-- =====================================================
-- ESQUEMA DE BANCO DE DADOS POSTGRESQL 14+ PARA MAPOTECA
-- =====================================================
-- Criado a partir das planilhas Excel no diretório tabelas_base_mapoteca_digital/
-- Total de 13 tabelas: 9 principais + 3 de relacionamento + 1 principal
-- Padrão de nomes: t_ para todas as tabelas (compatível com nomes dos arquivos Excel)
-- =====================================================

-- Limpeza de objetos existentes (se necessário)
-- DROP SCHEMA IF EXISTS mapoteca CASCADE;
-- CREATE SCHEMA mapoteca;
-- SET search_path TO mapoteca, public;

-- =====================================================
-- TABELAS PRINCIPAIS/DIMENSIONAIS
-- =====================================================

-- 1. Tabela de classes de mapa
CREATE TABLE t_classe_mapa (
    id_classe_mapa VARCHAR(2) PRIMARY KEY,
    nome_classe_mapa VARCHAR(50) NOT NULL UNIQUE
);

-- 2. Tabela de tipos de mapa
CREATE TABLE t_tipo_mapa (
    id_tipo_mapa VARCHAR(2) PRIMARY KEY,
    nome_tipo_mapa VARCHAR(50) NOT NULL UNIQUE
);

-- 3. Tabela de regiões
CREATE TABLE t_regiao (
    id_regiao VARCHAR(3) PRIMARY KEY,
    nome_regiao VARCHAR(100) NOT NULL,
    abrangencia VARCHAR(20)
);

-- 4. Tabela de temas
CREATE TABLE t_tema (
    id_tema SERIAL PRIMARY KEY,
    codigo_tema VARCHAR(20) NOT NULL UNIQUE,
    nome_tema VARCHAR(200) NOT NULL
);

-- 5. Tabela de tipos de regionalização
CREATE TABLE t_tipo_regionalizacao (
    id_tipo_regionalizacao VARCHAR(2) PRIMARY KEY,
    nome_tipo_regionalizacao VARCHAR(100) NOT NULL UNIQUE
);

-- 6. Tabela de tipos de tema
CREATE TABLE t_tipo_tema (
    id_tipo_tema VARCHAR(2) PRIMARY KEY,
    codigo_tipo_tema VARCHAR(10) NOT NULL UNIQUE,
    nome_tipo_tema VARCHAR(50) NOT NULL
);

-- 7. Tabela de escalas
CREATE TABLE t_escala (
    codigo_escala VARCHAR(10) PRIMARY KEY,
    nome_escala VARCHAR(20) NOT NULL UNIQUE
);

-- 8. Tabela de cores
CREATE TABLE t_cor (
    codigo_cor VARCHAR(5) PRIMARY KEY,
    nome_cor VARCHAR(20) NOT NULL UNIQUE
);

-- 9. Tabela de anos
CREATE TABLE t_anos (
    id_ano VARCHAR(2) PRIMARY KEY,
    ano INTEGER NOT NULL UNIQUE CHECK (ano BETWEEN 1990 AND 2050)
);

-- =====================================================
-- TABELAS DE RELACIONAMENTO (N:M)
-- =====================================================

-- 10. Relacionamento entre classe e tipo de mapa
CREATE TABLE t_classe_mapa_tipo_mapa (
    id_classe_mapa VARCHAR(2) NOT NULL,
    id_tipo_mapa VARCHAR(2) NOT NULL,
    PRIMARY KEY (id_classe_mapa, id_tipo_mapa),
    FOREIGN KEY (id_classe_mapa) REFERENCES t_classe_mapa(id_classe_mapa) ON DELETE CASCADE,
    FOREIGN KEY (id_tipo_mapa) REFERENCES t_tipo_mapa(id_tipo_mapa) ON DELETE CASCADE
);

-- 11. Relacionamento entre tipo de regionalização e região
CREATE TABLE t_regionalizacao_regiao (
    id_tipo_regionalizacao VARCHAR(2) NOT NULL,
    id_regiao VARCHAR(3) NOT NULL,
    PRIMARY KEY (id_tipo_regionalizacao, id_regiao),
    FOREIGN KEY (id_tipo_regionalizacao) REFERENCES t_tipo_regionalizacao(id_tipo_regionalizacao) ON DELETE CASCADE,
    FOREIGN KEY (id_regiao) REFERENCES t_regiao(id_regiao) ON DELETE CASCADE
);

-- 12. Relacionamento entre tipo de tema e tema
CREATE TABLE t_tipo_tema_tema (
    id_tipo_tema VARCHAR(2) NOT NULL,
    id_tema INTEGER NOT NULL,
    PRIMARY KEY (id_tipo_tema, id_tema),
    FOREIGN KEY (id_tipo_tema) REFERENCES t_tipo_tema(id_tipo_tema) ON DELETE CASCADE,
    FOREIGN KEY (id_tema) REFERENCES t_tema(id_tema) ON DELETE CASCADE
);

-- =====================================================
-- TABELA PRINCIPAL DE MAPAS (CORAÇÃO DO SISTEMA)
-- =====================================================

-- 13. Tabela principal de mapas publicados
CREATE TABLE t_publicacao (
    -- Identificador principal
    id_publicacao SERIAL PRIMARY KEY,

    -- Classificação principal do mapa
    id_classe_mapa VARCHAR(2) NOT NULL,
    id_tipo_mapa VARCHAR(2) NOT NULL,

    -- Características temporais e espaciais
    id_ano VARCHAR(2) NOT NULL,
    id_regiao VARCHAR(3) NOT NULL,
    codigo_escala VARCHAR(10) NOT NULL,
    codigo_cor VARCHAR(5) NOT NULL,
    id_tipo_regionalizacao VARCHAR(2) NOT NULL,

    -- Classificação temática
    id_tema INTEGER NOT NULL,
    id_tipo_tema VARCHAR(2) NOT NULL,

    -- Foreign Keys para integridade referencial
    CONSTRAINT fk_t_publicacao_classe_mapa FOREIGN KEY (id_classe_mapa) REFERENCES t_classe_mapa(id_classe_mapa) ON DELETE RESTRICT,
    CONSTRAINT fk_t_publicacao_tipo_mapa FOREIGN KEY (id_tipo_mapa) REFERENCES t_tipo_mapa(id_tipo_mapa) ON DELETE RESTRICT,
    CONSTRAINT fk_t_publicacao_ano FOREIGN KEY (id_ano) REFERENCES t_anos(id_ano) ON DELETE RESTRICT,
    CONSTRAINT fk_t_publicacao_regiao FOREIGN KEY (id_regiao) REFERENCES t_regiao(id_regiao) ON DELETE RESTRICT,
    CONSTRAINT fk_t_publicacao_escala FOREIGN KEY (codigo_escala) REFERENCES t_escala(codigo_escala) ON DELETE RESTRICT,
    CONSTRAINT fk_t_publicacao_cor FOREIGN KEY (codigo_cor) REFERENCES t_cor(codigo_cor) ON DELETE RESTRICT,
    CONSTRAINT fk_t_publicacao_tema FOREIGN KEY (id_tema) REFERENCES t_tema(id_tema) ON DELETE RESTRICT,
    CONSTRAINT fk_t_publicacao_tipo_tema FOREIGN KEY (id_tipo_tema) REFERENCES t_tipo_tema(id_tipo_tema) ON DELETE RESTRICT,
    CONSTRAINT fk_t_publicacao_tipo_regionalizacao FOREIGN KEY (id_tipo_regionalizacao) REFERENCES t_tipo_regionalizacao(id_tipo_regionalizacao) ON DELETE RESTRICT
);

-- =====================================================
-- ÍNDICES PARA MELHORAR PERFORMANCE
-- =====================================================

-- Índices para tabelas principais
CREATE INDEX idx_t_classe_mapa_nome ON t_classe_mapa(nome_classe_mapa);
CREATE INDEX idx_t_tipo_mapa_nome ON t_tipo_mapa(nome_tipo_mapa);
CREATE INDEX idx_t_regiao_nome ON t_regiao(nome_regiao);
CREATE INDEX idx_t_regiao_abrangencia ON t_regiao(abrangencia) WHERE abrangencia IS NOT NULL;
CREATE INDEX idx_t_tema_codigo ON t_tema(codigo_tema);
CREATE INDEX idx_t_tema_nome ON t_tema(nome_tema);
CREATE INDEX idx_t_tipo_regionalizacao_nome ON t_tipo_regionalizacao(nome_tipo_regionalizacao);
CREATE INDEX idx_t_tipo_tema_codigo ON t_tipo_tema(codigo_tipo_tema);
CREATE INDEX idx_t_tipo_tema_nome ON t_tipo_tema(nome_tipo_tema);
CREATE INDEX idx_t_escala_nome ON t_escala(nome_escala);
CREATE INDEX idx_t_cor_nome ON t_cor(nome_cor);
CREATE INDEX idx_t_anos_valor ON t_anos(ano);

-- Índices para tabelas de relacionamento
CREATE INDEX idx_t_regionalizacao_regiao ON t_regionalizacao_regiao(id_regiao);
CREATE INDEX idx_t_tipo_tema_tema ON t_tipo_tema_tema(id_tema);

-- Índices para a tabela principal de publicações
CREATE INDEX idx_t_publicacao_classe_tipo ON t_publicacao(id_classe_mapa, id_tipo_mapa);
CREATE INDEX idx_t_publicacao_regiao_ano ON t_publicacao(id_regiao, id_ano);
CREATE INDEX idx_t_publicacao_tema_tipo ON t_publicacao(id_tema, id_tipo_tema);
CREATE INDEX idx_t_publicacao_escala_cor ON t_publicacao(codigo_escala, codigo_cor);
CREATE INDEX idx_t_publicacao_regionalizacao ON t_publicacao(id_tipo_regionalizacao);

-- =====================================================
-- VIEWS ÚTEIS PARA CONSULTAS
-- =====================================================

-- View para visualizar informações completas de temas com tipos
CREATE VIEW vw_t_tema_completo AS
SELECT
    t.id_tema,
    t.codigo_tema,
    t.nome_tema,
    tt.codigo_tipo_tema,
    tt.nome_tipo_tema
FROM t_tema t
JOIN t_tipo_tema_tema ttt ON t.id_tema = ttt.id_tema
JOIN t_tipo_tema tt ON ttt.id_tipo_tema = tt.id_tipo_tema;

-- View para visualizar regiões com seus tipos de regionalização
CREATE VIEW vw_t_regiao_completa AS
SELECT
    r.id_regiao,
    r.nome_regiao,
    r.abrangencia,
    tr.nome_tipo_regionalizacao
FROM t_regiao r
JOIN t_regionalizacao_regiao trr ON r.id_regiao = trr.id_regiao
JOIN t_tipo_regionalizacao tr ON trr.id_tipo_regionalizacao = tr.id_tipo_regionalizacao;

-- View para visualizar tipos de mapa com classes
CREATE VIEW vw_t_tipo_mapa_completo AS
SELECT
    tm.id_tipo_mapa,
    tm.nome_tipo_mapa,
    cm.id_classe_mapa,
    cm.nome_classe_mapa
FROM t_tipo_mapa tm
JOIN t_classe_mapa_tipo_mapa cmtm ON tm.id_tipo_mapa = cmtm.id_tipo_mapa
JOIN t_classe_mapa cm ON cmtm.id_classe_mapa = cm.id_classe_mapa;

-- View para visualizar informações completas das publicações
CREATE VIEW vw_t_publicacao_completa AS
SELECT
    p.id_publicacao,
    -- Classificação principal
    cm.nome_classe_mapa,
    tm.nome_tipo_mapa,
    -- Características temporais e espaciais
    a.ano,
    r.nome_regiao,
    r.abrangencia,
    e.nome_escala,
    cor.nome_cor,
    tr.nome_tipo_regionalizacao,
    -- Classificação temática
    t.codigo_tema,
    t.nome_tema,
    tt.codigo_tipo_tema,
    tt.nome_tipo_tema
FROM t_publicacao p
JOIN t_classe_mapa cm ON p.id_classe_mapa = cm.id_classe_mapa
JOIN t_tipo_mapa tm ON p.id_tipo_mapa = tm.id_tipo_mapa
JOIN t_anos a ON p.id_ano = a.id_ano
JOIN t_regiao r ON p.id_regiao = r.id_regiao
JOIN t_escala e ON p.codigo_escala = e.codigo_escala
JOIN t_cor cor ON p.codigo_cor = cor.codigo_cor
JOIN t_tipo_regionalizacao tr ON p.id_tipo_regionalizacao = tr.id_tipo_regionalizacao
JOIN t_tema t ON p.id_tema = t.id_tema
JOIN t_tipo_tema tt ON p.id_tipo_tema = tt.id_tipo_tema;

-- =====================================================
-- COMENTÁRIOS E DOCUMENTAÇÃO
-- =====================================================

COMMENT ON TABLE t_classe_mapa IS 'Tabela que armazena as classes de mapas (ex: Mapa, Cartograma)';
COMMENT ON TABLE t_tipo_mapa IS 'Tabela que armazena os tipos de mapas (ex: Estadual, Regional, Municipal)';
COMMENT ON TABLE t_regiao IS 'Tabela que armazena as regiões geográficas';
COMMENT ON TABLE t_tema IS 'Tabela que armazena os temas dos mapas';
COMMENT ON TABLE t_tipo_regionalizacao IS 'Tabela que armazena os tipos de regionalização';
COMMENT ON TABLE t_tipo_tema IS 'Tabela que armazena os tipos de temas';
COMMENT ON TABLE t_escala IS 'Tabela que armazena as escalas dos mapas';
COMMENT ON TABLE t_cor IS 'Tabela que armazena as cores dos mapas';
COMMENT ON TABLE t_anos IS 'Tabela que armazena os anos de referência dos mapas';
COMMENT ON TABLE t_classe_mapa_tipo_mapa IS 'Tabela de relacionamento N:M entre classe e tipo de mapa';
COMMENT ON TABLE t_regionalizacao_regiao IS 'Tabela de relacionamento N:M entre tipo de regionalização e região';
COMMENT ON TABLE t_tipo_tema_tema IS 'Tabela de relacionamento N:M entre tipo de tema e tema';
COMMENT ON TABLE t_publicacao IS 'Tabela principal que armazena todas as publicações de mapas com suas classificações completas';

-- =====================================================
-- ESTATÍSTICAS INICIAIS
-- =====================================================

-- Este schema foi criado com base em 12 planilhas Excel contendo:
-- - 2 classes de mapa
-- - 3 tipos de mapa
-- - 214 regiões
-- - 55 temas
-- - 11 tipos de regionalização
-- - 6 tipos de tema
-- - 9 escalas
-- - 2 cores
-- - 33 anos (1998-2030)
-- - 6 relacionamentos classe x tipo mapa
-- - 233 relacionamentos tipo regionalização x região
-- - 55 relacionamentos tipo tema x tema
--
-- + Tabela principal 'mapa' para armazenar os mapas publicados com todas as suas classificações

-- =====================================================
-- FINAL DO SCRIPT
-- =====================================================