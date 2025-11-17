-- ===================================================================================
-- Mapoteca Digital - Script 01: Setup Schema Principal
-- ===================================================================================
-- Descrição: Criação do schema dados_mapoteca e tabelas principais
-- Ambiente: Oracle Linux (10.28.246.75) | PostgreSQL 14+ | ESRI SDE
-- Usuário: dados_mapoteca | Schema: dados_mapoteca
-- Data: 2025-11-10
-- ===================================================================================

-- Configuração do ambiente
\set ON_ERROR_STOP on
SET client_min_messages TO WARNING;
SET search_path TO dados_mapoteca, public;

-- ===================================================================================
-- 1. CRIAÇÃO DO SCHEMA
-- ===================================================================================
DROP SCHEMA IF EXISTS dados_mapoteca CASCADE;
CREATE SCHEMA dados_mapoteca;
COMMENT ON SCHEMA dados_mapoteca IS 'Schema principal da Mapoteca Digital para gestão de publicações cartográficas';

-- ===================================================================================
-- 2. EXTENSÕES NECESSÁRIAS
-- ===================================================================================
-- Habilitar extensão para UUID e busca full-text
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ===================================================================================
-- 3. TABELAS DE DOMÍNIO (LOOKUP TABLES)
-- ===================================================================================

-- 3.1. Tipos de Tema
CREATE TABLE dados_mapoteca.tipos_tema (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    cor_padrao VARCHAR(7) CHECK (cor_padrao ~ '^#[0-9A-Fa-f]{6}$' OR cor_padrao IS NULL),
    ordem_exibicao INTEGER DEFAULT 0,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_codigo_tipo_tema_format CHECK (codigo ~ '^[a-z]{3,10}$')
);

COMMENT ON TABLE dados_mapoteca.tipos_tema IS 'Tipos de temas para classificação das publicações';
COMMENT ON COLUMN dados_mapoteca.tipos_tema.codigo IS 'Código único em minúsculas';
COMMENT ON COLUMN dados_mapoteca.tipos_tema.cor_padrao IS 'Cor hexadecimal para UI (ex: #2E86AB)';

-- 3.2. Temas
CREATE TABLE dados_mapoteca.temas (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nome VARCHAR(200) NOT NULL,
    slug VARCHAR(250) UNIQUE NOT NULL,
    descricao TEXT,
    palavras_chave TEXT[],
    id_tipo_tema INTEGER REFERENCES dados_mapoteca.tipos_tema(id),
    ordem_exibicao INTEGER DEFAULT 0,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_tema_slug_format CHECK (slug ~ '^[a-z0-9-]+$'),
    CONSTRAINT chk_tema_codigo_format CHECK (codigo ~ '^[a-z0-9]{3,50}$')
);

COMMENT ON TABLE dados_mapoteca.temas IS 'Temas específicos das publicações cartográficas';
COMMENT ON COLUMN dados_mapoteca.temas.palavras_chave IS 'Array de tags para busca e classificação';

-- 3.3. Regiões (não espaciais)
CREATE TABLE dados_mapoteca.regioes (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nome VARCHAR(200) NOT NULL,
    slug VARCHAR(250) UNIQUE NOT NULL,
    descricao TEXT,
    tipo_regionalizacao VARCHAR(100),
    abrangencia TEXT,
    area_aproximada_km2 DECIMAL(12,2) CHECK (area_aproximada_km2 > 0 OR area_aproximada_km2 IS NULL),
    municipios_incluidos TEXT[],
    principais_cidades TEXT[],
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_regiao_slug_format CHECK (slug ~ '^[a-z0-9-]+$'),
    CONSTRAINT chk_regiao_codigo_format CHECK (codigo ~ '^[a-z0-9-]{3,50}$')
);

COMMENT ON TABLE dados_mapoteca.regioes IS 'Regiões geográficas (descrição textual, sem geometria)';
COMMENT ON COLUMN dados_mapoteca.regioes.tipo_regionalizacao IS 'Tipo: estadual, regional, municipal';

-- 3.4. Classes de Publicação (Mapa/Cartograma)
CREATE TABLE dados_mapoteca.classes_publicacao (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    ordem_exibicao INTEGER DEFAULT 0,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_classe_pub_codigo CHECK (codigo ~ '^[a-z]{3,20}$')
);

COMMENT ON TABLE dados_mapoteca.classes_publicacao IS 'Classes: mapa, cartograma';
COMMENT ON COLUMN dados_mapoteca.classes_publicacao.codigo IS 'Código: mapa, cartograma';

-- 3.5. Tipos de Publicação (Abrangência)
CREATE TABLE dados_mapoteca.tipos_publicacao (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    ordem_exibicao INTEGER DEFAULT 0,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_tipo_pub_codigo CHECK (codigo ~ '^[a-z]{3,20}$')
);

COMMENT ON TABLE dados_mapoteca.tipos_publicacao IS 'Tipos: estadual, regional, municipal';
COMMENT ON COLUMN dados_mapoteca.tipos_publicacao.codigo IS 'Código: estadual, regional, municipal';

-- 3.6. Anos
CREATE TABLE dados_mapoteca.anos (
    id SERIAL PRIMARY KEY,
    ano INTEGER UNIQUE NOT NULL CHECK (ano >= 1900 AND ano <= 2100),
    descricao VARCHAR(200),
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE dados_mapoteca.anos IS 'Anos de referência das publicações';

-- 3.7. Escalas
CREATE TABLE dados_mapoteca.escalas (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    denominador INTEGER CHECK (denominador > 0),
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_escala_codigo CHECK (codigo ~ '^[0-9:]+$')
);

COMMENT ON TABLE dados_mapoteca.escalas IS 'Escalas cartográficas (1:25.000, 1:100.000, etc)';
COMMENT ON COLUMN dados_mapoteca.escalas.denominador IS 'Denominador da escala (ex: 25000 para 1:25.000)';

-- 3.8. Cores
CREATE TABLE dados_mapoteca.cores (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE dados_mapoteca.cores IS 'Cores das publicações (colorido, pb, satelite, etc)';

-- ===================================================================================
-- 4. TABELAS PRINCIPAIS DE NEGÓCIO
-- ===================================================================================

-- 4.1. Publicações (Tabela Principal)
CREATE TABLE dados_mapoteca.publicacoes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    titulo VARCHAR(500) NOT NULL,
    slug VARCHAR(550) UNIQUE NOT NULL,
    descricao TEXT,
    resumo TEXT,
    palavras_chave TEXT[],

    -- Metadados Cartográficos
    id_classe_publicacao INTEGER REFERENCES dados_mapoteca.classes_publicacao(id),
    id_tipo_publicacao INTEGER REFERENCES dados_mapoteca.tipos_publicacao(id),
    id_ano INTEGER REFERENCES dados_mapoteca.anos(id),
    id_escala INTEGER REFERENCES dados_mapoteca.escalas(id),
    id_cor INTEGER REFERENCES dados_mapoteca.cores(id),

    -- Metadados Descritivos
    autor VARCHAR(200),
    fonte VARCHAR(300),
    instituicao VARCHAR(300),
    metodo_obtencao TEXT,
    precisao_info TEXT,

    -- Metadados Técnicos
    formato_arquivo VARCHAR(50) DEFAULT 'PDF',
    tamanho_arquivo_mb DECIMAL(10,2) CHECK (tamanho_arquivo_mb > 0 OR tamanho_arquivo_mb IS NULL),
    numero_paginas INTEGER CHECK (numero_paginas > 0 OR numero_paginas IS NULL),
    resolucao_dpi INTEGER CHECK (resolucao_dpi > 0 OR resolucao_dpi IS NULL),

    -- Sistema de Coordenadas (Informação Textual)
    sistema_referencia VARCHAR(100),
    datum VARCHAR(100),
    hemisferio VARCHAR(20) CHECK (hemisferio IN ('Norte', 'Sul') OR hemisferio IS NULL),
    fuso_horario VARCHAR(10) DEFAULT '-03:00',

    -- Cobertura Geográfica (Coordenadas Decimais)
    cobertura_norte DECIMAL(10,6) CHECK (cobertura_norte BETWEEN -90 AND 90 OR cobertura_norte IS NULL),
    cobertura_sul DECIMAL(10,6) CHECK (cobertura_sul BETWEEN -90 AND 90 OR cobertura_sul IS NULL),
    cobertura_leste DECIMAL(10,6) CHECK (cobertura_leste BETWEEN -180 AND 180 OR cobertura_leste IS NULL),
    cobertura_oeste DECIMAL(10,6) CHECK (cobertura_oeste BETWEEN -180 AND 180 OR cobertura_oeste IS NULL),
    descricao_cobertura TEXT,

    -- ESRI SDE Integration (não espacial)
    sde_table_name VARCHAR(100),
    sde_objectid INTEGER,
    sde_registro_modificado TIMESTAMP,

    -- Sistema de Busca e Conteúdo
    metadados JSONB DEFAULT '{}',
    search_vector tsvector,

    -- Status e Controle
    publicado BOOLEAN DEFAULT false,
    destacado BOOLEAN DEFAULT false,
    downloads INTEGER DEFAULT 0 CHECK (downloads >= 0),
    visualizacoes INTEGER DEFAULT 0 CHECK (visualizacoes >= 0),

    -- Auditoria
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100) DEFAULT 'system',
    updated_by VARCHAR(100),

    -- Constraints
    CONSTRAINT chk_pub_slug_format CHECK (slug ~ '^[a-z0-9-]+$'),
    CONSTRAINT chk_pub_coordenada_valida CHECK (
        (cobertura_norte IS NULL OR cobertura_sul IS NULL OR cobertura_norte >= cobertura_sul) AND
        (cobertura_leste IS NULL OR cobertura_oeste IS NULL OR cobertura_leste >= cobertura_oeste)
    ),
    CONSTRAINT chk_pub_tipo_combinacao CHECK (
        -- Validações específicas para os 6 tipos de publicação
        (id_classe_publicacao = 1 AND id_tipo_publicacao IN (1, 2, 3)) OR -- Mapas: Estadual, Regional, Municipal
        (id_classe_publicacao = 2 AND id_tipo_publicacao IN (1, 2, 3))    -- Cartogramas: Estadual, Regional, Municipal
    )
);

COMMENT ON TABLE dados_mapoteca.publicacoes IS 'Tabela principal de publicações cartográficas';
COMMENT ON COLUMN dados_mapoteca.publicacoes.id_classe_publicacao IS 'Classe: 1=Mapa, 2=Cartograma';
COMMENT ON COLUMN dados_mapoteca.publicacoes.id_tipo_publicacao IS 'Tipo: 1=Estadual, 2=Regional, 3=Municipal';
COMMENT ON COLUMN dados_mapoteca.publicacoes.search_vector IS 'Vetor para busca full-text';

-- 4.2. Relacionamento: Publicações × Temas
CREATE TABLE dados_mapoteca.publicacao_temas (
    id SERIAL PRIMARY KEY,
    id_publicacao UUID REFERENCES dados_mapoteca.publicacoes(id) ON DELETE CASCADE,
    id_tema INTEGER REFERENCES dados_mapoteca.temas(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(id_publicacao, id_tema)
);

COMMENT ON TABLE dados_mapoteca.publicacao_temas IS 'Relacionamento N:N entre publicações e temas';

-- 4.3. Relacionamento: Publicações × Regiões
CREATE TABLE dados_mapoteca.publicacao_regioes (
    id SERIAL PRIMARY KEY,
    id_publicacao UUID REFERENCES dados_mapoteca.publicacoes(id) ON DELETE CASCADE,
    id_regiao INTEGER REFERENCES dados_mapoteca.regioes(id) ON DELETE CASCADE,
    nivel_cobertura VARCHAR(50) CHECK (nivel_cobertura IN ('total', 'parcial', 'referencia') OR nivel_cobertura IS NULL),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(id_publicacao, id_regiao)
);

COMMENT ON TABLE dados_mapoteca.publicacao_regioes IS 'Relacionamento N:N entre publicações e regiões';
COMMENT ON COLUMN dados_mapoteca.publicacao_regioes.nivel_cobertura IS 'Nível de cobertura: total, parcial, referência';

-- ===================================================================================
-- 5. TABELAS DE ANEXOS E ARQUIVOS (ESRI Integration)
-- ===================================================================================

-- 5.1. Anexos (PDFs via ESRI Attachments)
CREATE TABLE dados_mapoteca.anexos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_publicacao UUID REFERENCES dados_mapoteca.publicacoes(id) ON DELETE CASCADE,
    nome_arquivo VARCHAR(500) NOT NULL,
    caminho_arquivo VARCHAR(1000) NOT NULL,
    tamanho_bytes BIGINT CHECK (tamanho_bytes > 0),
    tipo_mime VARCHAR(100) DEFAULT 'application/pdf',
    checksum_md5 VARCHAR(32) CHECK (checksum_md5 ~ '^[a-f0-9]{32}$' OR checksum_md5 IS NULL),

    -- Metadados do Arquivo
    data_upload TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ordem INTEGER DEFAULT 0 CHECK (ordem >= 0),
    principal BOOLEAN DEFAULT false,
    visivel BOOLEAN DEFAULT true,

    -- ESRI Attachments Integration
    attachment_id INTEGER UNIQUE, -- ID único no ESRI Attachments
    attachment_data BYTEA, -- Dados binários (opcional, se armazenado localmente)
    sde_created_date TIMESTAMP,
    sde_modified_date TIMESTAMP,

    -- Auditoria
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100) DEFAULT 'system',

    -- Constraints
    CONSTRAINT chk_anexo_principal_unico CHECK (
        principal = false OR
        id = (SELECT id FROM dados_mapoteca.anexos
              WHERE id_publicacao = anexos.id_publicacao AND principal = true
              ORDER BY created_at LIMIT 1)
    )
);

COMMENT ON TABLE dados_mapoteca.anexos IS 'Anexos PDF com integração ESRI Attachments';
COMMENT ON COLUMN dados_mapoteca.anexos.attachment_id IS 'ID único no sistema ESRI Attachments';

-- ===================================================================================
-- 6. TABELAS DE SISTEMA E AUDITORIA
-- ===================================================================================

-- 6.1. Log de Operações
CREATE TABLE dados_mapoteca.audit_log (
    id SERIAL PRIMARY KEY,
    tabela VARCHAR(50) NOT NULL,
    operacao VARCHAR(20) NOT NULL CHECK (operacao IN ('INSERT', 'UPDATE', 'DELETE')),
    id_registro UUID,
    valores_antigos JSONB,
    valores_novos JSONB,
    usuario VARCHAR(100),
    ip_address INET,
    user_agent TEXT,
    data_operacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE dados_mapoteca.audit_log IS 'Log de auditoria para todas as operações';

-- 6.2. Estatísticas de Acesso
CREATE TABLE dados_mapoteca.estatisticas_acesso (
    id SERIAL PRIMARY KEY,
    id_publicacao UUID REFERENCES dados_mapoteca.publicacoes(id) ON DELETE CASCADE,
    tipo_acesso VARCHAR(20) CHECK (tipo_acesso IN ('visualizacao', 'download', 'preview')),
    data_acesso TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address INET,
    user_agent TEXT,
    referer TEXT
);

COMMENT ON TABLE dados_mapoteca.estatisticas_acesso IS 'Estatísticas de acesso às publicações';

-- ===================================================================================
-- 7. VIEWS DE CONSULTA OTIMIZADAS
-- ===================================================================================

-- 7.1. View Principal de Publicações
CREATE OR REPLACE VIEW dados_mapoteca.v_publicacoes_completas AS
SELECT
    p.id,
    p.titulo,
    p.slug,
    p.descricao,
    p.resumo,
    p.autor,
    p.fonte,
    p.instituicao,
    p.publicado,
    p.destacado,
    p.downloads,
    p.visualizacoes,
    p.created_at,
    p.updated_at,

    -- Classes e Tipos
    cp.nome as classe_publicacao,
    tp.nome as tipo_publicacao,
    cp.codigo as codigo_classe,
    tp.codigo as codigo_tipo,

    -- Metadados
    a.ano,
    e.nome as escala,
    e.codigo as codigo_escala,
    c.nome as cor,
    c.codigo as codigo_cor,

    -- Arrays Relacionados
    COALESCE(
        ARRAY_AGG(DISTINCT t.nome) FILTER (WHERE t.nome IS NOT NULL),
        ARRAY[]::TEXT[]
    ) as temas_array,

    COALESCE(
        ARRAY_AGG(DISTINCT r.nome) FILTER (WHERE r.nome IS NOT NULL),
        ARRAY[]::TEXT[]
    ) as regioes_array,

    -- Controle de Anexos
    (SELECT COUNT(*) FROM dados_mapoteca.anexos an WHERE an.id_publicacao = p.id) as total_anexos,
    (SELECT COUNT(*) FROM dados_mapoteca.anexos an WHERE an.id_publicacao = p.id AND an.principal = true) as anexos_principais

FROM dados_mapoteca.publicacoes p
LEFT JOIN dados_mapoteca.classes_publicacao cp ON p.id_classe_publicacao = cp.id
LEFT JOIN dados_mapoteca.tipos_publicacao tp ON p.id_tipo_publicacao = tp.id
LEFT JOIN dados_mapoteca.anos a ON p.id_ano = a.id
LEFT JOIN dados_mapoteca.escalas e ON p.id_escala = e.id
LEFT JOIN dados_mapoteca.cores c ON p.id_cor = c.id
LEFT JOIN dados_mapoteca.publicacao_temas pt ON p.id = pt.id_publicacao
LEFT JOIN dados_mapoteca.temas t ON pt.id_tema = t.id
LEFT JOIN dados_mapoteca.publicacao_regioes pr ON p.id = pr.id_publicacao
LEFT JOIN dados_mapoteca.regioes r ON pr.id_regiao = r.id
GROUP BY p.id, cp.nome, tp.nome, cp.codigo, tp.codigo, a.ano, e.nome, e.codigo, c.nome, c.codigo;

COMMENT ON VIEW dados_mapoteca.v_publicacoes_completas IS 'View principal com todos os dados relacionais';

-- ===================================================================================
-- 8. RESUMO DA CRIAÇÃO
-- ===================================================================================

-- Schema criado com sucesso:
-- ✓ Schema: dados_mapoteca
-- ✓ 8 tabelas de domínio (lookup)
-- ✓ 1 tabela principal (publicacoes)
-- ✓ 2 tabelas de relacionamento (temas, regioes)
-- ✓ 1 tabela de anexos (ESRI integration)
-- ✓ 2 tabelas de sistema (audit, estatisticas)
-- ✓ 1 view otimizada de consulta

-- Total: 15 tabelas + 1 view principal

SELECT
    'dados_mapoteca' as schema_name,
    COUNT(*) as total_tables,
    (SELECT COUNT(*) FROM information_schema.views WHERE table_schema = 'dados_mapoteca') as total_views
FROM information_schema.tables
WHERE table_schema = 'dados_mapoteca';

-- Fim do Script 01
-- ===================================================================================