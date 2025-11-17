# Redesenho da Arquitetura de Dados - Mapoteca Digital

## Sumário Executivo

Este documento apresenta uma proposta completa de redesenho da arquitetura de dados para o Sistema Mapoteca Digital, abordando os problemas identificados na estrutura atual e propondo soluções modernas, normalizadas e escaláveis para gerenciamento de publicações cartográficas.

**Data:** 10 de Novembro de 2025
**Versão:** 1.0
**Autor:** Arquiteto de Dados
**Status:** Proposta

---

## 1. Análise da Situação Atual

### 1.1 Problemas Identificados

#### Problemas Críticos:
1. **Redundância de Dados**: A tabela `t_tipo_tema.md` contém múltiplas linhas duplicadas para os mesmos tipos de tema
2. **Inconsistência em Nomenclatura**: Mistura de português, abreviações e diferentes padrões de naming
3. **Relacionamentos Muitos-para-Muitos**: Sem modelagem adequada de tabelas de junção
4. **Falta de Normalização**: Dados não seguem as formas normais do banco de dados
5. **Tipos de Dados Inadequados**: Ausência de definições de tipos e restrições apropriadas
6. **Separação Incorreta**: Dados de lookup misturados com dados transacionais

#### Problemas de Escalabilidade:
1. **Performance**: Consultas ineficientes devido à falta de índices adequados
2. **Manutenibilidade**: Estrutura complexa e difícil de manter
3. **Integridade**: Falta de constraints e validações
4. **Documentação**: Ausência de documentação estruturada

### 1.2 Estrutura Atual

#### Entidades Principais Identificadas:
- **Temas**: 55 tópicos de cartografia a socioeconômico
- **Tipos de Temas**: 6 categorias (cart, padm, fisamb, reg, soc, infra)
- **Classes de Mapas**: Mapa, Cartograma
- **Tipos de Mapa**: Estadual, Regional, Municipal
- **Regiões**: 215+ regiões com diversos relacionamentos hierárquicos
- **Tipos de Regionalização**: 11 tipos diferentes
- **Anos**: Período de 1998-2030
- **Cores**: cor, pb
- **Escalas**: Variadas escalas cartográficas

#### Relacionamentos Complexos:
- Muitos-para-muitos entre Tipos de Temas e Temas
- Muitos-para-muitos entre Tipos de Regionalização e Regiões
- Muitos-para-muitos entre Classes de Mapas e Tipos de Mapa

---

## 2. Proposta de Nova Arquitetura

### 2.1 Princípios de Design

1. **Normalização**: Aplicação das Formas Normais até 3FN
2. **Consistência**: Convenções de nomenclatura padronizadas
3. **Performance**: Índices otimizados para consultas geográficas
4. **Escalabilidade**: Estrutura que suporte crescimento de dados
5. **Integridade**: Constraints e validações robustas
6. **Documentação**: Metadados completos e documentação integrada

### 2.2 Convenções de Nomenclatura

#### Padrões Adotados:
- **Tabelas**: snake_case com prefixo `mapoteca_`
- **Colunas**: snake_case descritivo
- **Chaves Primárias**: `id_{tabela}`
- **Chaves Estrangeiras**: `id_{tabela_referenciada}`
- **Índices**: `idx_{tabela}_{coluna(s)}`
- **Constraints**: `ck_{tabela}_{regra}`
- **Triggers**: `trg_{tabela}_{acao}`

#### Exemplos:
```sql
-- Tabelas
mapoteca_tipo_tema
mapoteca_tema
mapoteca_publicacao
mapoteca_anexo_pdf

-- Colunas
id_tipo_tema
nome_tipo_tema
data_criacao
usuario_atualizacao

-- Índices
idx_mapoteca_tema_id_tipo_tema
idx_mapoteca_publicacao_ano_tema
```

### 2.3 Modelo de Dados Proposto

#### Schema Principal:

```sql
-- Schema da Mapoteca Digital
CREATE SCHEMA IF NOT EXISTS mapoteca;
COMMENT ON SCHEMA mapoteca IS 'Schema principal do Sistema Mapoteca Digital';
```

---

## 3. Estrutura Detalhada das Tabelas

### 3.1 Tabelas de Domínio (Lookup)

#### 3.1.1 Tipos de Tema
```sql
CREATE TABLE mapoteca.mapoteca_tipo_tema (
    id_tipo_tema SERIAL PRIMARY KEY,
    codigo_tipo_tema VARCHAR(10) UNIQUE NOT NULL,
    nome_tipo_tema VARCHAR(100) NOT NULL,
    descricao_tipo_tema TEXT,
    ordem_exibicao INTEGER DEFAULT 0,
    ativo BOOLEAN DEFAULT true,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_criacao VARCHAR(100) NOT NULL,
    usuario_atualizacao VARCHAR(100),

    CONSTRAINT ck_tipo_tema_codigo
        CHECK (codigo_tipo_tema ~ '^[a-z0-9_]+$'),
    CONSTRAINT ck_tipo_tema_ordem
        CHECK (ordem_exibicao >= 0)
);

COMMENT ON TABLE mapoteca.mapoteca_tipo_tema IS 'Tipos de temas cartográficos';
COMMENT ON COLUMN mapoteca.mapoteca_tipo_tema.codigo_tipo_tema IS 'Código único de identificação do tipo de tema';
COMMENT ON COLUMN mapoteca.mapoteca_tipo_tema.nome_tipo_tema IS 'Nome descritivo do tipo de tema';

-- Índices
CREATE INDEX idx_mapoteca_tipo_tema_codigo ON mapoteca.mapoteca_tipo_tema(codigo_tipo_tema);
CREATE INDEX idx_mapoteca_tipo_tema_ativo ON mapoteca.mapoteca_tipo_tema(ativo);
CREATE INDEX idx_mapoteca_tipo_tema_ordem ON mapoteca.mapoteca_tipo_tema(ordem_exibicao);

-- Dados iniciais
INSERT INTO mapoteca.mapoteca_tipo_tema (codigo_tipo_tema, nome_tipo_tema, descricao_tipo_tema, ordem_exibicao) VALUES
('cartografia', 'Cartografia', 'Mapas base e referências cartográficas', 1),
('politico_administrativo', 'Político-Administrativo', 'Divisões políticas e administrativas', 2),
('fisico_ambiental', 'Físico-Ambiental', 'Aspectos físicos e ambientais', 3),
('regionalizacao', 'Regionalização', 'Diferentes tipos de regionalização', 4),
('socioeconomico', 'Socioeconômico', 'Indicadores e dados socioeconômicos', 5),
('infraestrutura', 'Infraestrutura', 'Infraestrutura e equipamentos', 6);
```

#### 3.1.2 Temas
```sql
CREATE TABLE mapoteca.mapoteca_tema (
    id_tema SERIAL PRIMARY KEY,
    id_tipo_tema INTEGER NOT NULL REFERENCES mapoteca.mapoteca_tipo_tema(id_tipo_tema),
    codigo_tema VARCHAR(20) UNIQUE NOT NULL,
    nome_tema VARCHAR(200) NOT NULL,
    descricao_tema TEXT,
    ordem_exibicao INTEGER DEFAULT 0,
    ativo BOOLEAN DEFAULT true,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_criacao VARCHAR(100) NOT NULL,
    usuario_atualizacao VARCHAR(100),

    CONSTRAINT ck_tema_codigo
        CHECK (codigo_tema ~ '^[a-z0-9_]+$'),
    CONSTRAINT ck_tema_ordem
        CHECK (ordem_exibicao >= 0)
);

COMMENT ON TABLE mapoteca.mapoteca_tema IS 'Temas específicos de publicações cartográficas';
COMMENT ON COLUMN mapoteca.mapoteca_tema.codigo_tema IS 'Código único do tema';
COMMENT ON COLUMN mapoteca.mapoteca_tema.nome_tema IS 'Nome descritivo do tema';

-- Índices
CREATE INDEX idx_mapoteca_tema_codigo ON mapoteca.mapoteca_tema(codigo_tema);
CREATE INDEX idx_mapoteca_tema_id_tipo_tema ON mapoteca.mapoteca_tema(id_tipo_tema);
CREATE INDEX idx_mapoteca_tema_ativo ON mapoteca.mapoteca_tema(ativo);
CREATE INDEX idx_mapoteca_tema_tipo_ordem ON mapoteca.mapoteca_tema(id_tipo_tema, ordem_exibicao);

-- Trigger para atualização de timestamp
CREATE OR REPLACE FUNCTION mapoteca.fn_atualizar_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_atualizacao = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_tema_atualizacao
    BEFORE UPDATE ON mapoteca.mapoteca_tema
    FOR EACH ROW EXECUTE FUNCTION mapoteca.fn_atualizar_timestamp();
```

#### 3.1.3 Classes de Publicação
```sql
CREATE TABLE mapoteca.mapoteca_classe_publicacao (
    id_classe_publicacao SERIAL PRIMARY KEY,
    codigo_classe VARCHAR(20) UNIQUE NOT NULL,
    nome_classe VARCHAR(50) NOT NULL,
    descricao_classe TEXT,
    ativo BOOLEAN DEFAULT true,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_criacao VARCHAR(100) NOT NULL,

    CONSTRAINT ck_classe_publicacao_codigo
        CHECK (codigo_classe ~ '^[a-z0-9_]+$')
);

COMMENT ON TABLE mapoteca.mapoteca_classe_publicacao IS 'Classes de publicações cartográficas';

-- Dados iniciais
INSERT INTO mapoteca.mapoteca_classe_publicacao (codigo_classe, nome_classe, descricao_classe) VALUES
('mapa', 'Mapa', 'Representação cartográfica tradicional'),
('cartograma', 'Cartograma', 'Representação gráfica de dados estatísticos');
```

#### 3.1.4 Tipos de Publicação
```sql
CREATE TABLE mapoteca.mapoteca_tipo_publicacao (
    id_tipo_publicacao SERIAL PRIMARY KEY,
    codigo_tipo VARCHAR(20) UNIQUE NOT NULL,
    nome_tipo VARCHAR(50) NOT NULL,
    descricao_tipo TEXT,
    abrangencia_espacial VARCHAR(50),
    ativo BOOLEAN DEFAULT true,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_criacao VARCHAR(100) NOT NULL,

    CONSTRAINT ck_tipo_publicacao_codigo
        CHECK (codigo_tipo ~ '^[a-z0-9_]+$')
);

COMMENT ON TABLE mapoteca.mapoteca_tipo_publicacao IS 'Tipos de publicação por abrangência espacial';

-- Dados iniciais
INSERT INTO mapoteca.mapoteca_tipo_publicacao (codigo_tipo, nome_tipo, descricao_tipo, abrangencia_espacial) VALUES
('estadual', 'Estadual', 'Publicações com abrangência estadual', 'estado'),
('regional', 'Regional', 'Publicações com abrangência regional', 'regiao'),
('municipal', 'Municipal', 'Publicações com abrangência municipal', 'municipio');
```

#### 3.1.5 Regionalizações
```sql
CREATE TABLE mapoteca.mapoteca_tipo_regionalizacao (
    id_tipo_regionalizacao SERIAL PRIMARY KEY,
    codigo_tipo VARCHAR(20) UNIQUE NOT NULL,
    nome_tipo VARCHAR(100) NOT NULL,
    descricao_tipo TEXT,
    esfera_governo VARCHAR(50),
    ativo BOOLEAN DEFAULT true,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_criacao VARCHAR(100) NOT NULL,

    CONSTRAINT ck_tipo_regionalizacao_codigo
        CHECK (codigo_tipo ~ '^[a-z0-9_]+$')
);

COMMENT ON TABLE mapoteca.mapoteca_tipo_regionalizacao IS 'Tipos de regionalização existentes';

-- Regiões
CREATE TABLE mapoteca.mapoteca_regiao (
    id_regiao SERIAL PRIMARY KEY,
    codigo_regiao VARCHAR(20) UNIQUE NOT NULL,
    nome_regiao VARCHAR(200) NOT NULL,
    nome_normalizado VARCHAR(200) NOT NULL,
    abrangencia VARCHAR(100),
    ativo BOOLEAN DEFAULT true,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_criacao VARCHAR(100) NOT NULL,

    CONSTRAINT ck_regiao_codigo
        CHECK (codigo_regiao ~ '^[a-z0-9_]+$')
);

COMMENT ON TABLE mapoteca.mapoteca_regiao IS 'Regiões geográficas e administrativas';

-- Relacionamento M-N entre Regionalizações e Regiões
CREATE TABLE mapoteca.mapoteca_regiao_regionalizacao (
    id_regiao INTEGER NOT NULL REFERENCES mapoteca.mapoteca_regiao(id_regiao),
    id_tipo_regionalizacao INTEGER NOT NULL REFERENCES mapoteca.mapoteca_tipo_regionalizacao(id_tipo_regionalizacao),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_criacao VARCHAR(100) NOT NULL,

    PRIMARY KEY (id_regiao, id_tipo_regionalizacao)
);

COMMENT ON TABLE mapoteca.mapoteca_regiao_regionalizacao IS 'Relacionamento entre regiões e tipos de regionalização';
```

#### 3.1.6 Tabelas Auxiliares
```sql
-- Cores
CREATE TABLE mapoteca.mapoteca_cor (
    id_cor SERIAL PRIMARY KEY,
    codigo_cor VARCHAR(20) UNIQUE NOT NULL,
    nome_cor VARCHAR(50) NOT NULL,
    descricao_cor TEXT,
    valor_hex VARCHAR(7),
    ativo BOOLEAN DEFAULT true,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_criacao VARCHAR(100) NOT NULL,

    CONSTRAINT ck_cor_codigo
        CHECK (codigo_cor ~ '^[a-z0-9_]+$'),
    CONSTRAINT ck_cor_hex
        CHECK (valor_hex ~ '^#[0-9A-Fa-f]{6}$' OR valor_hex IS NULL)
);

-- Escalas
CREATE TABLE mapoteca.mapoteca_escala (
    id_escala SERIAL PRIMARY KEY,
    codigo_escala VARCHAR(20) UNIQUE NOT NULL,
    nome_escala VARCHAR(100) NOT NULL,
    denominacao VARCHAR(50),
    valor_escala INTEGER,
    ativo BOOLEAN DEFAULT true,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_criacao VARCHAR(100) NOT NULL,

    CONSTRAINT ck_escala_codigo
        CHECK (codigo_escala ~ '^[a-z0-9_]+$'),
    CONSTRAINT ck_escala_valor
        CHECK (valor_escala > 0)
);

-- Anos de Referência
CREATE TABLE mapoteca.mapoteca_ano_referencia (
    id_ano SERIAL PRIMARY KEY,
    ano INTEGER UNIQUE NOT NULL,
    descricao TEXT,
    ativo BOOLEAN DEFAULT true,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_criacao VARCHAR(100) NOT NULL,

    CONSTRAINT ck_ano_valor
        CHECK (ano BETWEEN 1900 AND 2100)
);
```

### 3.2 Tabelas de Negócio

#### 3.2.1 Publicações
```sql
-- Tabela principal de publicações
CREATE TABLE mapoteca.mapoteca_publicacao (
    id_publicacao SERIAL PRIMARY KEY,
    id_classe_publicacao INTEGER NOT NULL REFERENCES mapoteca.mapoteca_classe_publicacao(id_classe_publicacao),
    id_tipo_publicacao INTEGER NOT NULL REFERENCES mapoteca.mapoteca_tipo_publicacao(id_tipo_publicacao),
    id_tema INTEGER NOT NULL REFERENCES mapoteca.mapoteca_tema(id_tema),
    id_regiao INTEGER REFERENCES mapoteca.mapoteca_regiao(id_regiao),
    id_escala INTEGER REFERENCES mapoteca.mapoteca_escala(id_escala),
    id_cor INTEGER REFERENCES mapoteca.mapoteca_cor(id_cor),
    id_ano_referencia INTEGER REFERENCES mapoteca.mapoteca_ano_referencia(id_ano_referencia),

    titulo VARCHAR(500) NOT NULL,
    subtitulo VARCHAR(500),
    descricao TEXT,
    palavras_chave TEXT,

    -- Metadados
    fonte_dados VARCHAR(300),
    metodologia TEXT,
    coordenacao VARCHAR(200),
    equipe_elaboracao TEXT,

    -- Controle
    status VARCHAR(20) DEFAULT 'rascunho' NOT NULL,
    data_publicacao DATE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_criacao VARCHAR(100) NOT NULL,
    usuario_atualizacao VARCHAR(100),
    data_aprovacao TIMESTAMP,
    usuario_aprovacao VARCHAR(100),

    -- Constraints de status
    CONSTRAINT ck_publicacao_status
        CHECK (status IN ('rascunho', 'revisao', 'aprovado', 'publicado', 'arquivado')),
    CONSTRAINT ck_publicacao_regiao_obrigatoria
        CHECK ((id_tipo_publicacao = (SELECT id_tipo_publicacao FROM mapoteca.mapoteca_tipo_publicacao WHERE codigo_tipo = 'regional'))
               = (id_regiao IS NOT NULL))
);

COMMENT ON TABLE mapoteca.mapoteca_publicacao IS 'Tabela principal de publicações cartográficas';

-- Índices de performance
CREATE INDEX idx_mapoteca_publicacao_titulo ON mapoteca.mapoteca_publicacao(titulo);
CREATE INDEX idx_mapoteca_publicacao_status ON mapoteca.mapoteca_publicacao(status);
CREATE INDEX idx_mapoteca_publicacao_classe ON mapoteca.mapoteca_publicacao(id_classe_publicacao);
CREATE INDEX idx_mapoteca_publicacao_tipo ON mapoteca.mapoteca_publicacao(id_tipo_publicacao);
CREATE INDEX idx_mapoteca_publicacao_tema ON mapoteca.mapoteca_publicacao(id_tema);
CREATE INDEX idx_mapoteca_publicacao_ano ON mapoteca.mapoteca_publicacao(id_ano_referencia);
CREATE INDEX idx_mapoteca_publicacao_busca ON mapoteca.mapoteca_publicacao USING gin(to_tsvector('portuguese', titulo || ' ' || COALESCE(descricao, '') || ' ' || COALESCE(palavras_chave, '')));

-- Trigger para atualização
CREATE TRIGGER trg_publicacao_atualizacao
    BEFORE UPDATE ON mapoteca.mapoteca_publicacao
    FOR EACH ROW EXECUTE FUNCTION mapoteca.fn_atualizar_timestamp();
```

#### 3.2.2 Anexos PDF (ESRI Attachments Integration)
```sql
CREATE TABLE mapoteca.mapoteca_anexo_pdf (
    id_anexo SERIAL PRIMARY KEY,
    id_publicacao INTEGER NOT NULL REFERENCES mapoteca.mapoteca_publicacao(id_publicacao) ON DELETE CASCADE,

    -- Metadados do arquivo
    nome_arquivo VARCHAR(500) NOT NULL,
    nome_original VARCHAR(500),
    tamanho_arquivo BIGINT NOT NULL,
    tipo_mime VARCHAR(100) DEFAULT 'application/pdf',
    hash_arquivo VARCHAR(64) NOT NULL,

    -- Armazenamento binário (ESRI Attachments)
    dados_binarios BYTEA,
    global_id UUID DEFAULT gen_random_uuid() UNIQUE,

    -- Metadados para busca
    palavras_chave TEXT,
    texto_extraido TEXT,

    -- Controle
    data_upload TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_ultima_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_upload VARCHAR(100) NOT NULL,
    status VARCHAR(20) DEFAULT 'ativo' NOT NULL,

    -- Constraints
    CONSTRAINT ck_anexo_status
        CHECK (status IN ('ativo', 'inativo', 'erro', 'processando')),
    CONSTRAINT ck_anexo_tamanho
        CHECK (tamanho_arquivo > 0),
    CONSTRAINT ck_anexo_hash
        CHECK (length(hash_arquivo) = 64)
);

COMMENT ON TABLE mapoteca.mapoteca_anexo_pdf IS 'Armazenamento de anexos PDF usando ESRI Attachments';

-- Índices para performance
CREATE INDEX idx_mapoteca_anexo_id_publicacao ON mapoteca.mapoteca_anexo_pdf(id_publicacao);
CREATE INDEX idx_mapoteca_anexo_hash ON mapoteca.mapoteca_anexo_pdf(hash_arquivo);
CREATE INDEX idx_mapoteca_anexo_busca ON mapoteca.mapoteca_anexo_pdf USING gin(to_tsvector('portuguese', COALESCE(palavras_chave, '') || ' ' || COALESCE(texto_extraido, '') || ' ' || nome_arquivo));
CREATE UNIQUE INDEX idx_mapoteca_anexo_global_id ON mapoteca.mapoteca_anexo_pdf(global_id);

-- Função para inserção de anexo
CREATE OR REPLACE FUNCTION mapoteca.fn_inserir_anexo_pdf(
    p_id_publicacao INTEGER,
    p_nome_arquivo VARCHAR(500),
    p_dados_binarios BYTEA,
    p_usuario VARCHAR(100),
    p_palavras_chave TEXT DEFAULT NULL
) RETURNS INTEGER AS $$
DECLARE
    v_id_anexo INTEGER;
    v_tamanho BIGINT;
    v_hash VARCHAR(64);
BEGIN
    -- Calcular tamanho e hash
    v_tamanho := octet_length(p_dados_binarios);
    v_hash := encode(sha256(p_dados_binarios), 'hex');

    -- Inserir anexo
    INSERT INTO mapoteca.mapoteca_anexo_pdf (
        id_publicacao, nome_arquivo, nome_original, tamanho_arquivo,
        dados_binarios, hash_arquivo, palavras_chave, usuario_upload
    ) VALUES (
        p_id_publicacao, p_nome_arquivo, p_nome_arquivo, v_tamanho,
        p_dados_binarios, v_hash, p_palavras_chave, p_usuario
    ) RETURNING id_anexo INTO v_id_anexo;

    RETURN v_id_anexo;
END;
$$ LANGUAGE plpgsql;
```

#### 3.2.3 Histórico de Auditoria
```sql
CREATE TABLE mapoteca.mapoteca_historico_auditoria (
    id_historico SERIAL PRIMARY KEY,
    tabela_origem VARCHAR(100) NOT NULL,
    id_registro INTEGER NOT NULL,
    tipo_operacao VARCHAR(20) NOT NULL,

    dados_anteriores JSONB,
    dados_novos JSONB,

    campo_modificado VARCHAR(100),
    valor_antigo TEXT,
    valor_novo TEXT,

    usuario_operacao VARCHAR(100) NOT NULL,
    data_operacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_origem VARCHAR(45),
    user_agent TEXT,

    -- Constraints
    CONSTRAINT ck_historico_operacao
        CHECK (tipo_operacao IN ('INSERT', 'UPDATE', 'DELETE', 'APPROVE', 'PUBLISH', 'ARCHIVE'))
);

COMMENT ON TABLE mapoteca.mapoteca_historico_auditoria IS 'Histórico de auditoria de todas as operações';

-- Índices
CREATE INDEX idx_mapoteca_historico_tabela_registro ON mapoteca.mapoteca_historico_auditoria(tabela_origem, id_registro);
CREATE INDEX idx_mapoteca_historico_data ON mapoteca.mapoteca_historico_auditoria(data_operacao);
CREATE INDEX idx_mapoteca_historico_usuario ON mapoteca.mapoteca_historico_auditoria(usuario_operacao);

-- Função de trigger para auditoria
CREATE OR REPLACE FUNCTION mapoteca.fn_trigger_auditoria()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO mapoteca.mapoteca_historico_auditoria (
            tabela_origem, id_registro, tipo_operacao, dados_novos, usuario_operacao
        ) VALUES (
            TG_TABLE_NAME, NEW.id_publicacao, 'INSERT', row_to_json(NEW), current_user
        );
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO mapoteca.mapoteca_historico_auditoria (
            tabela_origem, id_registro, tipo_operacao, dados_anteriores, dados_novos, usuario_operacao
        ) VALUES (
            TG_TABLE_NAME, NEW.id_publicacao, 'UPDATE', row_to_json(OLD), row_to_json(NEW), current_user
        );
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO mapoteca.mapoteca_historico_auditoria (
            tabela_origem, id_registro, tipo_operacao, dados_anteriores, usuario_operacao
        ) VALUES (
            TG_TABLE_NAME, OLD.id_publicacao, 'DELETE', row_to_json(OLD), current_user
        );
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger na tabela de publicações
CREATE TRIGGER trg_publicacao_auditoria
    AFTER INSERT OR UPDATE OR DELETE ON mapoteca.mapoteca_publicacao
    FOR EACH ROW EXECUTE FUNCTION mapoteca.fn_trigger_auditoria();
```

---

## 4. Views e Consultas Otimizadas

### 4.1 Views para Interface

#### 4.1.1 View de Publicações Completas
```sql
CREATE OR REPLACE VIEW mapoteca.vw_publicacoes_completas AS
SELECT
    p.id_publicacao,
    p.titulo,
    p.subtitulo,
    p.descricao,
    p.palavras_chave,
    p.data_publicacao,
    p.status,

    -- Dados relacionados
    cp.nome_classe AS classe_publicacao,
    tp.nome_tipo AS tipo_publicacao,
    t.nome_tema AS tema,
    tt.nome_tipo_tema AS tipo_tema,
    r.nome_regiao AS regiao,
    e.nome_escala AS escala,
    c.nome_cor AS cor,
    ar.ano AS ano_referencia,

    -- Controle
    p.data_criacao,
    p.usuario_criacao,
    p.data_atualizacao,
    p.usuario_atualizacao,

    -- Anexos
    (SELECT COUNT(*) FROM mapoteca.mapoteca_anexo_pdf a WHERE a.id_publicacao = p.id_publicacao AND a.status = 'ativo') AS qtd_anexos,
    (SELECT array_agg(nome_arquivo ORDER BY nome_arquivo)
     FROM mapoteca.mapoteca_anexo_pdf a
     WHERE a.id_publicacao = p.id_publicacao AND a.status = 'ativo') AS nomes_anexos

FROM mapoteca.mapoteca_publicacao p
LEFT JOIN mapoteca.mapoteca_classe_publicacao cp ON p.id_classe_publicacao = cp.id_classe_publicacao
LEFT JOIN mapoteca.mapoteca_tipo_publicacao tp ON p.id_tipo_publicacao = tp.id_tipo_publicacao
LEFT JOIN mapoteca.mapoteca_tema t ON p.id_tema = t.id_tema
LEFT JOIN mapoteca.mapoteca_tipo_tema tt ON t.id_tipo_tema = tt.id_tipo_tema
LEFT JOIN mapoteca.mapoteca_regiao r ON p.id_regiao = r.id_regiao
LEFT JOIN mapoteca.mapoteca_escala e ON p.id_escala = e.id_escala
LEFT JOIN mapoteca.mapoteca_cor c ON p.id_cor = c.id_cor
LEFT JOIN mapoteca.mapoteca_ano_referencia ar ON p.id_ano_referencia = ar.id_ano
WHERE p.status IN ('aprovado', 'publicado');

COMMENT ON VIEW mapoteca.vw_publicacoes_completas IS 'View completa de publicações para interface';
```

#### 4.1.2 View de Busca Full-Text
```sql
CREATE OR REPLACE VIEW mapoteca.vw_busca_publicacoes AS
SELECT
    p.id_publicacao,
    p.titulo,
    p.subtitulo,
    p.descricao,
    p.palavras_chave,
    p.data_publicacao,

    -- Vetor de busca combinado
    to_tsvector('portuguese',
        COALESCE(p.titulo, '') || ' ' ||
        COALESCE(p.subtitulo, '') || ' ' ||
        COALESCE(p.descricao, '') || ' ' ||
        COALESCE(p.palavras_chave, '') || ' ' ||
        COALESCE(t.nome_tema, '') || ' ' ||
        COALESCE(tt.nome_tipo_tema, '') || ' ' ||
        COALESCE(r.nome_regiao, '') || ' ' ||
        COALESCE(ar.ano::TEXT, '')
    ) AS vetor_busca,

    -- Metadados
    cp.nome_classe AS classe,
    tp.nome_tipo AS tipo,
    t.nome_tema AS tema,
    r.nome_regiao AS regiao,
    ar.ano AS ano,

    -- Ordenação
    p.data_criacao,
    p.data_atualizacao

FROM mapoteca.mapoteca_publicacao p
LEFT JOIN mapoteca.mapoteca_classe_publicacao cp ON p.id_classe_publicacao = cp.id_classe_publicacao
LEFT JOIN mapoteca.mapoteca_tipo_publicacao tp ON p.id_tipo_publicacao = tp.id_tipo_publicacao
LEFT JOIN mapoteca.mapoteca_tema t ON p.id_tema = t.id_tema
LEFT JOIN mapoteca.mapoteca_tipo_tema tt ON t.id_tipo_tema = tt.id_tipo_tema
LEFT JOIN mapoteca.mapoteca_regiao r ON p.id_regiao = r.id_regiao
LEFT JOIN mapoteca.mapoteca_ano_referencia ar ON p.id_ano_referencia = ar.id_ano
WHERE p.status = 'publicado';

COMMENT ON VIEW mapoteca.vw_busca_publicacoes IS 'View otimizada para busca full-text';
```

### 4.2 Funções de Busca

#### 4.2.1 Função de Busca Principal
```sql
CREATE OR REPLACE FUNCTION mapoteca.fn_buscar_publicacoes(
    p_termo_busca TEXT DEFAULT NULL,
    p_id_tipo_tema INTEGER DEFAULT NULL,
    p_id_tema INTEGER DEFAULT NULL,
    p_id_tipo_publicacao INTEGER DEFAULT NULL,
    p_id_classe_publicacao INTEGER DEFAULT NULL,
    p_id_regiao INTEGER DEFAULT NULL,
    p_ano_inicial INTEGER DEFAULT NULL,
    p_ano_final INTEGER DEFAULT NULL,
    p_limite INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
) RETURNS TABLE (
    id_publicacao INTEGER,
    titulo VARCHAR,
    subtitulo VARCHAR,
    tema VARCHAR,
    tipo_tema VARCHAR,
    tipo_publicacao VARCHAR,
    classe_publicacao VARCHAR,
    regiao VARCHAR,
    ano INTEGER,
    relevancia REAL,
    snippet TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id_publicacao,
        p.titulo,
        p.subtitulo,
        t.nome_tema,
        tt.nome_tipo_tema,
        tp.nome_tipo,
        cp.nome_classe,
        r.nome_regiao,
        ar.ano,
        -- Relevância baseada na busca
        CASE
            WHEN p_termo_busca IS NOT NULL THEN
                ts_rank(v.vetor_busca, plainto_tsquery('portuguese', p_termo_busca))
            ELSE
                1.0
        END AS relevancia,
        -- Snippet do conteúdo
        CASE
            WHEN p_termo_busca IS NOT NULL THEN
                ts_headline('portuguese',
                    COALESCE(p.titulo, '') || ' ' || COALESCE(p.descricao, ''),
                    plainto_tsquery('portuguese', p_termo_busca),
                    'MaxWords=35, MinWords=25, ShortWord=3, HighlightAll=true, MaxFragments=3, FragmentDelimiter=" ... "')
            ELSE
                LEFT(p.descricao, 200) || CASE WHEN length(p.descricao) > 200 THEN '...' ELSE '' END
        END AS snippet

    FROM mapoteca.mapoteca_publicacao p
    JOIN mapoteca.vw_busca_publicacoes v ON p.id_publicacao = v.id_publicacao
    LEFT JOIN mapoteca.mapoteca_tema t ON p.id_tema = t.id_tema
    LEFT JOIN mapoteca.mapoteca_tipo_tema tt ON t.id_tipo_tema = tt.id_tipo_tema
    LEFT JOIN mapoteca.mapoteca_tipo_publicacao tp ON p.id_tipo_publicacao = tp.id_tipo_publicacao
    LEFT JOIN mapoteca.mapoteca_classe_publicacao cp ON p.id_classe_publicacao = cp.id_classe_publicacao
    LEFT JOIN mapoteca.mapoteca_regiao r ON p.id_regiao = r.id_regiao
    LEFT JOIN mapoteca.mapoteca_ano_referencia ar ON p.id_ano_referencia = ar.id_ano

    WHERE
        p.status = 'publicado'
        AND (p_termo_busca IS NULL OR v.vetor_busca @@ plainto_tsquery('portuguese', p_termo_busca))
        AND (p_id_tipo_tema IS NULL OR t.id_tipo_tema = p_id_tipo_tema)
        AND (p_id_tema IS NULL OR p.id_tema = p_id_tema)
        AND (p_id_tipo_publicacao IS NULL OR p.id_tipo_publicacao = p_id_tipo_publicacao)
        AND (p_id_classe_publicacao IS NULL OR p.id_classe_publicacao = p_id_classe_publicacao)
        AND (p_id_regiao IS NULL OR p.id_regiao = p_id_regiao)
        AND (p_ano_inicial IS NULL OR ar.ano >= p_ano_inicial)
        AND (p_ano_final IS NULL OR ar.ano <= p_ano_final)

    ORDER BY
        CASE
            WHEN p_termo_busca IS NOT NULL THEN
                ts_rank(v.vetor_busca, plainto_tsquery('portuguese', p_termo_busca)) DESC
            ELSE
                p.data_publicacao DESC NULLS LAST, p.data_criacao DESC
        END,
        p.titulo

    LIMIT p_limite OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION mapoteca.fn_buscar_publicacoes IS 'Função principal de busca de publicações com filtros múltiplos';
```

#### 4.2.2 Função de Sugestões (Auto-completar)
```sql
CREATE OR REPLACE FUNCTION mapoteca.fn_sugestoes_busca(
    p_termo_parcial TEXT DEFAULT NULL,
    p_limite INTEGER DEFAULT 10
) RETURNS TABLE (
    sugestao TEXT,
    tipo VARCHAR,
    frequencia INTEGER
) AS $$
BEGIN
    RETURN QUERY
    -- Sugestões de temas
    SELECT DISTINCT
        t.nome_tema AS sugestao,
        'tema' AS tipo,
        COUNT(*) OVER (PARTITION BY t.nome_tema) AS frequencia
    FROM mapoteca.mapoteca_tema t
    JOIN mapoteca.mapoteca_publicacao p ON t.id_tema = p.id_tema
    WHERE p.status = 'publicado'
        AND p_termo_parcial IS NULL
        OR unaccent(t.nome_tema) ILIKE '%' || unaccent(p_termo_parcial) || '%'

    UNION ALL

    -- Sugestões de regiões
    SELECT DISTINCT
        r.nome_regiao AS sugestao,
        'regiao' AS tipo,
        COUNT(*) OVER (PARTITION BY r.nome_regiao) AS frequencia
    FROM mapoteca.mapoteca_regiao r
    JOIN mapoteca.mapoteca_publicacao p ON r.id_regiao = p.id_regiao
    WHERE p.status = 'publicado'
        AND p_termo_parcial IS NULL
        OR unaccent(r.nome_regiao) ILIKE '%' || unaccent(p_termo_parcial) || '%'

    UNION ALL

    -- Sugestões de títulos
    SELECT DISTINCT
        p.titulo AS sugestao,
        'titulo' AS tipo,
        1 AS frequencia
    FROM mapoteca.mapoteca_publicacao p
    WHERE p.status = 'publicado'
        AND p_termo_parcial IS NULL
        OR unaccent(p.titulo) ILIKE '%' || unaccent(p_termo_parcial) || '%'

    ORDER BY frequencia DESC, sugestao
    LIMIT p_limite;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION mapoteca.fn_sugestoes_busca IS 'Função para auto-completar e sugestões de busca';
```

---

## 5. Estratégia de Migração

### 5.1 Plano de Migração de Dados

#### Fase 1: Preparação
1. **Backup Completo**: Backup de todas as tabelas existentes
2. **Análise de Dados**: Validação da qualidade e integridade dos dados atuais
3. **Mapeamento**: Documentação do mapeamento entre estrutura antiga e nova

#### Fase 2: Migração de Domínios
```sql
-- Script de migração de tipos de tema
INSERT INTO mapoteca.mapoteca_tipo_tema (codigo_tipo_tema, nome_tipo_tema, ordem_exibicao)
SELECT DISTINCT
    CASE codigo_tipo_tema
        WHEN 'cart' THEN 'cartografia'
        WHEN 'padm' THEN 'politico_administrativo'
        WHEN 'fisamb' THEN 'fisico_ambiental'
        WHEN 'reg' THEN 'regionalizacao'
        WHEN 'soc' THEN 'socioeconomico'
        WHEN 'infra' THEN 'infraestrutura'
    END AS codigo_tipo_tema,
    tipo_tema,
    ROW_NUMBER() OVER (ORDER BY tipo_tema) AS ordem_exibicao
FROM tabelas_existentes.t_tipo_tema
GROUP BY codigo_tipo_tema, tipo_tema;

-- Script de migração de temas
INSERT INTO mapoteca.mapoteca_tema (id_tipo_tema, codigo_tema, nome_tema, ordem_exibicao)
SELECT
    tt.id_tipo_tema,
    REPLACE(REPLACE(REPLACE(codigo_tema, '.', ''), '-', '_'), ' ', '_') AS codigo_tema,
    tema,
    ROW_NUMBER() OVER (PARTITION BY tt.id_tipo_tema ORDER BY tema) AS ordem_exibicao
FROM tabelas_existentes.t_tipo_tema_tema ttt
JOIN mapoteca.mapoteca_tipo_tema tt ON
    CASE ttt.codigo_tipo_tema
        WHEN 'cart' THEN 'cartografia'
        WHEN 'padm' THEN 'politico_administrativo'
        WHEN 'fisamb' THEN 'fisico_ambiental'
        WHEN 'reg' THEN 'regionalizacao'
        WHEN 'soc' THEN 'socioeconomico'
        WHEN 'infra' THEN 'infraestrutura'
    END = tt.codigo_tipo_tema;
```

#### Fase 3: Migração de Publicações
```sql
-- Script de migração das publicações existentes
-- (Este é um exemplo e precisa ser adaptado para a estrutura real)
```

### 5.2 Validação e Testes

#### Validação de Integridade
1. **Contagem de Registros**: Verificar se todos os registros foram migrados
2. **Validação de Relacionamentos**: Garantir a integridade referencial
3. **Testes de Performance**: Comparar performance antes e depois da migração
4. **Validação Funcional**: Testar todas as funcionalidades do sistema

#### Testes Automatizados
```sql
-- Teste de integridade referencial
DO $$
DECLARE
    v_orphan_records INTEGER;
BEGIN
    -- Verificar temas sem tipo de tema
    SELECT COUNT(*) INTO v_orphan_records
    FROM mapoteca.mapoteca_tema t
    LEFT JOIN mapoteca.mapoteca_tipo_tema tt ON t.id_tipo_tema = tt.id_tipo_tema
    WHERE tt.id_tipo_tema IS NULL;

    IF v_orphan_records > 0 THEN
        RAISE EXCEPTION 'Encontrados % temas sem tipo de tema válido', v_orphan_records;
    END IF;

    -- Verificar publicações sem tema
    SELECT COUNT(*) INTO v_orphan_records
    FROM mapoteca.mapoteca_publicacao p
    LEFT JOIN mapoteca.mapoteca_tema t ON p.id_tema = t.id_tema
    WHERE t.id_tema IS NULL;

    IF v_orphan_records > 0 THEN
        RAISE EXCEPTION 'Encontradas % publicações sem tema válido', v_orphan_records;
    END IF;

    RAISE NOTICE 'Todos os testes de integridade passaram com sucesso';
END $$;
```

---

## 6. Performance e Otimização

### 6.1 Índices Otimizados

#### Índices Primários
```sql
-- Índices compostos para consultas frequentes
CREATE INDEX idx_publicacao_tema_ano ON mapoteca.mapoteca_publicacao(id_tema, id_ano_referencia);
CREATE INDEX idx_publicacao_tipo_status ON mapoteca.mapoteca_publicacao(id_tipo_publicacao, status);
CREATE INDEX idx_publicacao_classe_tema ON mapoteca.mapoteca_publicacao(id_classe_publicacao, id_tema);
CREATE INDEX idx_publicacao_regiao_tipo ON mapoteca.mapoteca_publicacao(id_regiao, id_tipo_publicacao);

-- Índices para ordenação
CREATE INDEX idx_publicacao_data_criacao ON mapoteca.mapoteca_publicacao(data_criacao DESC);
CREATE INDEX idx_publicacao_data_publicacao ON mapoteca.mapoteca_publicacao(data_publicacao DESC NULLS LAST);

-- Índices para busca full-text
CREATE INDEX idx_publicacao_busca_completa ON mapoteca.mapoteca_publicacao
    USING gin(to_tsvector('portuguese', titulo || ' ' || COALESCE(descricao, '') || ' ' || COALESCE(palavras_chave, '')));
```

#### Índices Especializados
```sql
-- Índice para consultas geográficas (se houver dados espaciais)
-- CREATE INDEX idx_publicacao_geometria ON mapoteca.mapoteca_publicacao USING GIST(geometria);

-- Índices para auditoria
CREATE INDEX idx_historico_data_usuario ON mapoteca.mapoteca_historico_auditoria(data_operacao DESC, usuario_operacao);

-- Índices parciais para performance
CREATE INDEX idx_publicacoes_ativas ON mapoteca.mapoteca_publicacao(id_publicacao, titulo, data_criacao)
    WHERE status IN ('aprovado', 'publicado');
```

### 6.2 Análise de Performance

#### Consultas Monitoradas
```sql
-- Habilitar estatísticas detalhadas
ALTER SYSTEM SET track_activities = on;
ALTER SYSTEM SET track_counts = on;
ALTER SYSTEM SET track_io_timing = on;

-- Monitorar consultas lentas
SELECT
    query,
    calls,
    total_time,
    mean_time,
    rows
FROM pg_stat_statements
WHERE query LIKE '%mapoteca_%'
ORDER BY mean_time DESC
LIMIT 10;
```

#### Otimização de Consultas
```sql
-- Exemplo de consulta otimizada para dropdown de temas
EXPLAIN (ANALYZE, BUFFERS)
SELECT t.id_tema, t.nome_tema, tt.nome_tipo_tema
FROM mapoteca.mapoteca_tema t
JOIN mapoteca.mapoteca_tipo_tema tt ON t.id_tipo_tema = tt.id_tipo_tema
WHERE t.ativo = true
    AND tt.ativo = true
ORDER BY tt.ordem_exibicao, t.ordem_exibicao;
```

### 6.3 Cache e Estratégias de Performance

#### Materialized Views para Consultas Complexas
```sql
CREATE MATERIALIZED VIEW mapoteca.mv_estatisticas_publicacoes AS
SELECT
    tt.nome_tipo_tema,
    t.nome_tema,
    tp.nome_tipo,
    COUNT(*) AS total_publicacoes,
    MAX(p.data_criacao) AS ultima_publicacao,
    MIN(p.data_criacao) AS primeira_publicacao
FROM mapoteca.mapoteca_publicacao p
JOIN mapoteca.mapoteca_tema t ON p.id_tema = t.id_tema
JOIN mapoteca.mapoteca_tipo_tema tt ON t.id_tipo_tema = tt.id_tipo_tema
JOIN mapoteca.mapoteca_tipo_publicacao tp ON p.id_tipo_publicacao = tp.id_tipo_publicacao
WHERE p.status = 'publicado'
GROUP BY tt.nome_tipo_tema, t.nome_tema, tp.nome_tipo
ORDER BY total_publicacoes DESC;

-- Índice na materialized view
CREATE INDEX idx_mv_estatisticas_tipo_tema ON mapoteca.mv_estatisticas_publicacoes(nome_tipo_tema);

-- Função para atualizar a view
CREATE OR REPLACE FUNCTION mapoteca.fn_atualizar_estatisticas()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY mapoteca.mv_estatisticas_publicacoes;
END;
$$ LANGUAGE plpgsql;
```

---

## 7. Segurança e Controle de Acesso

### 7.1 Roles e Permissões

#### Estrutura de Roles
```sql
-- Roles principais
CREATE ROLE mapoteca_readonly;
CREATE ROLE mapoteca_editor;
CREATE ROLE mapoteca_admin;
CREATE ROLE mapoteca_app;

-- Conceder permissões básicas
GRANT USAGE ON SCHEMA mapoteca TO mapoteca_readonly;
GRANT USAGE ON SCHEMA mapoteca TO mapoteca_editor;
GRANT USAGE ON SCHEMA mapoteca TO mapoteca_admin;
GRANT USAGE ON SCHEMA mapoteca TO mapoteca_app;

-- Permissões de leitura
GRANT SELECT ON ALL TABLES IN SCHEMA mapoteca TO mapoteca_readonly;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA mapoteca TO mapoteca_readonly;

-- Permissões de edição
GRANT SELECT, INSERT, UPDATE ON mapoteca.mapoteca_publicacao TO mapoteca_editor;
GRANT SELECT, INSERT, UPDATE ON mapoteca.mapoteca_anexo_pdf TO mapoteca_editor;
GRANT SELECT, INSERT ON mapoteca.mapoteca_historico_auditoria TO mapoteca_editor;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA mapoteca TO mapoteca_editor;

-- Permissões administrativas
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA mapoteca TO mapoteca_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA mapoteca TO mapoteca_admin;
GRANT ALL PRIVILEGES ON SCHEMA mapoteca TO mapoteca_admin;
```

#### Row Level Security (RLS)
```sql
-- Habilitar RLS na tabela de publicações
ALTER TABLE mapoteca.mapoteca_publicacao ENABLE ROW LEVEL SECURITY;

-- Políticas de acesso
CREATE POLICY policy_publicacoes_readonly ON mapoteca.mapoteca_publicacao
    FOR SELECT
    TO mapoteca_readonly
    USING (status IN ('aprovado', 'publicado'));

CREATE POLICY policy_publicacoes_editor ON mapoteca.mapoteca_publicacao
    FOR ALL
    TO mapoteca_editor
    USING (true)
    WITH CHECK (true);

-- Políticas específicas por usuário (exemplo)
CREATE POLICY policy_publicacoes_usuario ON mapoteca.mapoteca_publicacao
    FOR ALL
    TO mapoteca_editor
    USING (usuario_criacao = current_user OR status = 'publicado')
    WITH CHECK (usuario_criacao = current_user OR status IN ('rascunho', 'revisao'));
```

### 7.2 Auditoria e Logging

#### Auditoria Detalhada
```sql
-- Função estendida de auditoria
CREATE OR REPLACE FUNCTION mapoteca.fn_auditoria_detalhada()
RETURNS TRIGGER AS $$
DECLARE
    v_detalhes JSONB;
BEGIN
    v_detalhes := jsonb_build_object(
        'ip_origem', inet_client_addr(),
        'user_agent', current_setting('application_name', true),
        'transaction_id', txid_current(),
        'session_user', session_user,
        'current_user', current_user
    );

    IF TG_OP = 'INSERT' THEN
        INSERT INTO mapoteca.mapoteca_historico_auditoria (
            tabela_origem, id_registro, tipo_operacao,
            dados_novos, usuario_operacao, ip_origem
        ) VALUES (
            TG_TABLE_NAME, NEW.id_publicacao, 'INSERT',
            row_to_json(NEW) || v_detalhes, current_user, inet_client_addr()
        );
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        -- Registrar apenas campos modificados
        INSERT INTO mapoteca.mapoteca_historico_auditoria (
            tabela_origem, id_registro, tipo_operacao,
            dados_anteriores, dados_novos, usuario_operacao, ip_origem
        ) VALUES (
            TG_TABLE_NAME, NEW.id_publicacao, 'UPDATE',
            row_to_json(OLD) || v_detalhes,
            row_to_json(NEW) || v_detalhes,
            current_user, inet_client_addr()
        );
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO mapoteca.mapoteca_historico_auditoria (
            tabela_origem, id_registro, tipo_operacao,
            dados_anteriores, usuario_operacao, ip_origem
        ) VALUES (
            TG_TABLE_NAME, OLD.id_publicacao, 'DELETE',
            row_to_json(OLD) || v_detalhes, current_user, inet_client_addr()
        );
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
```

---

## 8. Monitoramento e Manutenção

### 8.1 Monitoramento de Performance

#### Estatísticas e Health Checks
```sql
-- Função de health check
CREATE OR REPLACE FUNCTION mapoteca.fn_health_check()
RETURNS TABLE (
    metrica VARCHAR,
    valor VARCHAR,
    status VARCHAR
) AS $$
BEGIN
    -- Verificar conexões ativas
    RETURN QUERY
    SELECT
        'conexoes_ativas'::VARCHAR,
        COUNT(*)::TEXT,
        CASE WHEN COUNT(*) < 50 THEN 'OK' ELSE 'ALERTA' END
    FROM pg_stat_activity
    WHERE datname = current_database()
    AND state = 'active';

    -- Verificar tamanho das tabelas
    RETURN QUERY
    SELECT
        'tamanho_publicacoes_mb'::VARCHAR,
        ROUND(pg_total_relation_size('mapoteca.mapoteca_publicacao')/1024.0/1024.0, 2)::TEXT,
        CASE WHEN pg_total_relation_size('mapoteca.mapoteca_publicacao') < 1024*1024*100 THEN 'OK' ELSE 'ALERTA' END;

    -- Verificar performance de consultas
    RETURN QUERY
    SELECT
        'tempo_medio_consultas_ms'::VARCHAR,
        ROUND(AVG(mean_time), 2)::TEXT,
        CASE WHEN AVG(mean_time) < 100 THEN 'OK' ELSE 'ALERTA' END
    FROM pg_stat_statements
    WHERE query LIKE '%mapoteca_%';
END;
$$ LANGUAGE plpgsql;
```

### 8.2 Manutenção Automática

#### Rotinas de Manutenção
```sql
-- Função de manutenção periódica
CREATE OR REPLACE FUNCTION mapoteca.fn_manutencao_periodica()
RETURNS void AS $$
BEGIN
    -- Atualizar estatísticas
    ANALYZE mapoteca.mapoteca_publicacao;
    ANALYZE mapoteca.mapoteca_tema;
    ANALYZE mapoteca.mapoteca_tipo_tema;

    -- Limpar logs antigos (manter últimos 6 meses)
    DELETE FROM mapoteca.mapoteca_historico_auditoria
    WHERE data_operacao < CURRENT_DATE - INTERVAL '6 months';

    -- Atualizar materialized views
    REFRESH MATERIALIZED VIEW CONCURRENTLY mapoteca.mv_estatisticas_publicacoes;

    -- Otimizar tabelas fragmentadas
    VACUUM ANALYZE mapoteca.mapoteca_publicacao;
    VACUUM ANALYZE mapoteca.mapoteca_anexo_pdf;

    RAISE NOTICE 'Manutenção periódica concluída com sucesso';
END;
$$ LANGUAGE plpgsql;

-- Agendar manutenção (requer pg_cron)
-- SELECT cron.schedule('manutencao-mapoteca', '0 2 * * 0', 'SELECT mapoteca.fn_manutencao_periodica();');
```

### 8.3 Backup e Recovery

#### Estratégia de Backup
```sql
-- Função de verificação de backup
CREATE OR REPLACE FUNCTION mapoteca.fn_verificar_backup()
RETURNS TABLE (
    tipo_backup VARCHAR,
    data_backup TIMESTAMP,
    status VARCHAR,
    observacoes TEXT
) AS $$
BEGIN
    -- Verificar último backup completo
    RETURN QUERY
    SELECT
        'backup_completo'::VARCHAR,
        MAX(data_backup),
        CASE WHEN MAX(data_backup) > CURRENT_TIMESTAMP - INTERVAL '1 day' THEN 'OK' ELSE 'ATRASADO' END,
        'Backup completo das tabelas principais'
    FROM (
        SELECT data_criacao AS data_backup
        FROM mapoteca.mapoteca_historico_auditoria
        WHERE tipo_operacao = 'BACKUP_COMPLETE'
        ORDER BY data_criacao DESC
        LIMIT 1
    ) backup_completo;

    -- Verificar backup de arquivos
    RETURN QUERY
    SELECT
        'backup_arquivos'::VARCHAR,
        MAX(data_upload),
        CASE WHEN MAX(data_upload) > CURRENT_TIMESTAMP - INTERVAL '7 days' THEN 'OK' ELSE 'ATRASADO' END,
        'Backup dos anexos PDF'
    FROM mapoteca.mapoteca_anexo_pdf;
END;
$$ LANGUAGE plpgsql;
```

---

## 9. Documentação de API

### 9.1 Funções Principais

#### Interface de Busca
```sql
-- Função principal para interface de busca
CREATE OR REPLACE FUNCTION mapoteca.interface_busca(
    p_termo TEXT DEFAULT NULL,
    p_filtros JSONB DEFAULT '{}',
    p_pagina INTEGER DEFAULT 1,
    p_itens_por_pagina INTEGER DEFAULT 20
) RETURNS JSONB AS $$
DECLARE
    v_resultado JSONB;
    v_total INTEGER;
    v_offset INTEGER;
BEGIN
    v_offset := (p_pagina - 1) * p_itens_por_pagina;

    -- Buscar resultados
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', id_publicacao,
            'titulo', titulo,
            'subtitulo', subtitulo,
            'tema', tema,
            'tipo_tema', tipo_tema,
            'tipo_publicacao', tipo_publicacao,
            'classe_publicacao', classe_publicacao,
            'regiao', regiao,
            'ano', ano,
            'relevancia', relevancia,
            'snippet', snippet
        )
    ) INTO v_resultado
    FROM mapoteca.fn_buscar_publicacoes(
        p_termo,
        (p_filtros->>'id_tipo_tema')::INTEGER,
        (p_filtros->>'id_tema')::INTEGER,
        (p_filtros->>'id_tipo_publicacao')::INTEGER,
        (p_filtros->>'id_classe_publicacao')::INTEGER,
        (p_filtros->>'id_regiao')::INTEGER,
        (p_filtros->>'ano_inicial')::INTEGER,
        (p_filtros->>'ano_final')::INTEGER,
        p_itens_por_pagina,
        v_offset
    );

    -- Contar total
    SELECT COUNT(*) INTO v_total
    FROM mapoteca.fn_buscar_publicacoes(
        p_termo,
        (p_filtros->>'id_tipo_tema')::INTEGER,
        (p_filtros->>'id_tema')::INTEGER,
        (p_filtros->>'id_tipo_publicacao')::INTEGER,
        (p_filtros->>'id_classe_publicacao')::INTEGER,
        (p_filtros->>'id_regiao')::INTEGER,
        (p_filtros->>'ano_inicial')::INTEGER,
        (p_filtros->>'ano_final')::INTEGER,
        1000000, -- Limite alto para contar todos
        0
    );

    RETURN jsonb_build_object(
        'resultados', COALESCE(v_resultado, '[]'::jsonb),
        'paginacao', jsonb_build_object(
            'pagina_atual', p_pagina,
            'itens_por_pagina', p_itens_por_pagina,
            'total_resultados', v_total,
            'total_paginas', CEIL(v_total::DECIMAL / p_itens_por_pagina)
        ),
        'filtros_aplicados', p_filtros,
        'termo_busca', p_termo
    );
END;
$$ LANGUAGE plpgsql;
```

### 9.2 Views para Dropdowns

#### Dropdowns Hierárquicos
```sql
-- View para dropdown de temas organizados por tipo
CREATE OR REPLACE VIEW mapoteca.vw_dropdown_temas AS
SELECT
    tt.codigo_tipo_tema,
    tt.nome_tipo_tema AS categoria,
    t.codigo_tema,
    t.nome_tema AS tema,
    tt.ordem_exibicao AS ordem_categoria,
    t.ordem_exibicao AS ordem_tema,
    ROW_NUMBER() OVER (PARTITION BY tt.id_tipo_tema ORDER BY t.ordem_exibicao) AS ordem_no_tipo
FROM mapoteca.mapoteca_tema t
JOIN mapoteca.mapoteca_tipo_tema tt ON t.id_tipo_tema = tt.id_tipo_tema
WHERE t.ativo = true
    AND tt.ativo = true
ORDER BY tt.ordem_exibicao, t.ordem_exibicao;

-- View para dropdown de regiões por tipo de regionalização
CREATE OR REPLACE VIEW mapoteca.vw_dropdown_regioes AS
SELECT
    tr.codigo_tipo AS tipo_regionalizacao,
    tr.nome_tipo AS nome_tipo_regionalizacao,
    r.codigo_regiao,
    r.nome_regiao,
    tr.id_tipo_regionalizacao,
    r.id_regiao
FROM mapoteca.mapoteca_regiao r
JOIN mapoteca.mapoteca_regiao_regionalizacao rrr ON r.id_regiao = rrr.id_regiao
JOIN mapoteca.mapoteca_tipo_regionalizacao tr ON rrr.id_tipo_regionalizacao = tr.id_tipo_regionalizacao
WHERE r.ativo = true
    AND tr.ativo = true
ORDER BY tr.nome_tipo, r.nome_regiao;
```

---

## 10. Plano de Implementação

### 10.1 Cronograma

#### Fase 1: Fundação (Semanas 1-2)
- [ ] Criação do schema e tabelas de domínio
- [ ] Migração dos dados de lookup
- [ ] Configuração de roles e permissões básicas
- [ ] Implementação de auditoria

#### Fase 2: Migração (Semanas 3-4)
- [ ] Migração das publicações existentes
- [ ] Migração dos anexos PDF
- [ ] Validação de integridade de dados
- [ ] Testes funcionais básicos

#### Fase 3: Otimização (Semanas 5-6)
- [ ] Criação de índices otimizados
- [ ] Implementação de views materializadas
- [ ] Otimização de consultas críticas
- [ ] Testes de performance

#### Fase 4: Integração (Semanas 7-8)
- [ ] Integração com ESRI Attachments
- [ ] Implementação de busca full-text
- [ ] Configuração de interface web
- [ ] Testes de integração

#### Fase 5: Produção (Semanas 9-10)
- [ ] Deploy em ambiente de produção
- [ ] Monitoramento e ajustes finais
- [ ] Documentação completa
- [ ] Treinamento da equipe

### 10.2 Riscos e Mitigações

#### Riscos Identificados
1. **Perda de Dados**: Durante migração
   - **Mitigação**: Backups completos antes de cada fase
   - **Plano de Contingência**: Rollback automatizado

2. **Performance Degradation**: Queries lentas
   - **Mitigação**: Testes de performance em cada etapa
   - **Plano de Contingência**: Índices adicionais se necessário

3. **Compatibilidade**: Problemas com aplicações existentes
   - **Mitigação**: Views de compatibilidade
   - **Plano de Contingência**: Mantenção de estrutura antiga em paralelo

### 10.3 Critérios de Sucesso

#### Métricas de Sucesso
- [ ] Migração 100% dos dados sem perdas
- [ ] Performance: tempo de resposta < 2 segundos para 95% das consultas
- [ ] Disponibilidade: 99.9% uptime durante migração
- [ ] Satisfação: feedback positivo dos usuários

#### KPIs de Monitoramento
- Tempo de resposta das consultas principais
- Taxa de utilização da nova busca
- Número de publicações criadas/atualizadas
- Uso de recursos do banco de dados

---

## 11. Conclusão

Esta proposta de redesenho da arquitetura de dados aborda todos os problemas identificados na estrutura atual da Mapoteca Digital:

### 11.1 Benefícios Alcançados

1. **Normalização Completa**: Eliminação de redundâncias e inconsistências
2. **Performance Otimizada**: Índices e consultas otimizadas para volume de dados
3. **Escalabilidade**: Estrutura preparada para crescimento futuro
4. **Integridade**: Constraints robustas e auditoria completa
5. **Manutenibilidade**: Documentação completa e código bem estruturado
6. **Modernização**: Uso de features modernas do PostgreSQL

### 11.2 Próximos Passos

1. **Aprovação da Proposta**: Revisão e aprovação pela equipe técnica
2. **Detalhamento Técnico**: Refinamento dos scripts de migração
3. **Execução**: Implementação conforme cronograma proposto
4. **Monitoramento**: Acompanhamento contínuo pós-implementação

### 11.3 Documentação Complementar

- Dicionário de dados completo
- Scripts de migração detalhados
- Manuais de operação e manutenção
- Guias de desenvolvimento e integração

---

**Assinaturas**

_________________________
Arquiteto de Dados
Data: 10/11/2025

_________________________
Aprovado por:
Data: __/__/____

_________________________
Implementado por:
Data: __/__/____

---

*Documento versão 1.0 - Última atualização: 10/Novembro/2025*
*Confidencial - Uso Interno*