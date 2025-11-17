-- ===================================================================================
-- Mapoteca Digital - Script 03: Índices e Constraints Adicionais
-- ===================================================================================
-- Descrição: Criação de índices otimizados e constraints para performance e integridade
-- Ambiente: Oracle Linux (10.28.246.75) | PostgreSQL 14+ | ESRI SDE
-- Usuário: dados_mapoteca | Schema: dados_mapoteca
-- Data: 2025-11-10
-- Dependências: Scripts 01-setup-schema.sql e 02-populate-data.sql
-- ===================================================================================

-- Configuração do ambiente
\set ON_ERROR_STOP on
SET client_min_messages TO WARNING;
SET search_path TO dados_mapoteca, public;

-- ===================================================================================
-- 1. ÍNDICES PARA TABELAS PRINCIPAIS
-- ===================================================================================

-- 1.1. Índices para Publicações (Performance Crítica)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_publicacoes_id
ON dados_mapoteca.publicacoes (id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_publicacoes_slug
ON dados_mapoteca.publicacoes (slug);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_publicacoes_publicadas
ON dados_mapoteca.publicacoes (publicado, destacado, created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_publicacoes_classe_tipo
ON dados_mapoteca.publicacoes (id_classe_publicacao, id_tipo_publicacao);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_publicacoes_ano
ON dados_mapoteca.publicacoes (id_ano);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_publicacoes_escala
ON dados_mapoteca.publicacoes (id_escala);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_publicacoes_cor
ON dados_mapoteca.publicacoes (id_cor);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_publicacoes_autor
ON dados_mapoteca.publicacoes (autor);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_publicacoes_fonte
ON dados_mapoteca.publicacoes (fonte);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_publicacoes_instituicao
ON dados_mapoteca.publicacoes (instituicao);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_publicacoes_created_at
ON dados_mapoteca.publicacoes (created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_publicacoes_updated_at
ON dados_mapoteca.publicacoes (updated_at DESC);

-- 1.2. Índices para Temas
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_temas_codigo
ON dados_mapoteca.temas (codigo);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_temas_slug
ON dados_mapoteca.temas (slug);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_temas_tipo
ON dados_mapoteca.temas (id_tipo_tema);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_temas_ativos
ON dados_mapoteca.temas (ativo, ordem_exibicao);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_temas_busca_nome
ON dados_mapoteca.temas USING GIN (to_tsvector('portuguese', nome));

-- 1.3. Índices para Regiões
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_regioes_codigo
ON dados_mapoteca.regioes (codigo);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_regioes_slug
ON dados_mapoteca.regioes (slug);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_regioes_tipo
ON dados_mapoteca.regioes (tipo_regionalizacao);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_regioes_ativas
ON dados_mapoteca.regioes (ativo);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_regioes_busca_nome
ON dados_mapoteca.regioes USING GIN (to_tsvector('portuguese', nome));

-- 1.4. Índices para Tabelas de Domínio
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tipos_tema_codigo
ON dados_mapoteca.tipos_tema (codigo);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tipos_tema_ativos
ON dados_mapoteca.tipos_tema (ativo, ordem_exibicao);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_classes_pub_codigo
ON dados_mapoteca.classes_publicacao (codigo);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_classes_pub_ativas
ON dados_mapoteca.classes_publicacao (ativo, ordem_exibicao);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tipos_pub_codigo
ON dados_mapoteca.tipos_publicacao (codigo);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tipos_pub_ativas
ON dados_mapoteca.tipos_publicacao (ativo, ordem_exibicao);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_anos_ano
ON dados_mapoteca.anos (ano);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_anos_ativos
ON dados_mapoteca.anos (ativo);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_escalas_codigo
ON dados_mapoteca.escalas (codigo);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_escalas_ativas
ON dados_mapoteca.escalas (ativo);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_cores_codigo
ON dados_mapoteca.cores (codigo);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_cores_ativas
ON dados_mapoteca.cores (ativo);

-- ===================================================================================
-- 2. ÍNDICES PARA TABELAS DE RELACIONAMENTO
-- ===================================================================================

-- 2.1. Publicações × Temas
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_pub_tema_publicacao
ON dados_mapoteca.publicacao_temas (id_publicacao);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_pub_tema_tema
ON dados_mapoteca.publicacao_temas (id_tema);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_pub_tema_unico
ON dados_mapoteca.publicacao_temas (id_publicacao, id_tema);

-- 2.2. Publicações × Regiões
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_pub_regiao_publicacao
ON dados_mapoteca.publicacao_regioes (id_publicacao);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_pub_regiao_regiao
ON dados_mapoteca.publicacao_regioes (id_regiao);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_pub_regiao_nivel_cobertura
ON dados_mapoteca.publicacao_regioes (nivel_cobertura);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_pub_regiao_unico
ON dados_mapoteca.publicacao_regioes (id_publicacao, id_regiao);

-- 2.3. Anexos
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_anexos_publicacao
ON dados_mapoteca.anexos (id_publicacao);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_anexos_principal
ON dados_mapoteca.anexos (id_publicacao, principal);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_anexos_ordem
ON dados_mapoteca.anexos (id_publicacao, ordem);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_anexos_visivel
ON dados_mapoteca.anexos (id_publicacao, visivel);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_anexos_attachment_id
ON dados_mapoteca.anexos (attachment_id);

-- ===================================================================================
-- 3. ÍNDICES PARA TABELAS DE SISTEMA
-- ===================================================================================

-- 3.1. Audit Log
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_log_tabela
ON dados_mapoteca.audit_log (tabela);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_log_operacao
ON dados_mapoteca.audit_log (operacao);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_log_data
ON dados_mapoteca.audit_log (data_operacao DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_log_usuario
ON dados_mapoteca.audit_log (usuario);

-- 3.2. Estatísticas de Acesso
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_estatisticas_publicacao
ON dados_mapoteca.estatisticas_acesso (id_publicacao);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_estatisticas_tipo
ON dados_mapoteca.estatisticas_acesso (tipo_acesso);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_estatisticas_data
ON dados_mapoteca.estatisticas_acesso (data_acesso DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_estatisticas_ip
ON dados_mapoteca.estatisticas_acesso (ip_address);

-- ===================================================================================
-- 4. ÍNDICES COMPOSTOS PARA PERFORMANCE DE BUSCA
-- ===================================================================================

-- 4.1. Índices para filtros combinados frequentes
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_publicacoes_filtros_principais
ON dados_mapoteca.publicacoes (publicado, id_classe_publicacao, id_tipo_publicacao, created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_publicacoes_filtros_completos
ON dados_mapoteca.publicacoes (publicado, id_classe_publicacao, id_tipo_publicacao, id_ano, id_escala);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_publicacoes_busca_avancada
ON dados_mapoteca.publicacoes (publicado, id_ano, id_classe_publicacao, destacado);

-- 4.2. Índices para ordenações específicas
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_publicacoes_ordenacao_downloads
ON dados_mapoteca.publicacoes (publicado, downloads DESC, created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_publicacoes_ordenacao_visualizacoes
ON dados_mapoteca.publicacoes (publicado, visualizacoes DESC, created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_publicacoes_ordenacao_titulo
ON dados_mapoteca.publicacoes (publicado, titulo);

-- 4.3. Índices para coordenadas geográficas
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_publicacoes_cobertura_geografica
ON dados_mapoteca.publicacoes (cobertura_norte, cobertura_sul, cobertura_leste, cobertura_oeste)
WHERE publicado = true;

-- ===================================================================================
-- 5. CONSTRAINTS ADICIONAIS
-- ===================================================================================

-- 5.1. CHECK Constraints para validações de negócio

-- Validação de combinações válidas (já existe mas vamos reforçar)
ALTER TABLE dados_mapoteca.publicacoes
ADD CONSTRAINT chk_pub_tipo_classe_combinacao
CHECK (
    -- Mapas: Estadual, Regional, Municipal (3 combinações)
    (id_classe_publicacao = 1 AND id_tipo_publicacao IN (1, 2, 3))
    OR
    -- Cartogramas: Estadual, Regional, Municipal (3 combinações)
    (id_classe_publicacao = 2 AND id_tipo_publicacao IN (1, 2, 3))
);

-- Validação de tamanhos de arquivos
ALTER TABLE dados_mapoteca.publicacoes
ADD CONSTRAINT chk_pub_tamanho_arquivo_mb
CHECK (tamanho_arquivo_mb IS NULL OR tamanho_arquivo_mb > 0);

-- Validação de número de páginas
ALTER TABLE dados_mapoteca.publicacoes
ADD CONSTRAINT chk_pub_numero_paginas
CHECK (numero_paginas IS NULL OR numero_paginas > 0);

-- Validação de resolução DPI
ALTER TABLE dados_mapoteca.publicacoes
ADD CONSTRAINT chk_pub_resolucao_dpi
CHECK (resolucao_dpi IS NULL OR resolucao_dpi > 0);

-- Validação de formato de arquivo
ALTER TABLE dados_mapoteca.publicacoes
ADD CONSTRAINT chk_pub_formato_arquivo
CHECK (formato_arquivo IN ('PDF', 'TIFF', 'JPG', 'PNG', 'DWG', 'SHP') OR formato_arquivo IS NULL);

-- 5.2. Constraints para Anexos
ALTER TABLE dados_mapoteca.anexos
ADD CONSTRAINT chk_anexo_tamanho_bytes
CHECK (tamanho_bytes IS NULL OR tamanho_bytes > 0);

ALTER TABLE dados_mapoteca.anexos
ADD CONSTRAINT chk_anexo_tipo_mime
CHECK (tipo_mime IS NULL OR
        tipo_mime IN ('application/pdf', 'image/tiff', 'image/jpeg', 'image/png'));

ALTER TABLE dados_mapoteca.anexos
ADD CONSTRAINT chk_anexo_checksum_md5
CHECK (checksum_md5 IS NULL OR LENGTH(checksum_md5) = 32);

-- 5.3. Constraints para coordenadas geográficas
ALTER TABLE dados_mapoteca.publicacoes
ADD CONSTRAINT chk_pub_coordenada_latitude
CHECK (
    (cobertura_norte IS NULL OR (cobertura_norte >= -90 AND cobertura_norte <= 90)) AND
    (cobertura_sul IS NULL OR (cobertura_sul >= -90 AND cobertura_sul <= 90))
);

ALTER TABLE dados_mapoteca.publicacoes
ADD CONSTRAINT chk_pub_coordenada_longitude
CHECK (
    (cobertura_leste IS NULL OR (cobertura_leste >= -180 AND cobertura_leste <= 180)) AND
    (cobertura_oeste IS NULL OR (cobertura_oeste >= -180 AND cobertura_oeste <= 180))
);

-- ===================================================================================
-- 6. TRIGGERS PARA AUDITORIA AUTOMÁTICA
-- ===================================================================================

-- 6.1. Função para auditoria de alterações
CREATE OR REPLACE FUNCTION dados_mapoteca.fn_audit_log()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO dados_mapoteca.audit_log (
            tabela, operacao, id_registro, valores_antigos,
            usuario, ip_address, user_agent
        ) VALUES (
            TG_TABLE_NAME, TG_OP, OLD.id, row_to_json(OLD),
            current_setting('application_name', true),
            inet_client_addr(),
            current_setting('application_name', true)
        );
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO dados_mapoteca.audit_log (
            tabela, operacao, id_registro, valores_antigos, valores_novos,
            usuario, ip_address, user_agent
        ) VALUES (
            TG_TABLE_NAME, TG_OP, NEW.id, row_to_json(OLD), row_to_json(NEW),
            current_setting('application_name', true),
            inet_client_addr(),
            current_setting('application_name', true)
        );
        RETURN NEW;
    ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO dados_mapoteca.audit_log (
            tabela, operacao, id_registro, valores_novos,
            usuario, ip_address, user_agent
        ) VALUES (
            TG_TABLE_NAME, TG_OP, NEW.id, row_to_json(NEW),
            current_setting('application_name', true),
            inet_client_addr(),
            current_setting('application_name', true)
        );
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 6.2. Aplicar triggers nas tabelas principais
DROP TRIGGER IF EXISTS trigger_audit_publicacoes ON dados_mapoteca.publicacoes;
CREATE TRIGGER trigger_audit_publicacoes
    AFTER INSERT OR UPDATE OR DELETE ON dados_mapoteca.publicacoes
    FOR EACH ROW EXECUTE FUNCTION dados_mapoteca.fn_audit_log();

DROP TRIGGER IF EXISTS trigger_audit_temas ON dados_mapoteca.temas;
CREATE TRIGGER trigger_audit_temas
    AFTER INSERT OR UPDATE OR DELETE ON dados_mapoteca.temas
    FOR EACH ROW EXECUTE FUNCTION dados_mapoteca.fn_audit_log();

DROP TRIGGER IF EXISTS trigger_audit_regioes ON dados_mapoteca.regioes;
CREATE TRIGGER trigger_audit_regioes
    AFTER INSERT OR UPDATE OR DELETE ON dados_mapoteca.regioes
    FOR EACH ROW EXECUTE FUNCTION dados_mapoteca.fn_audit_log();

DROP TRIGGER IF EXISTS trigger_audit_anexos ON dados_mapoteca.anexos;
CREATE TRIGGER trigger_audit_anexos
    AFTER INSERT OR UPDATE OR DELETE ON dados_mapoteca.anexos
    FOR EACH ROW EXECUTE FUNCTION dados_mapoteca.fn_audit_log();

-- ===================================================================================
-- 7. TRIGGERS PARA ATUALIZAÇÃO AUTOMÁTICA DE CAMPOS
-- ===================================================================================

-- 7.1. Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION dados_mapoteca.fn_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    NEW.updated_by = current_setting('application_name', true);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger de updated_at
DROP TRIGGER IF EXISTS trigger_updated_at_publicacoes ON dados_mapoteca.publicacoes;
CREATE TRIGGER trigger_updated_at_publicacoes
    BEFORE UPDATE ON dados_mapoteca.publicacoes
    FOR EACH ROW EXECUTE FUNCTION dados_mapoteca.fn_updated_at();

DROP TRIGGER IF EXISTS trigger_updated_at_temas ON dados_mapoteca.temas;
CREATE TRIGGER trigger_updated_at_temas
    BEFORE UPDATE ON dados_mapoteca.temas
    FOR EACH ROW EXECUTE FUNCTION dados_mapoteca.fn_updated_at();

DROP TRIGGER IF EXISTS trigger_updated_at_regioes ON dados_mapoteca.regioes;
CREATE TRIGGER trigger_updated_at_regioes
    BEFORE UPDATE ON dados_mapoteca.regioes
    FOR EACH ROW EXECUTE FUNCTION dados_mapoteca.fn_updated_at();

-- 7.2. Trigger para incrementar visualizações
CREATE OR REPLACE FUNCTION dados_mapoteca.fn_incrementar_visualizacao()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE dados_mapoteca.publicacoes
    SET visualizacoes = visualizacoes + 1
    WHERE id = NEW.id_publicacao;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_incrementar_visualizacao ON dados_mapoteca.estatisticas_acesso;
CREATE TRIGGER trigger_incrementar_visualizacao
    AFTER INSERT ON dados_mapoteca.estatisticas_acesso
    FOR EACH ROW
    WHEN (NEW.tipo_acesso = 'visualizacao')
    EXECUTE FUNCTION dados_mapoteca.fn_incrementar_visualizacao();

-- ===================================================================================
-- 8. PARTIAL INDEXES PARA PERFORMANCE
-- ===================================================================================

-- 8.1. Índices apenas para registros publicados (maioria das consultas)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_publicacoes_publicadas_titulo
ON dados_mapoteca.publicacoes (titulo)
WHERE publicado = true;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_publicacoes_publicadas_created_at
ON dados_mapoteca.publicacoes (created_at DESC)
WHERE publicado = true;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_publicacoes_publicadas_destacadas
ON dados_mapoteca.publicacoes (destacado, created_at DESC)
WHERE publicado = true AND destacado = true;

-- 8.2. Índices para anexos visíveis
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_anexos_visiveis_principal
ON dados_mapoteca.anexos (id_publicacao, principal DESC, ordem)
WHERE visivel = true;

-- ===================================================================================
-- 9. ESTATÍSTICAS E ANÁLISE DE PERFORMANCE
-- ===================================================================================

-- 9.1. Coletar estatísticas das tabelas
ANALYZE dados_mapoteca.publicacoes;
ANALYZE dados_mapoteca.temas;
ANALYZE dados_mapoteca.regioes;
ANALYZE dados_mapoteca.anexos;
ANALYZE dados_mapoteca.publicacao_temas;
ANALYZE dados_mapoteca.publicacao_regioes;
ANALYZE dados_mapoteca.tipos_tema;
ANALYZE dados_mapoteca.classes_publicacao;
ANALYZE dados_mapoteca.tipos_publicacao;
ANALYZE dados_mapoteca.anos;
ANALYZE dados_mapoteca.escalas;
ANALYZE dados_mapoteca.cores;

-- 9.2. Query para análise de índices criados
SELECT
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'dados_mapoteca'
ORDER BY tablename, indexname;

-- 9.3. Query para análise de tamanho das tabelas
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as tamanho_total,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) as tamanho_tabela,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) as tamanho_indices
FROM pg_tables
WHERE schemaname = 'dados_mapoteca'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- ===================================================================================
-- 10. VALIDAÇÃO FINAL
-- ===================================================================================

-- Resumo da criação de índices
SELECT
    'RESUMO ÍNDICES E CONSTRAINTS' as descricao,
    'Script 03 concluído com sucesso' as status;

-- Contagem de índices por tabela
SELECT
    'ÍNDICES POR TABELA' as categoria,
    COUNT(*) as total_indices,
    STRING_AGG(indexname, ', ' ORDER BY indexname) as indices_criados
FROM pg_indexes
WHERE schemaname = 'dados_mapoteca'
GROUP BY 'ÍNDICES POR TABELA'

UNION ALL

SELECT
    'TOTAL DE ÍNDICES' as categoria,
    COUNT(*) as total_indices,
    NULL as indices_criados
FROM pg_indexes
WHERE schemaname = 'dados_mapoteca';

-- Verificação de constraints
SELECT
    'CONSTRAINTS POR TABELA' as categoria,
    COUNT(*) as total_constraints,
    STRING_AGG(constraint_name, ', ' ORDER BY constraint_name) as constraints_criadas
FROM information_schema.table_constraints
WHERE table_schema = 'dados_mapoteca'
GROUP BY 'CONSTRAINTS POR TABELA'

UNION ALL

SELECT
    'TOTAL DE CONSTRAINTS' as categoria,
    COUNT(*) as total_constraints,
    NULL as constraints_criadas
FROM information_schema.table_constraints
WHERE table_schema = 'dados_mapoteca';

-- Teste de performance (query exemplo)
EXPLAIN (ANALYZE, BUFFERS)
SELECT p.*, t.nome as tema, r.nome as regiao
FROM dados_mapoteca.publicacoes p
LEFT JOIN dados_mapoteca.publicacao_temas pt ON p.id = pt.id_publicacao
LEFT JOIN dados_mapoteca.temas t ON pt.id_tema = t.id
LEFT JOIN dados_mapoteca.publicacao_regioes pr ON p.id = pr.id_publicacao
LEFT JOIN dados_mapoteca.regioes r ON pr.id_regiao = r.id
WHERE p.publicado = true
LIMIT 10;

-- Fim do Script 03
-- ===================================================================================