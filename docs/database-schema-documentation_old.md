# Documentação de Esquema de Banco de Dados - Mapoteca

## 📖 Visão Geral

Este documento descreve o esquema de banco de dados PostgreSQL 14+ desenvolvido para o projeto Mapoteca, criado a partir da análise de 12 planilhas Excel contendo dados estruturais de mapas e regionalizações.

### 🎯 Objetivo do Banco de Dados

- Armazenar informações estruturais sobre mapas e suas características
- Suportar regionalizações e classificações geográficas
- Facilitar consultas complexas entre diferentes entidades
- Garantir integridade referencial e performance nas operações

---

## 📊 Estatísticas do Esquema

### Resumo de Tabelas
- **Total de Tabelas:** 13
  - **10 Tabelas Principais:** Dados dimensionais + tabela principal de mapas
  - **3 Tabelas de Relacionamento:** N:M connections
- **Total de Registros Estimados:** ~630+ (estrutura) + infinitos (mapas publicados)
- **Bytes Armazenados:** ~50KB (estrutura) + dinâmico (dados de mapas)

### Volume de Dados por Fonte
| Tabela | Registros | Descrição |
|--------|-----------|-----------|
| `classe_mapa` | 2 | Classes de mapas (Mapa, Cartograma) |
| `tipo_mapa` | 3 | Tipos de mapas (Estadual, Regional, Municipal) |
| `regiao` | 214 | Regiões geográficas diversas |
| `tema` | 55 | Temas de classificação de mapas |
| `tipo_regionalizacao` | 11 | Tipos de regionalização |
| `tipo_tema` | 6 | Tipos de temas |
| `escala` | 9 | Escalas cartográficas |
| `cor` | 2 | Opções de cores |
| `ano` | 33 | Anos de referência (1998-2030) |
| `classe_mapa_tipo_mapa` | 6 | Relacionamentos classe x tipo |
| `tipo_regionalizacao_regiao` | 233 | Relacionamentos regionalização x região |
| `tipo_tema_tema` | 55 | Relacionamentos tipo tema x tema |
| `mapa` | ∞ | Tabela principal de mapas publicados (não limitado) |

---

## 🏗️ Estrutura do Esquema

### Diagrama Entidade-Relacionamento (Simplificado)

```
[classe_mapa] ◄───► [classe_mapa_tipo_mapa] ◄───► [tipo_mapa]
                                                │
[regiao] ◄───► [tipo_regionalizacao_regiao] ◄───► [tipo_regionalizacao]

[tema] ◄───► [tipo_tema_tema] ◄───► [tipo_tema]

[escala]     [cor]       [ano]
    \           \           /
     \           \         /
      \           \       /
       ▼           ▼     ▼
           [mapa] ← Tabela Principal
```

---

## 📋 Detalhamento das Tabelas

### 1. Tabelas Principais

#### `classe_mapa`
**Descrição:** Classificação principal dos tipos de representação cartográfica.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `id_classe_mapa` | VARCHAR(2) | PRIMARY KEY | Identificador único |
| `nome_classe_mapa` | VARCHAR(50) | NOT NULL, UNIQUE | Nome da classe |
| `data_criacao` | TIMESTAMPTZ | DEFAULT NOW() | Data de criação |
| `data_atualizacao` | TIMESTAMPTZ | DEFAULT NOW() | Última atualização |

**Exemplos de Dados:**
- `01: Mapa`
- `02: Cartograma`

---

#### `tipo_mapa`
**Descrição:** Classificação por abrangência territorial dos mapas.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `id_tipo_mapa` | VARCHAR(2) | PRIMARY KEY | Identificador único |
| `nome_tipo_mapa` | VARCHAR(50) | NOT NULL, UNIQUE | Nome do tipo |
| `data_criacao` | TIMESTAMPTZ | DEFAULT NOW() | Data de criação |
| `data_atualizacao` | TIMESTAMPTZ | DEFAULT NOW() | Última atualização |

**Exemplos de Dados:**
- `01: Estadual`
- `02: Regional`
- `03: Municipal`

---

#### `regiao`
**Descrição:** Unidades geográficas com diferentes níveis de granularidade.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `id_regiao` | VARCHAR(3) | PRIMARY KEY | Identificador único |
| `nome_regiao` | VARCHAR(100) | NOT NULL | Nome da região |
| `abrangencia` | VARCHAR(20) | NULL | Tipo de abrangência |
| `data_criacao` | TIMESTAMPTZ | DEFAULT NOW() | Data de criação |
| `data_atualizacao` | TIMESTAMPTZ | DEFAULT NOW() | Última atualização |

---

#### `tema`
**Descrição:** Temáticas abordadas nos mapas para classificação e pesquisa.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `id_tema` | SERIAL | PRIMARY KEY | ID sequencial |
| `codigo_tema` | VARCHAR(20) | NOT NULL, UNIQUE | Código temático |
| `nome_tema` | VARCHAR(200) | NOT NULL | Descrição do tema |
| `data_criacao` | TIMESTAMPTZ | DEFAULT NOW() | Data de criação |
| `data_atualizacao` | TIMESTAMPTZ | DEFAULT NOW() | Última atualização |

---

#### `tipo_regionalizacao`
**Descrição:** Métodos e critérios de regionalização territorial.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `id_tipo_regionalizacao` | VARCHAR(2) | PRIMARY KEY | Identificador único |
| `nome_tipo_regionalizacao` | VARCHAR(100) | NOT NULL, UNIQUE | Nome do tipo |
| `data_criacao` | TIMESTAMPTZ | DEFAULT NOW() | Data de criação |
| `data_atualizacao` | TIMESTAMPTZ | DEFAULT NOW() | Última atualização |

---

#### `tipo_tema`
**Descrição:** Categorias principais para agrupamento de temas.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `id_tipo_tema` | VARCHAR(2) | PRIMARY KEY | Identificador único |
| `codigo_tipo_tema` | VARCHAR(10) | NOT NULL, UNIQUE | Código do tipo |
| `nome_tipo_tema` | VARCHAR(50) | NOT NULL | Nome do tipo |
| `data_criacao` | TIMESTAMPTZ | DEFAULT NOW() | Data de criação |
| `data_atualizacao` | TIMESTAMPTZ | DEFAULT NOW() | Última atualização |

**Exemplos:**
- `CT: Cartografia`
- `PA: Político-Administrativo`
- `FA: Físico-Ambiental`

---

#### `escala`
**Descrição:** Escalas cartográficas padrão utilizadas.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `codigo_escala` | VARCHAR(10) | PRIMARY KEY | Código da escala |
| `nome_escala` | VARCHAR(20) | NOT NULL, UNIQUE | Nome descritivo |
| `data_criacao` | TIMESTAMPTZ | DEFAULT NOW() | Data de criação |
| `data_atualizacao` | TIMESTAMPTZ | DEFAULT NOW() | Última atualização |

**Exemplos:**
- `1:2.000.000`
- `1:500.000`
- `1:250.000`

---

#### `cor`
**Descrição:** Esquemas de cores disponíveis para os mapas.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `codigo_cor` | VARCHAR(5) | PRIMARY KEY | Código da cor |
| `nome_cor` | VARCHAR(20) | NOT NULL, UNIQUE | Nome do esquema |
| `data_criacao` | TIMESTAMPTZ | DEFAULT NOW() | Data de criação |
| `data_atualizacao` | TIMESTAMPTZ | DEFAULT NOW() | Última atualização |

**Exemplos:**
- `COLOR: Colorido`
- `PB: Preto e Branco`

---

#### `ano`
**Descrição:** Anos de referência temporal dos dados.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `id_ano` | VARCHAR(2) | PRIMARY KEY | Identificador |
| `ano` | INTEGER | NOT NULL, UNIQUE, CHECK(ano BETWEEN 1990 AND 2050) | Valor numérico |
| `data_criacao` | TIMESTAMPTZ | DEFAULT NOW() | Data de criação |
| `data_atualizacao` | TIMESTAMPTZ | DEFAULT NOW() | Última atualização |

**Intervalo:** 1998 a 2030

---

#### `mapa`
**Descrição:** Tabela principal que armazena todos os mapas publicados com suas classificações completas. Esta é a tabela central do sistema que conecta todas as outras tabelas de classificação.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `id_mapa` | SERIAL | PRIMARY KEY | Identificador único sequencial |
| `id_classe_mapa` | VARCHAR(2) | NOT NULL, FK | Classe do mapa (Mapa, Cartograma) |
| `id_tipo_mapa` | VARCHAR(2) | NOT NULL, FK | Tipo do mapa (Estadual, Regional, Municipal) |
| `id_ano` | VARCHAR(2) | NOT NULL, FK | Ano de referência do mapa |
| `id_regiao` | VARCHAR(3) | NOT NULL, FK | Região geográfica abrangida |
| `codigo_escala` | VARCHAR(10) | NOT NULL, FK | Escala cartográfica |
| `codigo_cor` | VARCHAR(5) | NOT NULL, FK | Esquema de cores |
| `id_tipo_regionalizacao` | VARCHAR(2) | NOT NULL, FK | Tipo de regionalização |
| `id_tema` | INTEGER | NOT NULL, FK | Tema principal do mapa |
| `id_tipo_tema` | VARCHAR(2) | NOT NULL, FK | Tipo de tema |
| `data_criacao` | TIMESTAMPTZ | DEFAULT NOW() | Data de criação |
| `data_atualizacao` | TIMESTAMPTZ | DEFAULT NOW() | Última atualização |

**Relacionamentos:**
- **Chaves Estrangeiras:** 9 FKs para todas as tabelas de classificação
- **Restrição DELETE:** RESTRICT (não permite exclusão se houver mapas relacionados)
- **Auditoria:** Timestamps automáticos para controle de modificações

**Exemplo de Registro Completo:**
```sql
INSERT INTO mapa (
    id_classe_mapa, id_tipo_mapa, id_ano, id_regiao,
    codigo_escala, codigo_cor, id_tipo_regionalizacao,
    id_tema, id_tipo_tema
) VALUES (
    '01', '01', '01', '001', -- Mapa Estadual, 1998, Região 001
    '1:2.000.000', 'COLOR', -- Escala e cor
    '01', '55', 'CT' -- Regionalização, Tema 55, Tipo Cartografia
);
```

---

### 2. Tabelas de Relacionamento

#### `classe_mapa_tipo_mapa`
**Descrição:** Relaciona classes com tipos de mapas (N:M).

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `id_classe_mapa` | VARCHAR(2) | PRIMARY KEY, FK | Referencia classe_mapa |
| `id_tipo_mapa` | VARCHAR(2) | PRIMARY KEY, FK | Referencia tipo_mapa |
| `data_criacao` | TIMESTAMPTZ | DEFAULT NOW() | Data de criação |

---

#### `tipo_regionalizacao_regiao`
**Descrição:** Relaciona tipos de regionalização com regiões (N:M).

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `id_tipo_regionalizacao` | VARCHAR(2) | PRIMARY KEY, FK | Referencia tipo_regionalizacao |
| `id_regiao` | VARCHAR(3) | PRIMARY KEY, FK | Referencia regiao |
| `data_criacao` | TIMESTAMPTZ | DEFAULT NOW() | Data de criação |

---

#### `tipo_tema_tema`
**Descrição:** Relaciona tipos de temas com temas específicos (N:M).

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `id_tipo_tema` | VARCHAR(2) | PRIMARY KEY, FK | Referencia tipo_tema |
| `id_tema` | INTEGER | PRIMARY KEY, FK | Referencia tema |
| `data_criacao` | TIMESTAMPTZ | DEFAULT NOW() | Data de criação |

---

## 🔧 Recursos Técnicos

### Índices Criados

#### Índices em Tabelas Principais
```sql
-- Performance em buscas por nome
CREATE INDEX idx_classe_mapa_nome ON classe_mapa(nome_classe_mapa);
CREATE INDEX idx_tipo_mapa_nome ON tipo_mapa(nome_tipo_mapa);
CREATE INDEX idx_regiao_nome ON regiao(nome_regiao);
CREATE INDEX idx_tema_nome ON tema(nome_tema);

-- Performance em buscas por código
CREATE INDEX idx_tema_codigo ON tema(codigo_tema);
CREATE INDEX idx_tipo_tema_codigo ON tipo_tema(codigo_tipo_tema);

-- Índices condicionais (apenas quando não NULL)
CREATE INDEX idx_regiao_abrangencia ON regiao(abrangencia) WHERE abrangencia IS NOT NULL;
```

#### Índices em Tabelas de Relacionamento
```sql
-- Otimização para joins frequentes
CREATE INDEX idx_tipo_reg_regiao ON tipo_regionalizacao_regiao(id_regiao);
CREATE INDEX idx_tipo_tema_tema_tema ON tipo_tema_tema(id_tema);
```

#### Índices na Tabela Principal de Mapas
```sql
-- Índices compostos para filtros múltiplos
CREATE INDEX idx_mapa_classe_tipo ON mapa(id_classe_mapa, id_tipo_mapa);
CREATE INDEX idx_mapa_regiao_ano ON mapa(id_regiao, id_ano);
CREATE INDEX idx_mapa_tema_tipo ON mapa(id_tema, id_tipo_tema);
CREATE INDEX idx_mapa_escala_cor ON mapa(codigo_escala, codigo_cor);

-- Índices simples para buscas específicas
CREATE INDEX idx_mapa_regionalizacao ON mapa(id_tipo_regionalizacao);
CREATE INDEX idx_mapa_data_criacao ON mapa(data_criacao);
CREATE INDEX idx_mapa_data_atualizacao ON mapa(data_atualizacao);
```

---

### Triggers Automáticos

Sistema de timestamps para auditoria e controle de modificações:

```sql
CREATE OR REPLACE FUNCTION atualizar_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_atualizacao = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

**Triggers Aplicados em Todas as Tabelas:**
- Atualização automática de `data_atualizacao` antes de cada UPDATE
- Mantém consistência temporal dos dados

---

### Views Úteis

#### `vw_tema_completo`
Combina informações de temas com seus tipos:
```sql
SELECT t.*, tt.codigo_tipo_tema, tt.nome_tipo_tema
FROM tema t
JOIN tipo_tema_tema ttt ON t.id_tema = ttt.id_tema
JOIN tipo_tema tt ON ttt.id_tipo_tema = tt.id_tipo_tema;
```

#### `vw_regiao_completa`
Visualização completa de regiões com regionalizações:
```sql
SELECT r.*, tr.nome_tipo_regionalizacao
FROM regiao r
JOIN tipo_regionalizacao_regiao trr ON r.id_regiao = trr.id_regiao
JOIN tipo_regionalizacao tr ON trr.id_tipo_regionalizacao = tr.id_tipo_regionalizacao;
```

#### `vw_tipo_mapa_completo`
Informações completas de tipos e classes de mapas:
```sql
SELECT tm.*, cm.nome_classe_mapa
FROM tipo_mapa tm
JOIN classe_mapa_tipo_mapa cmtm ON tm.id_tipo_mapa = cmtm.id_tipo_mapa
JOIN classe_mapa cm ON cmtm.id_classe_mapa = cm.id_classe_mapa;
```

#### `vw_mapa_completo`
Visualização completa de todos os dados dos mapas:
```sql
SELECT
    m.id_mapa,
    m.data_criacao,
    m.data_atualizacao,
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
```

---

## 📈 Performance e Otimização

### Estratégias de Otimização

1. **Índices Estratégicos:**
   - Índices únicos para colunas de lookup
   - Índices compostos onde necessário
   - Índices parciais para colunas opcionais

2. **Tipos de Dados Otimizados:**
   - VARCHAR para códigos preservando zeros à esquerda
   - SERIAL para IDs sequenciais
   - TIMESTAMPTZ para controle temporal

3. **Integridade Referencial:**
   - FOREIGN KEYs com DELETE CASCADE
   - Restrições CHECK para validação de domínio
   - UNIQUE constraints para evitar duplicatas

### Volume Estimado e Performance

| Tabela | Registros | Tamanho Estimado | Performance |
|--------|-----------|------------------|-------------|
| `regiao` | 214 | ~20KB | Excelente |
| `tema` | 55 | ~15KB | Excelente |
| `tipo_regionalizacao_regiao` | 233 | ~25KB | Bom |
| Outras tabelas | <100 | <20KB | Excelente |

**Tempo estimado de consulta:**
- Lookups simples: <5ms
- Joins complexos: <50ms
- Consultas com filtros múltiplos: <100ms

---

## 🔐 Segurança e Integridade

### Restrições Implementadas

1. **Chaves Primárias:**
   - Garantem unicidade de registros
   - Definem identificadores únicos para cada entidade

2. **Chaves Estrangeiras:**
   - Mantém integridade referencial
   - DELETE CASCADE para consistência automática
   - Previnem órfãos no relacionamento

3. **Restrições de Domínio:**
   - CHECK para validação de anos (1990-2050)
   - NOT NULL para campos essenciais
   - UNIQUE para evitar duplicatas

4. **Auditoria:**
   - Timestamps automáticos para rastreamento
   - Triggers para consistência temporal

---

## 📚 Exemplos de Consultas Úteis

### 1. Buscar todos os temas por tipo
```sql
SELECT
    tt.nome_tipo_tema,
    t.codigo_tema,
    t.nome_tema
FROM tipo_tema tt
JOIN tipo_tema_tema ttt ON tt.id_tipo_tema = ttt.id_tipo_tema
JOIN tema t ON ttt.id_tema = t.id_tema
WHERE tt.codigo_tipo_tema = 'PA'
ORDER BY t.nome_tema;
```

### 2. Listar regiões por tipo de regionalização
```sql
SELECT
    tr.nome_tipo_regionalizacao,
    r.nome_regiao
FROM tipo_regionalizacao tr
JOIN tipo_regionalizacao_regiao trr ON tr.id_tipo_regionalizacao = trr.id_tipo_regionalizacao
JOIN regiao r ON trr.id_regiao = r.id_regiao
ORDER BY tr.nome_tipo_regionalizacao, r.nome_regiao;
```

### 3. Combinação completa de classificações
```sql
SELECT
    cm.nome_classe_mapa,
    tm.nome_tipo_mapa,
    e.nome_escala,
    c.nome_cor,
    a.ano
FROM classe_mapa cm
JOIN classe_mapa_tipo_mapa cmtm ON cm.id_classe_mapa = cmtm.id_classe_mapa
JOIN tipo_mapa tm ON cmtm.id_tipo_mapa = tm.id_tipo_mapa
CROSS JOIN escala e
CROSS JOIN cor c
CROSS JOIN ano a;
```

### 4. Consultar mapas publicados com filtros
```sql
-- Mapas por região e ano
SELECT
    m.id_mapa,
    m.data_criacao,
    r.nome_regiao,
    a.ano,
    t.nome_tema,
    e.nome_escala
FROM mapa m
JOIN regiao r ON m.id_regiao = r.id_regiao
JOIN ano a ON m.id_ano = a.id_ano
JOIN tema t ON m.id_tema = t.id_tema
JOIN escala e ON m.codigo_escala = e.codigo_escala
WHERE r.nome_regiao LIKE '%São Paulo%'
AND a.ano >= 2020
ORDER BY a.ano DESC, m.data_criacao DESC;
```

### 5. Estatísticas de mapas por classificação
```sql
-- Contagem de mapas por tipo e classe
SELECT
    cm.nome_classe_mapa,
    tm.nome_tipo_mapa,
    COUNT(*) as total_mapas,
    MIN(m.data_criacao) as primeiro_mapa,
    MAX(m.data_criacao) as ultimo_mapa
FROM mapa m
JOIN classe_mapa cm ON m.id_classe_mapa = cm.id_classe_mapa
JOIN tipo_mapa tm ON m.id_tipo_mapa = tm.id_tipo_mapa
GROUP BY cm.nome_classe_mapa, tm.nome_tipo_mapa
ORDER BY total_mapas DESC;
```

---

## 🚀 Implantação e Manutenção

### Script de Implantação

1. **Backup do Banco:**
```sql
pg_dump -h localhost -U username -d database_name > backup_before.sql
```

2. **Executar Schema:**
```sql
\i database_schema.sql
```

3. **Validação:**
```sql
SELECT
    schemaname,
    tablename,
    rowcount
FROM pg_tables t
JOIN pg_class c ON t.tablename = c.relname
WHERE schemaname = 'public'
ORDER BY tablename;
```

### Manutenção Recomendada

1. **Estatísticas (semanal):**
```sql
ANALYZE;
```

2. **Reindexação (mensal):**
```sql
REINDEX DATABASE database_name;
```

3. **Monitoramento de Performance:**
```sql
SELECT
    schemaname,
    tablename,
    seq_tup_read,
    idx_tup_fetch
FROM pg_stat_user_tables;
```

---

## 📋 Checklist de Validação

### ✅ Itens Verificados

- [x] **Estrutura Normalizada:** 3NF aplicada
- [x] **Integridade Referencial:** FKs implementadas (incluindo 9 FKs na tabela mapa)
- [x] **Performance:** Índices otimizados (incluindo índices compostos para mapa)
- [x] **Auditoria:** Timestamps automáticos em todas as tabelas
- [x] **Documentação:** Comentários descritivos
- [x] **Validação:** Restrições CHECK e UNIQUE
- [x] **Views:** Consultas pré-otimizadas (incluindo vw_mapa_completo)
- [x] **Consistência:** Padrão de nomenclatura
- [x] **Tabela Principal:** mapa implementada com todos os relacionamentos
- [x] **Proteção de Dados:** DELETE RESTRICT para evitar exclusão acidental

---

## 🔮 Futuras Extensões

### Possíveis Melhorias

1. **Tabelas Adicionais:**
   - `usuario` - controle de acesso
   - `download_log` - auditoria de uso
   - `mapa_metadata` - metadados extensíveis para mapas
   - `mapa_arquivo` - armazenamento de múltiplos arquivos por mapa

2. **Recursos Avançados:**
   - Particionamento por ano
   - Materialized views para relatórios
   - Full-text search em descrições

3. **Performance:**
   - Índices parciais específicos
   - Caching de consultas frequentes
   - Otimização de queries complexas

---

## 📞 Suporte e Contato

**Responsável Técnico:** [Preencher nome do responsável]
**Data de Criação:** 10/11/2025
**Versão do Schema:** 1.0
**PostgreSQL:** 14+

---

## 📝 Histórico de Alterações

| Versão | Data | Alteração | Autor |
|--------|------|-----------|-------|
| 1.0 | 10/11/2025 | Criação inicial do schema (12 tabelas) | BMad Master |
| 1.1 | 10/11/2025 | Adicionada tabela principal 'mapa' com 9 FKs e índices otimizados | BMad Master |
| 1.2 | [Data] | [Descrição] | [Autor] |

---

*Este documento foi gerado automaticamente a partir da análise das planilhas Excel do projeto Mapoteca.*