-- =====================================================
-- ESQUEMA DE BANCO DE DADOS POSTGRESQL 14+ PARA MAPOTECA
-- =====================================================
-- Criado a partir das planilhas Excel no diretório excel/
-- Total de 12 tabelas: 9 principais + 3 de relacionamento
-- =====================================================

-- Limpeza de objetos existentes (se necessário)
-- DROP SCHEMA IF EXISTS mapoteca CASCADE;
-- CREATE SCHEMA mapoteca;
-- SET search_path TO mapoteca, public;

-- =====================================================
-- TABELAS PRINCIPAIS/DIMENSIONAIS
-- =====================================================

-- 1. Tabela de classes de mapa
CREATE TABLE classe_mapa (
    id_classe_mapa VARCHAR(2) PRIMARY KEY,
    nome_classe_mapa VARCHAR(50) NOT NULL UNIQUE
);

-- 2. Tabela de tipos de mapa
CREATE TABLE tipo_mapa (
    id_tipo_mapa VARCHAR(2) PRIMARY KEY,
    nome_tipo_mapa VARCHAR(50) NOT NULL UNIQUE
);

-- 3. Tabela de regiões
CREATE TABLE regiao (
    id_regiao VARCHAR(3) PRIMARY KEY,
    nome_regiao VARCHAR(100) NOT NULL,
    abrangencia VARCHAR(20)
);

-- 4. Tabela de temas
CREATE TABLE tema (
    id_tema SERIAL PRIMARY KEY,
    codigo_tema VARCHAR(20) NOT NULL UNIQUE,
    nome_tema VARCHAR(200) NOT NULL
);

-- 5. Tabela de tipos de regionalização
CREATE TABLE tipo_regionalizacao (
    id_tipo_regionalizacao VARCHAR(2) PRIMARY KEY,
    nome_tipo_regionalizacao VARCHAR(100) NOT NULL UNIQUE
);

-- 6. Tabela de tipos de tema
CREATE TABLE tipo_tema (
    id_tipo_tema VARCHAR(2) PRIMARY KEY,
    codigo_tipo_tema VARCHAR(10) NOT NULL UNIQUE,
    nome_tipo_tema VARCHAR(50) NOT NULL
);

-- 7. Tabela de escalas
CREATE TABLE escala (
    codigo_escala VARCHAR(10) PRIMARY KEY,
    nome_escala VARCHAR(20) NOT NULL UNIQUE
);

-- 8. Tabela de cores
CREATE TABLE cor (
    codigo_cor VARCHAR(5) PRIMARY KEY,
    nome_cor VARCHAR(20) NOT NULL UNIQUE
);

-- 9. Tabela de anos
CREATE TABLE ano (
    id_ano VARCHAR(2) PRIMARY KEY,
    ano INTEGER NOT NULL UNIQUE CHECK (ano BETWEEN 1990 AND 2050)
);

-- =====================================================
-- TABELAS DE RELACIONAMENTO (N:M)
-- =====================================================

-- 10. Relacionamento entre classe e tipo de mapa
CREATE TABLE classe_mapa_tipo_mapa (
    id_classe_mapa VARCHAR(2) NOT NULL,
    id_tipo_mapa VARCHAR(2) NOT NULL,
    PRIMARY KEY (id_classe_mapa, id_tipo_mapa),
    FOREIGN KEY (id_classe_mapa) REFERENCES classe_mapa(id_classe_mapa) ON DELETE CASCADE,
    FOREIGN KEY (id_tipo_mapa) REFERENCES tipo_mapa(id_tipo_mapa) ON DELETE CASCADE
);

-- 11. Relacionamento entre tipo de regionalização e região
CREATE TABLE tipo_regionalizacao_regiao (
    id_tipo_regionalizacao VARCHAR(2) NOT NULL,
    id_regiao VARCHAR(3) NOT NULL,
    PRIMARY KEY (id_tipo_regionalizacao, id_regiao),
    FOREIGN KEY (id_tipo_regionalizacao) REFERENCES tipo_regionalizacao(id_tipo_regionalizacao) ON DELETE CASCADE,
    FOREIGN KEY (id_regiao) REFERENCES regiao(id_regiao) ON DELETE CASCADE
);

-- 12. Relacionamento entre tipo de tema e tema
CREATE TABLE tipo_tema_tema (
    id_tipo_tema VARCHAR(2) NOT NULL,
    id_tema INTEGER NOT NULL,
    PRIMARY KEY (id_tipo_tema, id_tema),
    FOREIGN KEY (id_tipo_tema) REFERENCES tipo_tema(id_tipo_tema) ON DELETE CASCADE,
    FOREIGN KEY (id_tema) REFERENCES tema(id_tema) ON DELETE CASCADE
);

-- =====================================================
-- TABELA PRINCIPAL DE MAPAS (CORAÇÃO DO SISTEMA)
-- =====================================================

-- 13. Tabela principal de mapas publicados
CREATE TABLE mapa (
    -- Identificador principal
    id_mapa SERIAL PRIMARY KEY,

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
    CONSTRAINT fk_mapa_classe_mapa FOREIGN KEY (id_classe_mapa) REFERENCES classe_mapa(id_classe_mapa) ON DELETE RESTRICT,
    CONSTRAINT fk_mapa_tipo_mapa FOREIGN KEY (id_tipo_mapa) REFERENCES tipo_mapa(id_tipo_mapa) ON DELETE RESTRICT,
    CONSTRAINT fk_mapa_ano FOREIGN KEY (id_ano) REFERENCES ano(id_ano) ON DELETE RESTRICT,
    CONSTRAINT fk_mapa_regiao FOREIGN KEY (id_regiao) REFERENCES regiao(id_regiao) ON DELETE RESTRICT,
    CONSTRAINT fk_mapa_escala FOREIGN KEY (codigo_escala) REFERENCES escala(codigo_escala) ON DELETE RESTRICT,
    CONSTRAINT fk_mapa_cor FOREIGN KEY (codigo_cor) REFERENCES cor(codigo_cor) ON DELETE RESTRICT,
    CONSTRAINT fk_mapa_tema FOREIGN KEY (id_tema) REFERENCES tema(id_tema) ON DELETE RESTRICT,
    CONSTRAINT fk_mapa_tipo_tema FOREIGN KEY (id_tipo_tema) REFERENCES tipo_tema(id_tipo_tema) ON DELETE RESTRICT,
    CONSTRAINT fk_mapa_tipo_regionalizacao FOREIGN KEY (id_tipo_regionalizacao) REFERENCES tipo_regionalizacao(id_tipo_regionalizacao) ON DELETE RESTRICT
);

-- =====================================================
-- ÍNDICES PARA MELHORAR PERFORMANCE
-- =====================================================

-- Índices para tabelas principais
CREATE INDEX idx_classe_mapa_nome ON classe_mapa(nome_classe_mapa);
CREATE INDEX idx_tipo_mapa_nome ON tipo_mapa(nome_tipo_mapa);
CREATE INDEX idx_regiao_nome ON regiao(nome_regiao);
CREATE INDEX idx_regiao_abrangencia ON regiao(abrangencia) WHERE abrangencia IS NOT NULL;
CREATE INDEX idx_tema_codigo ON tema(codigo_tema);
CREATE INDEX idx_tema_nome ON tema(nome_tema);
CREATE INDEX idx_tipo_regionalizacao_nome ON tipo_regionalizacao(nome_tipo_regionalizacao);
CREATE INDEX idx_tipo_tema_codigo ON tipo_tema(codigo_tipo_tema);
CREATE INDEX idx_tipo_tema_nome ON tipo_tema(nome_tipo_tema);
CREATE INDEX idx_escala_nome ON escala(nome_escala);
CREATE INDEX idx_cor_nome ON cor(nome_cor);
CREATE INDEX idx_ano_valor ON ano(ano);

-- Índices para tabelas de relacionamento
CREATE INDEX idx_tipo_reg_regiao ON tipo_regionalizacao_regiao(id_regiao);
CREATE INDEX idx_tipo_tema_tema_tema ON tipo_tema_tema(id_tema);

-- Índices para a tabela principal de mapas
CREATE INDEX idx_mapa_classe_tipo ON mapa(id_classe_mapa, id_tipo_mapa);
CREATE INDEX idx_mapa_regiao_ano ON mapa(id_regiao, id_ano);
CREATE INDEX idx_mapa_tema_tipo ON mapa(id_tema, id_tipo_tema);
CREATE INDEX idx_mapa_escala_cor ON mapa(codigo_escala, codigo_cor);
CREATE INDEX idx_mapa_regionalizacao ON mapa(id_tipo_regionalizacao);

-- =====================================================
-- VIEWS ÚTEIS PARA CONSULTAS
-- =====================================================

-- View para visualizar informações completas de temas com tipos
CREATE VIEW vw_tema_completo AS
SELECT
    t.id_tema,
    t.codigo_tema,
    t.nome_tema,
    tt.codigo_tipo_tema,
    tt.nome_tipo_tema
FROM tema t
JOIN tipo_tema_tema ttt ON t.id_tema = ttt.id_tema
JOIN tipo_tema tt ON ttt.id_tipo_tema = tt.id_tipo_tema;

-- View para visualizar regiões com seus tipos de regionalização
CREATE VIEW vw_regiao_completa AS
SELECT
    r.id_regiao,
    r.nome_regiao,
    r.abrangencia,
    tr.nome_tipo_regionalizacao
FROM regiao r
JOIN tipo_regionalizacao_regiao trr ON r.id_regiao = trr.id_regiao
JOIN tipo_regionalizacao tr ON trr.id_tipo_regionalizacao = tr.id_tipo_regionalizacao;

-- View para visualizar tipos de mapa com classes
CREATE VIEW vw_tipo_mapa_completo AS
SELECT
    tm.id_tipo_mapa,
    tm.nome_tipo_mapa,
    cm.id_classe_mapa,
    cm.nome_classe_mapa
FROM tipo_mapa tm
JOIN classe_mapa_tipo_mapa cmtm ON tm.id_tipo_mapa = cmtm.id_tipo_mapa
JOIN classe_mapa cm ON cmtm.id_classe_mapa = cm.id_classe_mapa;

-- View para visualizar informações completas dos mapas
CREATE VIEW vw_mapa_completo AS
SELECT
    m.id_mapa,
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
FROM mapa m
JOIN classe_mapa cm ON m.id_classe_mapa = cm.id_classe_mapa
JOIN tipo_mapa tm ON m.id_tipo_mapa = tm.id_tipo_mapa
JOIN ano a ON m.id_ano = a.id_ano
JOIN regiao r ON m.id_regiao = r.id_regiao
JOIN escala e ON m.codigo_escala = e.codigo_escala
JOIN cor cor ON m.codigo_cor = cor.codigo_cor
JOIN tipo_regionalizacao tr ON m.id_tipo_regionalizacao = tr.id_tipo_regionalizacao
JOIN tema t ON m.id_tema = t.id_tema
JOIN tipo_tema tt ON m.id_tipo_tema = tt.id_tipo_tema;

-- =====================================================
-- COMENTÁRIOS E DOCUMENTAÇÃO
-- =====================================================

COMMENT ON TABLE classe_mapa IS 'Tabela que armazena as classes de mapas (ex: Mapa, Cartograma)';
COMMENT ON TABLE tipo_mapa IS 'Tabela que armazena os tipos de mapas (ex: Estadual, Regional, Municipal)';
COMMENT ON TABLE regiao IS 'Tabela que armazena as regiões geográficas';
COMMENT ON TABLE tema IS 'Tabela que armazena os temas dos mapas';
COMMENT ON TABLE tipo_regionalizacao IS 'Tabela que armazena os tipos de regionalização';
COMMENT ON TABLE tipo_tema IS 'Tabela que armazena os tipos de temas';
COMMENT ON TABLE escala IS 'Tabela que armazena as escalas dos mapas';
COMMENT ON TABLE cor IS 'Tabela que armazena as cores dos mapas';
COMMENT ON TABLE ano IS 'Tabela que armazena os anos de referência dos mapas';
COMMENT ON TABLE classe_mapa_tipo_mapa IS 'Tabela de relacionamento N:M entre classe e tipo de mapa';
COMMENT ON TABLE tipo_regionalizacao_regiao IS 'Tabela de relacionamento N:M entre tipo de regionalização e região';
COMMENT ON TABLE tipo_tema_tema IS 'Tabela de relacionamento N:M entre tipo de tema e tema';
COMMENT ON TABLE mapa IS 'Tabela principal que armazena todos os mapas publicados com suas classificações completas';

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