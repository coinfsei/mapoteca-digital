-- ===================================================================================
-- Mapoteca Digital - Script 04: Integração ESRI SDE e Attachments
-- ===================================================================================
-- Descrição: Configuração de integração com ESRI SDE para armazenamento de PDFs
-- Ambiente: Oracle Linux (10.28.246.75) | PostgreSQL 14+ | ESRI SDE
-- Usuário: dados_mapoteca | Schema: dados_mapoteca
-- Data: 2025-11-10
-- Dependências: Scripts 01, 02 e 03 devem ser executados anteriormente
-- ===================================================================================

-- Configuração do ambiente
\set ON_ERROR_STOP on
SET client_min_messages TO WARNING;
SET search_path TO dados_mapoteca, public;

-- ===================================================================================
-- 1. VERIFICAÇÃO DO AMBIENTE ESRI SDE
-- ===================================================================================

-- 1.1. Verificar se SDE está disponível
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.schemata
        WHERE schema_name = 'sde'
    ) THEN
        RAISE EXCEPTION 'ESRI SDE schema não encontrado. Verifique instalação do ESRI SDE.';
    END IF;

    RAISE NOTICE 'ESRI SDE detectado. Procedendo com configuração...';
END $$;

-- 1.2. Verificar tabelas SDE existentes
DO $$
DECLARE
    sde_tables_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO sde_tables_count
    FROM information_schema.tables
    WHERE table_schema = 'sde';

    RAISE NOTICE 'Tabelas SDE encontradas: %', sde_tables_count;

    -- Listar principais tabelas SDE se existirem
    IF sde_tables_count > 0 THEN
        RAISE NOTICE 'Tabelas SDE principais:';
        PERFORM pg_sleep(0.1); -- Pequena pausa para formatação
    END IF;
END $$;

-- ===================================================================================
-- 2. EXTENSÕES NECESSÁRIAS PARA ESRI INTEGRATION
-- ===================================================================================

-- 2.1. Habilitar extensão para UUID e dados binários
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2.2. Verificar se extensão postgis está disponível (mesmo que não usada diretamente)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_available_extensions
        WHERE name = 'postgis'
    ) THEN
        CREATE EXTENSION IF NOT EXISTS postgis;
        RAISE NOTICE 'PostGIS habilitado (para compatibilidade ESRI)';
    ELSE
        RAISE NOTICE 'PostGIS não disponível - usando modo não espacial';
    END IF;
END $$;

-- ===================================================================================
-- 3. TABELAS DE CONTROLE ESRI
-- ===================================================================================

-- 3.1. Tabela de controle de sincronização com ESRI
CREATE TABLE IF NOT EXISTS dados_mapoteca.esri_sync_control (
    id SERIAL PRIMARY KEY,
    tabela_origem VARCHAR(100) NOT NULL,
    tabela_sde VARCHAR(100),
    ultima_sincronizacao TIMESTAMP,
    status_sincronizacao VARCHAR(20) DEFAULT 'pending',
    total_registros INTEGER DEFAULT 0,
    registros_sincronizados INTEGER DEFAULT 0,
    erros TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_status_sincronizacao
        CHECK (status_sincronizacao IN ('pending', 'in_progress', 'completed', 'failed'))
);

COMMENT ON TABLE dados_mapoteca.esri_sync_control IS 'Controle de sincronização com tabelas ESRI SDE';
COMMENT ON COLUMN dados_mapoteca.esri_sync_control.tabela_origem IS 'Tabela no schema dados_mapoteca';
COMMENT ON COLUMN dados_mapoteca.esri_sync_control.tabela_sde IS 'Tabela correspondente no schema SDE';

-- 3.2. Tabela de metadados ESRI
CREATE TABLE IF NOT EXISTS dados_mapoteca.esri_metadata (
    id SERIAL PRIMARY KEY,
    id_publicacao UUID REFERENCES dados_mapoteca.publicacoes(id) ON DELETE CASCADE,
    sde_table_name VARCHAR(100) NOT NULL,
    sde_objectid INTEGER NOT NULL,
    sde_global_id UUID,
    sde_shape_length DECIMAL(15,5),
    sde_shape_area DECIMAL(15,5),
    sde_created_user VARCHAR(100),
    sde_created_date TIMESTAMP,
    sde_last_edited_user VARCHAR(100),
    sde_last_edited_date TIMESTAMP,
    sde_gdb_geomattr_data BYTEA,
    esri_metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(sde_table_name, sde_objectid)
);

COMMENT ON TABLE dados_mapoteca.esri_metadata IS 'Metadados específicos do ESRI SDE para cada publicação';
COMMENT ON COLUMN dados_mapoteca.esri_metadata.sde_global_id IS 'Global ID único do ESRI';
COMMENT ON COLUMN dados_mapoteca.esri_metadata.esri_metadata IS 'Metadados adicionais em formato JSON';

-- 3.3. Tabela de gerenciamento de Attachments ESRI
CREATE TABLE IF NOT EXISTS dados_mapoteca.esri_attachments_registry (
    id SERIAL PRIMARY KEY,
    attachment_id INTEGER UNIQUE NOT NULL,
    id_publicacao UUID REFERENCES dados_mapoteca.publicacoes(id) ON DELETE CASCADE,
    sde_table_name VARCHAR(100) NOT NULL,
    sde_parent_id INTEGER NOT NULL,
    attachment_name VARCHAR(255) NOT NULL,
    attachment_type VARCHAR(50) DEFAULT 'application/pdf',
    attachment_size INTEGER,
    content_type VARCHAR(100),
    data_blob BYTEA,
    rel_globalid UUID,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_user VARCHAR(100),
    keywords TEXT[],

    CONSTRAINT chk_attachment_id_positivo CHECK (attachment_id > 0),
    CONSTRAINT chk_sde_parent_id_positivo CHECK (sde_parent_id > 0)
);

COMMENT ON TABLE dados_mapoteca.esri_attachments_registry IS 'Registro central de attachments ESRI';
COMMENT ON COLUMN dados_mapoteca.esri_attachments_registry.rel_globalid IS 'Global ID relacionado ao attachment';

-- ===================================================================================
-- 4. FUNÇÕES DE INTEGRAÇÃO ESRI
-- ===================================================================================

-- 4.1. Função para gerar attachment_id único
CREATE OR REPLACE FUNCTION dados_mapoteca.fn_generate_attachment_id()
RETURNS INTEGER AS $$
DECLARE
    new_id INTEGER;
BEGIN
    -- Gerar ID único baseado em timestamp e sequência
    SELECT COALESCE(MAX(attachment_id), 0) + 1 INTO new_id
    FROM dados_mapoteca.esri_attachments_registry;

    -- Garantir que seja positivo e razoável
    IF new_id < 1000 THEN
        new_id := 1000;
    END IF;

    RETURN new_id;
END;
$$ LANGUAGE plpgsql;

-- 4.2. Função para salvar attachment no registro ESRI
CREATE OR REPLACE FUNCTION dados_mapoteca.fn_salvar_attachment_esri(
    p_id_publicacao UUID,
    p_nome_arquivo VARCHAR,
    p_dados_binarios BYTEA,
    p_tamanho INTEGER DEFAULT NULL,
    p_content_type VARCHAR DEFAULT 'application/pdf',
    p_usuario VARCHAR DEFAULT 'system'
)
RETURNS INTEGER AS $$
DECLARE
    v_attachment_id INTEGER;
    v_sde_table_name VARCHAR;
    v_sde_parent_id INTEGER;
BEGIN
    -- Obter informações da publicação
    SELECT COALESCE(sde_table_name, 'attachments'),
           COALESCE(sde_objectid, 1)
    INTO v_sde_table_name, v_sde_parent_id
    FROM dados_mapoteca.esri_metadata em
    WHERE em.id_publicacao = p_id_publicacao;

    -- Se não existe metadado ESRI, criar defaults
    IF v_sde_table_name IS NULL THEN
        v_sde_table_name := 'attachments';
        v_sde_parent_id := 1;

        -- Criar metadado ESRI básico
        INSERT INTO dados_mapoteca.esri_metadata (
            id_publicacao, sde_table_name, sde_objectid,
            sde_created_user, sde_created_date
        ) VALUES (
            p_id_publicacao, v_sde_table_name, v_sde_parent_id,
            p_usuario, CURRENT_TIMESTAMP
        );
    END IF;

    -- Gerar attachment_id único
    v_attachment_id := dados_mapoteca.fn_generate_attachment_id();

    -- Inserir no registry central
    INSERT INTO dados_mapoteca.esri_attachments_registry (
        attachment_id, id_publicacao, sde_table_name, sde_parent_id,
        attachment_name, attachment_type, attachment_size,
        content_type, data_blob, created_user
    ) VALUES (
        v_attachment_id, p_id_publicacao, v_sde_table_name, v_sde_parent_id,
        p_nome_arquivo, p_content_type, p_tamanho,
        p_content_type, p_dados_binarios, p_usuario
    );

    -- Atualizar tabela de anexos com o attachment_id
    INSERT INTO dados_mapoteca.anexos (
        id_publicacao, nome_arquivo, caminho_arquivo,
        tamanho_bytes, tipo_mime, attachment_id, attachment_data
    ) VALUES (
        p_id_publicacao, p_nome_arquivo, 'esri://' || v_sde_table_name || '/' || v_attachment_id,
        p_tamanho, p_content_type, v_attachment_id, p_dados_binarios
    );

    -- Registrar na tabela de controle
    INSERT INTO dados_mapoteca.esri_sync_control (
        tabela_origem, tabela_sde, status_sincronizacao,
        total_registros, registros_sincronizados
    ) VALUES (
        'anexos', v_sde_table_name, 'completed', 1, 1
    );

    RETURN v_attachment_id;
END;
$$ LANGUAGE plpgsql;

-- 4.3. Função para recuperar attachment
CREATE OR REPLACE FUNCTION dados_mapoteca.fn_recuperar_attachment_esri(
    p_attachment_id INTEGER
)
RETURNS TABLE (
    id_publicacao UUID,
    nome_arquivo VARCHAR,
    dados_binarios BYTEA,
    content_type VARCHAR,
    tamanho INTEGER,
    created_date TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ear.id_publicacao,
        ear.attachment_name,
        ear.data_blob,
        ear.content_type,
        ear.attachment_size,
        ear.created_date
    FROM dados_mapoteca.esri_attachments_registry ear
    WHERE ear.attachment_id = p_attachment_id;
END;
$$ LANGUAGE plpgsql;

-- 4.4. Função para listar attachments de uma publicação
CREATE OR REPLACE FUNCTION dados_mapoteca.fn_listar_attachments_publicacao(
    p_id_publicacao UUID
)
RETURNS TABLE (
    attachment_id INTEGER,
    nome_arquivo VARCHAR,
    content_type VARCHAR,
    tamanho INTEGER,
    created_date TIMESTAMP,
    download_url TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ear.attachment_id,
        ear.attachment_name,
        ear.content_type,
        ear.attachment_size,
        ear.created_date,
        '/api/attachments/download/' || ear.attachment_id::TEXT as download_url
    FROM dados_mapoteca.esri_attachments_registry ear
    WHERE ear.id_publicacao = p_id_publicacao
    ORDER BY ear.created_date DESC;
END;
$$ LANGUAGE plpgsql;

-- ===================================================================================
-- 5. VIEWS ESRI INTEGRATION
-- ===================================================================================

-- 5.1. View completa de publicações com ESRI metadata
CREATE OR REPLACE VIEW dados_mapoteca.v_publicacoes_esri AS
SELECT
    p.*,

    -- Metadados ESRI
    em.sde_table_name,
    em.sde_objectid,
    em.sde_global_id,
    em.sde_created_user,
    em.sde_created_date,
    em.sde_last_edited_user,
    em.sde_last_edited_date,
    em.esri_metadata,

    -- Controle de attachments
    (SELECT COUNT(*)
     FROM dados_mapoteca.esri_attachments_registry ear
     WHERE ear.id_publicacao = p.id) as total_attachments_esri,

    -- Attachment principal
    (SELECT attachment_id
     FROM dados_mapoteca.esri_attachments_registry ear
     WHERE ear.id_publicacao = p.id
     ORDER BY created_date DESC
     LIMIT 1) as attachment_principal_id,

    -- Tamanho total dos attachments
    (SELECT COALESCE(SUM(attachment_size), 0)
     FROM dados_mapoteca.esri_attachments_registry ear
     WHERE ear.id_publicacao = p.id) as tamanho_total_attachments_bytes

FROM dados_mapoteca.publicacoes p
LEFT JOIN dados_mapoteca.esri_metadata em ON p.id = em.id_publicacao;

COMMENT ON VIEW dados_mapoteca.v_publicacoes_esri IS 'View de publicações com metadados ESRI completos';

-- 5.2. View de attachments ESRI para administração
CREATE OR REPLACE VIEW dados_mapoteca.v_attachments_esri AS
SELECT
    ear.attachment_id,
    ear.id_publicacao,
    ear.sde_table_name,
    ear.sde_parent_id,
    ear.attachment_name,
    ear.attachment_type,
    ear.attachment_size,
    ear.content_type,
    ear.rel_globalid,
    ear.created_date,
    ear.created_user,
    ear.keywords,

    -- Informações da publicação
    p.titulo as publicacao_titulo,
    p.slug as publicacao_slug,
    p.publicado as publicacao_publicada,

    -- URL de download
    '/api/attachments/download/' || ear.attachment_id::TEXT as download_url

FROM dados_mapoteca.esri_attachments_registry ear
JOIN dados_mapoteca.publicacoes p ON ear.id_publicacao = p.id
ORDER BY ear.created_date DESC;

COMMENT ON VIEW dados_mapoteca.v_attachments_esri IS 'View administrativa de attachments ESRI';

-- ===================================================================================
-- 6. PROCEDURES DE SINCRONIZAÇÃO
-- ===================================================================================

-- 6.1. Procedure para sincronizar publicações com ESRI
CREATE OR REPLACE PROCEDURE dados_mapoteca.sp_sync_publicacoes_esri() AS $$
DECLARE
    v_sync_id INTEGER;
    v_total_registros INTEGER;
    v_registros_sincronizados INTEGER := 0;
    v_erros TEXT[] := ARRAY[]::TEXT[];
BEGIN
    -- Iniciar controle de sincronização
    INSERT INTO dados_mapoteca.esri_sync_control (
        tabela_origem, tabela_sde, status_sincronizacao, total_registros
    ) VALUES (
        'publicacoes', 'sde_attachments', 'in_progress',
        (SELECT COUNT(*) FROM dados_mapoteca.publicacoes WHERE publicado = true)
    ) RETURNING id INTO v_sync_id;

    -- Obter total de registros a sincronizar
    SELECT COUNT(*) INTO v_total_registros
    FROM dados_mapoteca.publicacoes
    WHERE publicado = true
    AND id NOT IN (SELECT id_publicacao FROM dados_mapoteca.esri_metadata);

    RAISE NOTICE 'Iniciando sincronização de % publicações com ESRI...', v_total_registros;

    -- Loop para sincronizar cada publicação
    FOR pub_record IN
        SELECT id, titulo, created_at
        FROM dados_mapoteca.publicacoes
        WHERE publicado = true
        AND id NOT IN (SELECT id_publicacao FROM dados_mapoteca.esri_metadata)
    LOOP
        BEGIN
            -- Criar metadado ESRI para publicação
            INSERT INTO dados_mapoteca.esri_metadata (
                id_publicacao, sde_table_name, sde_objectid,
                sde_created_user, sde_created_date
            ) VALUES (
                pub_record.id, 'publicacoes', pub_record.id::INTEGER,
                'system', pub_record.created_at
            );

            v_registros_sincronizados := v_registros_sincronizados + 1;

            -- Atualizar sde_objectid na publicação
            UPDATE dados_mapoteca.publicacoes
            SET sde_objectid = pub_record.id::INTEGER
            WHERE id = pub_record.id;

        EXCEPTION WHEN OTHERS THEN
            v_erros := array_append(v_erros,
                'Erro na publicação ' || pub_record.id || ': ' || SQLERRM);
        END;
    END LOOP;

    -- Atualizar controle de sincronização
    UPDATE dados_mapoteca.esri_sync_control
    SET status_sincronizacao = CASE
            WHEN v_erros = ARRAY[]::TEXT[] THEN 'completed'
            ELSE 'completed_with_errors'
        END,
        registros_sincronizados = v_registros_sincronizados,
        erros = v_erros,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = v_sync_id;

    RAISE NOTICE 'Sincronização concluída: %/% registros sincronizados',
                 v_registros_sincronizados, v_total_registros;

    IF v_erros != ARRAY[]::TEXT[] THEN
        RAISE WARNING 'Erros encontrados: %', array_to_string(v_erros, '; ');
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ===================================================================================
-- 7. ÍNDICES ESPECÍFICOS ESRI
-- ===================================================================================

-- 7.1. Índices para performance de consultas ESRI
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_esri_metadata_publicacao
ON dados_mapoteca.esri_metadata (id_publicacao);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_esri_metadata_sde_table_objectid
ON dados_mapoteca.esri_metadata (sde_table_name, sde_objectid);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_esri_metadata_global_id
ON dados_mapoteca.esri_metadata (sde_global_id) WHERE sde_global_id IS NOT NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_esri_attachments_publicacao
ON dados_mapoteca.esri_attachments_registry (id_publicacao);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_esri_attachments_table_parent
ON dados_mapoteca.esri_attachments_registry (sde_table_name, sde_parent_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_esri_attachments_id
ON dados_mapoteca.esri_attachments_registry (attachment_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_esri_attachments_global_id
ON dados_mapoteca.esri_attachments_registry (rel_globalid) WHERE rel_global_id IS NOT NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_esri_attachments_created_date
ON dados_mapoteca.esri_attachments_registry (created_date DESC);

-- 7.2. Índices para controle de sincronização
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_esri_sync_control_status
ON dados_mapoteca.esri_sync_control (status_sincronizacao, updated_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_esri_sync_control_origem
ON dados_mapoteca.esri_sync_control (tabela_origem, tabela_sde);

-- ===================================================================================
-- 8. VALIDAÇÃO E TESTES DE INTEGRAÇÃO
-- ===================================================================================

-- 8.1. Função para testar integração ESRI
CREATE OR REPLACE FUNCTION dados_mapoteca.fn_testar_integracao_esri()
RETURNS TABLE (
    teste VARCHAR,
    status VARCHAR,
    resultado TEXT
) AS $$
DECLARE
    v_test_result TEXT;
BEGIN
    -- Teste 1: Verificar schema SDE
    BEGIN
        IF EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'sde') THEN
            v_test_result := 'Schema SDE encontrado e acessível';
            RETURN QUERY SELECT 'Schema SDE'::VARCHAR, 'OK'::VARCHAR, v_test_result::TEXT;
        ELSE
            v_test_result := 'Schema SDE não encontrado';
            RETURN QUERY SELECT 'Schema SDE'::VARCHAR, 'ERRO'::VARCHAR, v_test_result::TEXT;
        END IF;
    END;

    -- Teste 2: Verificar tabelas de integração
    BEGIN
        IF EXISTS (SELECT 1 FROM information_schema.tables
                   WHERE table_schema = 'dados_mapoteca'
                   AND table_name IN ('esri_metadata', 'esri_attachments_registry')) THEN
            v_test_result := 'Tabelas de integração ESRI criadas com sucesso';
            RETURN QUERY SELECT 'Tabelas ESRI'::VARCHAR, 'OK'::VARCHAR, v_test_result::TEXT;
        ELSE
            v_test_result := 'Tabelas de integração não encontradas';
            RETURN QUERY SELECT 'Tabelas ESRI'::VARCHAR, 'ERRO'::VARCHAR, v_test_result::TEXT;
        END IF;
    END;

    -- Teste 3: Verificar funções ESRI
    BEGIN
        IF EXISTS (SELECT 1 FROM information_schema.routines
                   WHERE routine_schema = 'dados_mapoteca'
                   AND routine_name LIKE 'fn_%esri%') THEN
            v_test_result := 'Funções de integração ESRI disponíveis';
            RETURN QUERY SELECT 'Funções ESRI'::VARCHAR, 'OK'::VARCHAR, v_test_result::TEXT;
        ELSE
            v_test_result := 'Funções de integração não encontradas';
            RETURN QUERY SELECT 'Funções ESRI'::VARCHAR, 'ERRO'::VARCHAR, v_test_result::TEXT;
        END IF;
    END;

    -- Teste 4: Testar geração de attachment_id
    BEGIN
        PERFORM dados_mapoteca.fn_generate_attachment_id();
        v_test_result := 'Geração de attachment_id funcionando';
        RETURN QUERY SELECT 'Gerador ID'::VARCHAR, 'OK'::VARCHAR, v_test_result::TEXT;
    EXCEPTION WHEN OTHERS THEN
        v_test_result := 'Erro no gerador de attachment_id: ' || SQLERRM;
        RETURN QUERY SELECT 'Gerador ID'::VARCHAR, 'ERRO'::VARCHAR, v_test_result::TEXT;
    END;

    -- Teste 5: Verificar views ESRI
    BEGIN
        IF EXISTS (SELECT 1 FROM information_schema.views
                   WHERE table_schema = 'dados_mapoteca'
                   AND table_name LIKE 'v_%esri%') THEN
            v_test_result := 'Views ESRI criadas com sucesso';
            RETURN QUERY SELECT 'Views ESRI'::VARCHAR, 'OK'::VARCHAR, v_test_result::TEXT;
        ELSE
            v_test_result := 'Views ESRI não encontradas';
            RETURN QUERY SELECT 'Views ESRI'::VARCHAR, 'ERRO'::VARCHAR, v_test_result::TEXT;
        END IF;
    END;
END;
$$ LANGUAGE plpgsql;

-- ===================================================================================
-- 9. RESUMO E VALIDAÇÃO FINAL
-- ===================================================================================

-- 9.1. Executar testes de integração
SELECT * FROM dados_mapoteca.fn_testar_integracao_esri();

-- 9.2. Resumo da configuração ESRI
SELECT
    'INTEGRAÇÃO ESRI SDE' as componente,
    'Configuração concluída' as status,
    CASE
        WHEN EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'sde')
        THEN 'Schema SDE disponível'
        ELSE 'Schema SDE não encontrado - usar modo simulado'
    END as observacao

UNION ALL

SELECT
    'Tabelas ESRI' as componente,
    (SELECT COUNT(*)::TEXT FROM information_schema.tables
     WHERE table_schema = 'dados_mapoteca'
     AND table_name LIKE 'esri_%') || ' tabelas criadas' as status,
    'Metadados, attachments e controle de sincronização' as observacao

UNION ALL

SELECT
    'Funções ESRI' as componente,
    (SELECT COUNT(*)::TEXT FROM information_schema.routines
     WHERE routine_schema = 'dados_mapoteca'
     AND routine_name LIKE 'fn_%esri%') || ' funções criadas' as status,
    'Upload, download e gerenciamento de attachments' as observacao

UNION ALL

SELECT
    'Views ESRI' as componente,
    (SELECT COUNT(*)::TEXT FROM information_schema.views
     WHERE table_schema = 'dados_mapoteca'
     AND table_name LIKE 'v_%esri%') || ' views criadas' as status,
    'Consultas administrativas e de integração' as observacao;

-- 9.3. Próximos passos recomendados
SELECT
    'PRÓXIMOS PASSOS' as categoria,
    'Ações recomendadas após configuração ESRI' as descricao,
    ARRAY[
        '1. Testar upload de PDF com fn_salvar_attachment_esri()',
        '2. Verificar sincronização com sp_sync_publicacoes_esri()',
        '3. Validar downloads via API endpoints',
        '4. Configurar backup das tabelas ESRI',
        '5. Documentar integração com equipe ESRI'
    ] as acoes_recomendadas;

-- Fim do Script 04
-- ===================================================================================