# Documentação de Esquema de Banco de Dados - Mapoteca

## 📖 Visão Geral

Este documento descreve o esquema de banco de dados PostgreSQL 14+ desenvolvido para o projeto Mapoteca, criado a partir da análise de 12 planilhas Excel contendo dados estruturais de mapas e regionalizações.

**Schema:** `dados_mapoteca`
**Database:** `mapoteca`
**Data de Geração:** 17/11/2025

### 🎯 Objetivo do Banco de Dados

- Armazenar informações estruturais sobre mapas e suas características
- Suportar regionalizações e classificações geográficas
- Facilitar consultas complexas entre diferentes entidades
- Gerenciar attachments de arquivos PDF e outros documentos
- Garantir integridade referencial e performance nas operações

---

## 📊 Estatísticas do Esquema

### Resumo de Tabelas
- **Total de Tabelas:** 18
  - **10 Tabelas Principais:** Dados dimensionais e classificação
  - **4 Tabelas de Relacionamento:** N:M connections
  - **4 Tabelas de Publicação:** Gestão de mapas e attachments
- **Total de Registros:** ~1,210+ (estrutura) + infinitos (publicações e anexos)
- **Bytes Armazenados:** ~100KB (estrutura) + dinâmico (dados e arquivos)

### Volume de Dados Atual
| Tabela | Registros | Descrição |
|--------|-----------|-----------|
| `t_classe_mapa` | 2 | Classes de mapas (Mapa, Cartograma) |
| `t_tipo_mapa` | 3 | Tipos de mapas (Estadual, Regional, Municipal) |
| `t_regiao` | 106 | Regiões geográficas diversas |
| `t_tema` | 55 | Temas de classificação de mapas |
| `t_tipo_regionalizacao` | 11 | Tipos de regionalização |
| `t_tipo_tema` | 6 | Tipos de temas |
| `t_escala` | 9 | Escalas cartográficas |
| `t_cor` | 2 | Opções de cores |
| `t_anos` | 33 | Anos de referência (1998-2030) |
| `t_municipios` | 417 | Municípios com informações detalhadas |
| `t_classe_mapa_tipo_mapa` | 6 | Relacionamentos classe x tipo |
| `t_regionalizacao_regiao` | 229 | Relacionamentos regionalização x região |
| `t_tipo_tema_tema` | 55 | Relacionamentos tipo tema x tema |
| `t_publicacao` | 1+ | Tabela principal de publicações |
| `t_publicacao__attach` | 1+ | Anexos das publicações |
| `t_publicacao_municipios` | 0+ | Publicações por município |
| `t_publicacao_municipios_attach` | 0+ | Anexos de publicações municipais |

---

## 🏗️ Estrutura do Esquema

### Diagrama Entidade-Relacionamento (Simplificado)

```
[t_classe_mapa] ◄───► [t_classe_mapa_tipo_mapa] ◄───► [t_tipo_mapa]
                                                        │
[t_regiao] ◄───► [t_regionalizacao_regiao] ◄───► [t_tipo_regionalizacao]

[t_tema] ◄───► [t_tipo_tema_tema] ◄───► [t_tipo_tema]

[t_escala]     [t_cor]       [t_anos]
     \             \            /
      \             \          /
       \             \        /
        ▼             ▼      ▼
            [t_publicacao] ← Tabela Principal
                  │
                  ├──► [t_publicacao__attach] (Arquivos)
                  │
[t_municipios] ◄──► [t_publicacao_municipios]
                            │
                            └──► [t_publicacao_municipios_attach] (Arquivos)
```

---

## 📋 Detalhamento das Tabelas

### 1. Tabelas Principais

#### `t_classe_mapa`
**Descrição:** Classificação principal dos tipos de representação cartográfica.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `id_classe_mapa` | VARCHAR | NOT NULL | Identificador único |
| `nome_classe_mapa` | VARCHAR | NOT NULL | Nome da classe |

**Registros:** 2
**Exemplos de Dados:**
- `01: Mapa`
- `02: Cartograma`

---

#### `t_tipo_mapa`
**Descrição:** Classificação por abrangência territorial dos mapas.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `id_tipo_mapa` | VARCHAR | NOT NULL | Identificador único |
| `nome_tipo_mapa` | VARCHAR | NOT NULL | Nome do tipo |

**Registros:** 3
**Exemplos de Dados:**
- `01: Estadual`
- `02: Regional`
- `03: Municipal`

---

#### `t_regiao`
**Descrição:** Unidades geográficas com diferentes níveis de granularidade.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `id_regiao` | VARCHAR | NOT NULL | Identificador único |
| `nome_regiao` | VARCHAR | NOT NULL | Nome da região |
| `abrangencia` | VARCHAR | NULL | Tipo de abrangência |

**Registros:** 106

---

#### `t_tema`
**Descrição:** Temáticas abordadas nos mapas para classificação e pesquisa.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `id_tema` | INTEGER | NOT NULL, DEFAULT nextval('t_tema_id_tema_seq') | ID sequencial |
| `codigo_tema` | VARCHAR | NOT NULL | Código temático |
| `nome_tema` | VARCHAR | NOT NULL | Descrição do tema |

**Registros:** 55

---

#### `t_tipo_regionalizacao`
**Descrição:** Métodos e critérios de regionalização territorial.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `id_tipo_regionalizacao` | VARCHAR | NOT NULL | Identificador único |
| `nome_tipo_regionalizacao` | VARCHAR | NOT NULL | Nome do tipo |

**Registros:** 11

---

#### `t_tipo_tema`
**Descrição:** Categorias principais para agrupamento de temas.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `id_tipo_tema` | VARCHAR | NOT NULL | Identificador único |
| `codigo_tipo_tema` | VARCHAR | NOT NULL | Código do tipo |
| `nome_tipo_tema` | VARCHAR | NOT NULL | Nome do tipo |

**Registros:** 6
**Exemplos:**
- `CT: Cartografia`
- `PA: Político-Administrativo`
- `FA: Físico-Ambiental`

---

#### `t_escala`
**Descrição:** Escalas cartográficas padrão utilizadas.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `codigo_escala` | VARCHAR | NOT NULL | Código da escala |
| `nome_escala` | VARCHAR | NOT NULL | Nome descritivo |

**Registros:** 9
**Exemplos:**
- `1:2.000.000`
- `1:500.000`
- `1:250.000`

---

#### `t_cor`
**Descrição:** Esquemas de cores disponíveis para os mapas.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `codigo_cor` | VARCHAR | NOT NULL | Código da cor |
| `nome_cor` | VARCHAR | NOT NULL | Nome do esquema |

**Registros:** 2
**Exemplos:**
- `COLOR: Colorido`
- `PB: Preto e Branco`

---

#### `t_anos`
**Descrição:** Anos de referência temporal dos dados.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `id_ano` | VARCHAR | NOT NULL | Identificador |
| `ano` | INTEGER | NOT NULL | Valor numérico |

**Registros:** 33
**Intervalo:** 1998 a 2030

---

#### `t_municipios`
**Descrição:** Cadastro de municípios com informações detalhadas e localização territorial.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `codmun` | VARCHAR | NOT NULL | Código do município |
| `nommun` | VARCHAR | NOT NULL | Nome do município |
| `sigla_uf` | VARCHAR | NOT NULL, DEFAULT 'BA' | Sigla do estado |
| `nome_uf` | VARCHAR | NOT NULL, DEFAULT 'Bahia' | Nome do estado |
| `codigo_regiao` | VARCHAR | NULL | Código da região |
| `nome_regiao` | VARCHAR | NULL | Nome da região |
| `codigo_territorio` | VARCHAR | NULL | Código do território |
| `nome_territorio` | VARCHAR | NULL | Nome do território |
| `data_criacao` | TIMESTAMP | NULL, DEFAULT CURRENT_TIMESTAMP | Data de criação |
| `data_atualizacao` | TIMESTAMP | NULL, DEFAULT CURRENT_TIMESTAMP | Data de atualização |
| `ativo` | BOOLEAN | NULL, DEFAULT true | Status ativo |

**Registros:** 417

---

#### `t_publicacao`
**Descrição:** Tabela principal que armazena todos os mapas publicados com suas classificações completas. Inclui GlobalID para integração com ArcGIS.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `id_publicacao` | INTEGER | NOT NULL, DEFAULT nextval('t_publicacao_id_publicacao_seq') | ID sequencial |
| `id_classe_mapa` | VARCHAR | NOT NULL | Classe do mapa |
| `id_tipo_mapa` | VARCHAR | NOT NULL | Tipo do mapa |
| `id_ano` | VARCHAR | NOT NULL | Ano de referência |
| `id_regiao` | VARCHAR | NOT NULL | Região geográfica |
| `codigo_escala` | VARCHAR | NOT NULL | Escala cartográfica |
| `codigo_cor` | VARCHAR | NOT NULL | Esquema de cores |
| `id_tipo_regionalizacao` | VARCHAR | NOT NULL | Tipo de regionalização |
| `id_tema` | INTEGER | NOT NULL | Tema principal |
| `id_tipo_tema` | VARCHAR | NOT NULL | Tipo de tema |
| `globalid` | UUID | NOT NULL, DEFAULT gen_random_uuid() | GlobalID para ArcGIS |

**Registros:** 1+

---

#### `t_publicacao_municipios`
**Descrição:** Publicações específicas por município, permitindo gestão descentralizada.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `id_publicacao_municipio` | INTEGER | NOT NULL, DEFAULT nextval(...) | ID sequencial |
| `codmun` | VARCHAR | NOT NULL | Código do município |
| `nommun` | VARCHAR | NOT NULL | Nome do município |
| `id_classe_mapa` | VARCHAR | NOT NULL | Classe do mapa |
| `id_tipo_mapa` | VARCHAR | NOT NULL | Tipo do mapa |
| `id_ano` | VARCHAR | NOT NULL | Ano de referência |
| `globalid` | UUID | NOT NULL, DEFAULT gen_random_uuid() | GlobalID para ArcGIS |

**Registros:** 0+

---

### 2. Tabelas de Relacionamento

#### `t_classe_mapa_tipo_mapa`
**Descrição:** Relaciona classes com tipos de mapas (N:M).

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `id_classe_mapa` | VARCHAR | NOT NULL | Referencia t_classe_mapa |
| `id_tipo_mapa` | VARCHAR | NOT NULL | Referencia t_tipo_mapa |

**Registros:** 6

---

#### `t_regionalizacao_regiao`
**Descrição:** Relaciona tipos de regionalização com regiões (N:M).

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `id_tipo_regionalizacao` | VARCHAR | NOT NULL | Referencia t_tipo_regionalizacao |
| `id_regiao` | VARCHAR | NOT NULL | Referencia t_regiao |

**Registros:** 229

---

#### `t_tipo_tema_tema`
**Descrição:** Relaciona tipos de temas com temas específicos (N:M).

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `id_tipo_tema` | VARCHAR | NOT NULL | Referencia t_tipo_tema |
| `id_tema` | INTEGER | NOT NULL | Referencia t_tema |

**Registros:** 55

---

### 3. Tabelas de Attachments (Armazenamento de Arquivos)

#### `t_publicacao__attach`
**Descrição:** Armazena os arquivos PDF e documentos associados às publicações. Integração com SDE Attachments do ArcGIS.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `objectid` | INTEGER | NOT NULL, DEFAULT nextval('t_publicacao__attach_objectid_seq') | ID sequencial |
| `attachmentid` | INTEGER | NULL | ID do attachment |
| `globalid` | UUID | NOT NULL, DEFAULT gen_random_uuid() | GlobalID para ArcGIS |
| `rel_globalid` | UUID | NOT NULL | GlobalID da publicação relacionada |
| `content_type` | VARCHAR | NULL, DEFAULT 'application/pdf' | Tipo do conteúdo |
| `att_name` | VARCHAR | NOT NULL | Nome do arquivo |
| `data_size` | INTEGER | NOT NULL | Tamanho em bytes |
| `data` | BYTEA | NOT NULL | Conteúdo binário do arquivo |

**Registros:** 1+

---

#### `t_publicacao_municipios_attach`
**Descrição:** Armazena arquivos associados às publicações municipais.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|------------|-----------|
| `attachmentid` | INTEGER | NOT NULL | ID do attachment |
| `rel_globalid` | UUID | NOT NULL | GlobalID da publicação municipal |
| `content_type` | VARCHAR | NULL | Tipo do conteúdo |
| `att_name` | VARCHAR | NULL | Nome do arquivo |
| `data_size` | BIGINT | NULL | Tamanho em bytes |
| `data` | BYTEA | NULL | Conteúdo binário do arquivo |
| `globalid` | UUID | NOT NULL, DEFAULT gen_random_uuid() | GlobalID para ArcGIS |

**Registros:** 0+

---

## 🔧 Recursos Técnicos

### Características Especiais do Schema

#### **GlobalID e Integração ArcGIS**
- **GlobalID:** Campos UUID em tabelas de publicação para integração com ArcGIS
- **SDE Attachments:** Sistema de armazenamento de arquivos compatível com ESRI
- **Relacionamento:** Uso de `rel_globalid` para conectar attachments com publicações

#### **Armazenamento de Arquivos**
- **BYTEA:** Campo para armazenamento binário de PDFs e documentos
- **Metadata:** Campos para content_type, nome e tamanho dos arquivos
- **Performance:** Índices otimizados para consultas de attachments

### Índices Criados

#### Índices em Tabelas Principais
```sql
-- Performance em buscas por nome
CREATE INDEX idx_t_classe_mapa_nome ON t_classe_mapa(nome_classe_mapa);
CREATE INDEX idx_t_tipo_mapa_nome ON t_tipo_mapa(nome_tipo_mapa);
CREATE INDEX idx_t_regiao_nome ON t_regiao(nome_regiao);
CREATE INDEX idx_t_tema_nome ON t_tema(nome_tema);

-- Performance em buscas por código
CREATE INDEX idx_t_tema_codigo ON t_tema(codigo_tema);
CREATE INDEX idx_t_tipo_tema_codigo ON t_tipo_tema(codigo_tipo_tema);

-- Índices em municípios
CREATE INDEX idx_t_municipios_codmun ON t_municipios(codmun);
CREATE INDEX idx_t_municipios_nome ON t_municipios(nommun);
CREATE INDEX idx_t_municipios_regiao ON t_municipios(codigo_regiao) WHERE codigo_regiao IS NOT NULL;

-- Índices condicionais (apenas quando não NULL)
CREATE INDEX idx_t_regiao_abrangencia ON t_regiao(abrangencia) WHERE abrangencia IS NOT NULL;
```

#### Índices em Tabelas de Relacionamento
```sql
-- Otimização para joins frequentes
CREATE INDEX idx_t_regionalizacao_regiao ON t_regionalizacao_regiao(id_regiao);
CREATE INDEX idx_t_tipo_tema_tema_tema ON t_tipo_tema_tema(id_tema);
CREATE INDEX idx_t_classe_mapa_tipo_mapa_tipo ON t_classe_mapa_tipo_mapa(id_tipo_mapa);
```

#### Índices na Tabela Principal de Publicações
```sql
-- Índices compostos para filtros múltiplos
CREATE INDEX idx_t_publicacao_classe_tipo ON t_publicacao(id_classe_mapa, id_tipo_mapa);
CREATE INDEX idx_t_publicacao_regiao_ano ON t_publicacao(id_regiao, id_ano);
CREATE INDEX idx_t_publicacao_tema_tipo ON t_publicacao(id_tema, id_tipo_tema);
CREATE INDEX idx_t_publicacao_escala_cor ON t_publicacao(codigo_escala, codigo_cor);

-- Índices simples para buscas específicas
CREATE INDEX idx_t_publicacao_regionalizacao ON t_publicacao(id_tipo_regionalizacao);

-- Índice para GlobalID (performance no ArcGIS)
CREATE INDEX idx_t_publicacao_globalid ON t_publicacao(globalid);
```

#### Índices em Tabelas de Attachments
```sql
-- Performance em consultas de attachments
CREATE INDEX idx_t_publicacao_attach_rel_globalid ON t_publicacao__attach(rel_globalid);
CREATE INDEX idx_t_publicacao_attach_content_type ON t_publicacao__attach(content_type);
CREATE INDEX idx_t_publicacao_attach_name ON t_publicacao__attach(att_name);

-- Índice para GlobalID de relacionamento
CREATE INDEX idx_t_publicacao_municipios_attach_rel_globalid ON t_publicacao_municipios_attach(rel_globalid);
```

---

---

### Views Úteis

#### `vw_tema_completo`
Combina informações de temas com seus tipos:
```sql
SELECT t.*, tt.codigo_tipo_tema, tt.nome_tipo_tema
FROM t_tema t
JOIN t_tipo_tema_tema ttt ON t.id_tema = ttt.id_tema
JOIN t_tipo_tema tt ON ttt.id_tipo_tema = tt.id_tipo_tema;
```

#### `vw_regiao_completa`
Visualização completa de regiões com regionalizações:
```sql
SELECT r.*, tr.nome_tipo_regionalizacao
FROM t_regiao r
JOIN t_regionalizacao_regiao trr ON r.id_regiao = trr.id_regiao
JOIN t_tipo_regionalizacao tr ON trr.id_tipo_regionalizacao = tr.id_tipo_regionalizacao;
```

#### `vw_tipo_mapa_completo`
Informações completas de tipos e classes de mapas:
```sql
SELECT tm.*, cm.nome_classe_mapa
FROM t_tipo_mapa tm
JOIN t_classe_mapa_tipo_mapa cmtm ON tm.id_tipo_mapa = cmtm.id_tipo_mapa
JOIN t_classe_mapa cm ON cmtm.id_classe_mapa = cm.id_classe_mapa;
```

#### `vw_publicacao_completa`
Visualização completa de todos os dados das publicações:
```sql
SELECT
    p.id_publicacao,
    p.globalid,
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
```

#### `vw_publicacao_com_anexos`
Visualização de publicações com informações de anexos:
```sql
SELECT
    p.id_publicacao,
    p.globalid,
    cm.nome_classe_mapa,
    tm.nome_tipo_mapa,
    a.ano,
    r.nome_regiao,
    t.nome_tema,
    -- Informações de anexos
    COUNT(att.objectid) as quantidade_anexos,
    SUM(att.data_size) as tamanho_total_anexos,
    STRING_AGG(att.att_name, ', ') as nomes_anexos
FROM t_publicacao p
JOIN t_classe_mapa cm ON p.id_classe_mapa = cm.id_classe_mapa
JOIN t_tipo_mapa tm ON p.id_tipo_mapa = tm.id_tipo_mapa
JOIN t_anos a ON p.id_ano = a.id_ano
JOIN t_regiao r ON p.id_regiao = r.id_regiao
JOIN t_tema t ON p.id_tema = t.id_tema
LEFT JOIN t_publicacao__attach att ON p.globalid = att.rel_globalid
GROUP BY p.id_publicacao, p.globalid, cm.nome_classe_mapa, tm.nome_tipo_mapa,
         a.ano, r.nome_regiao, t.nome_tema;
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
| `t_regiao` | 106 | ~15KB | Excelente |
| `t_tema` | 55 | ~15KB | Excelente |
| `t_municipios` | 417 | ~50KB | Bom |
| `t_regionalizacao_regiao` | 229 | ~25KB | Bom |
| `t_tipo_tema_tema` | 55 | ~10KB | Excelente |
| Outras tabelas | <50 | <20KB | Excelente |
| **Tabelas de attachments** | Variável | Dinâmico | Depende do tamanho dos arquivos |

**Tempo estimado de consulta:**
- Lookups simples (dimensionais): <5ms
- Joins complexos: <50ms
- Consultas com filtros múltiplos: <100ms
- Consultas com attachments: <200ms (depende do tamanho)

**Otimizações Implementadas:**
- Índices específicos para GlobalID (integração ArcGIS)
- Índices compostos para filtros frequentes
- Índices condicionais para campos opcionais
- Estrutura otimizada para SDE Attachments

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
FROM t_tipo_tema tt
JOIN t_tipo_tema_tema ttt ON tt.id_tipo_tema = ttt.id_tipo_tema
JOIN t_tema t ON ttt.id_tema = t.id_tema
WHERE tt.codigo_tipo_tema = 'PA'
ORDER BY t.nome_tema;
```

### 2. Listar regiões por tipo de regionalização
```sql
SELECT
    tr.nome_tipo_regionalizacao,
    r.nome_regiao
FROM t_tipo_regionalizacao tr
JOIN t_regionalizacao_regiao trr ON tr.id_tipo_regionalizacao = trr.id_tipo_regionalizacao
JOIN t_regiao r ON trr.id_regiao = r.id_regiao
ORDER BY tr.nome_tipo_regionalizacao, r.nome_regiao;
```

### 3. Consultar municípios com informações territoriais
```sql
SELECT
    codmun,
    nommun,
    sigla_uf,
    nome_regiao,
    nome_territorio,
    ativo
FROM t_municipios
WHERE sigla_uf = 'BA'
AND ativo = true
ORDER BY nommun;
```

### 4. Combinação completa de classificações
```sql
SELECT
    cm.nome_classe_mapa,
    tm.nome_tipo_mapa,
    e.nome_escala,
    c.nome_cor,
    a.ano
FROM t_classe_mapa cm
JOIN t_classe_mapa_tipo_mapa cmtm ON cm.id_classe_mapa = cmtm.id_classe_mapa
JOIN t_tipo_mapa tm ON cmtm.id_tipo_mapa = tm.id_tipo_mapa
CROSS JOIN t_escala e
CROSS JOIN t_cor c
CROSS JOIN t_anos a;
```

### 5. Consultar publicações com filtros
```sql
-- Publicações por região e ano
SELECT
    p.id_publicacao,
    p.globalid,
    r.nome_regiao,
    a.ano,
    t.nome_tema,
    e.nome_escala
FROM t_publicacao p
JOIN t_regiao r ON p.id_regiao = r.id_regiao
JOIN t_anos a ON p.id_ano = a.id_ano
JOIN t_tema t ON p.id_tema = t.id_tema
JOIN t_escala e ON p.codigo_escala = e.codigo_escala
WHERE r.nome_regiao LIKE '%Bahia%'
AND a.ano >= 2020
ORDER BY a.ano DESC
```

### 6. Estatísticas de publicações por classificação
```sql
-- Contagem de publicações por tipo e classe
SELECT
    cm.nome_classe_mapa,
    tm.nome_tipo_mapa,
    COUNT(*) as total_publicacoes
FROM t_publicacao p
JOIN t_classe_mapa cm ON p.id_classe_mapa = cm.id_classe_mapa
JOIN t_tipo_mapa tm ON p.id_tipo_mapa = tm.id_tipo_mapa
GROUP BY cm.nome_classe_mapa, tm.nome_tipo_mapa
ORDER BY total_publicacoes DESC;
```

### 7. Publicações com anexos
```sql
-- Listar publicações com seus respectivos arquivos
SELECT
    p.id_publicacao,
    p.globalid,
    t.nome_tema,
    att.att_name as nome_arquivo,
    att.data_size as tamanho_bytes,
    att.content_type,
    CASE
        WHEN att.data_size < 1024 THEN att.data_size || ' bytes'
        WHEN att.data_size < 1048576 THEN ROUND(att.data_size/1024.0, 2) || ' KB'
        ELSE ROUND(att.data_size/1048576.0, 2) || ' MB'
    END as tamanho_formatado
FROM t_publicacao p
JOIN t_tema t ON p.id_tema = t.id_tema
JOIN t_publicacao__attach att ON p.globalid = att.rel_globalid
ORDER BY p.id_publicacao, att.att_name;
```

### 8. Publicações municipais
```sql
-- Publicações específicas por município
SELECT
    pm.id_publicacao_municipio,
    pm.globalid,
    pm.codmun,
    pm.nommun,
    cm.nome_classe_mapa,
    tm.nome_tipo_mapa,
    a.ano
FROM t_publicacao_municipios pm
JOIN t_municipios m ON pm.codmun = m.codmun
JOIN t_classe_mapa cm ON pm.id_classe_mapa = cm.id_classe_mapa
JOIN t_tipo_mapa tm ON pm.id_tipo_mapa = tm.id_tipo_mapa
JOIN t_anos a ON pm.id_ano = a.id_ano
WHERE pm.codmun LIKE '29%' -- Códigos de municípios da Bahia
ORDER BY pm.nommun, a.ano DESC;
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

- [x] **Estrutura Normalizada:** 3NF aplicada com 18 tabelas
- [x] **Integridade Referencial:** FKs implementadas em todas as tabelas relacionais
- [x] **Performance:** Índices otimizados incluindo GlobalID para ArcGIS
- [x] **Armazenamento de Arquivos:** Sistema SDE Attachments implementado
- [x] **GlobalID Integration:** UUIDs para integração com ESRI ArcGIS
- [x] **Municípios:** Cadastro completo com 417 municípios
- [x] **Publicações:** Sistema de publicações estaduais e municipais
- [x] **Attachments:** Tabelas específicas para gerenciamento de arquivos
- [x] **Documentação:** Comentários descritivos e views úteis
- [x] **Validação:** Restrições CHECK e UNIQUE
- [x] **Consistência:** Padrão de nomenclatura com prefixo `t_`
- [x] **Schema:** `dados_mapoteca` no database `mapoteca`

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
| 1.2 | 10/11/2025 | Removidos timestamps de todas as tabelas e triggers associadas para design limpo | BMad Master |
| 2.0 | 17/11/2025 | **Atualização Major com Schema JSON** - 18 tabelas totais, Sistema SDE Attachments, GlobalID, Municípios, Publicações | BMad System |

### Principais Mudanças v2.0:
- **Schema:** Renomeado para `dados_mapoteca` no database `mapoteca`
- **Nomenclatura:** Padrão `t_` para todas as tabelas
- **Novas Tabelas:** `t_municipios`, `t_publicacao`, `t_publicacao__attach`, `t_publicacao_municipios`, `t_publicacao_municipios_attach`
- **GlobalID:** Integração completa com ArcGIS via UUIDs
- **SDE Attachments:** Sistema de armazenamento de arquivos compatível com ESRI
- **Municípios:** Cadastro completo com 417 municípios e informações territoriais
- **Performance:** Índices otimizados para consultas com attachments e GlobalID
- **Views:** Novas views para publicações e anexos

---

*Este documento foi gerado automaticamente a partir da análise das planilhas Excel do projeto Mapoteca.*