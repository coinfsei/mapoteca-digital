```mermaid
erDiagram
    %% ============================================================================
    %% DIAGRAMA ER COMPLETO - MAPOTECA DIGITAL v2.0
    %% Schema: dados_mapoteca
    %% Database: mapoteca
    %% Data: 2025-11-17
    %% ============================================================================

    %% TABELAS DE DOMÍNIO (LOOKUP TABLES)

    t_classe_mapa {
        varchar id_classe_mapa PK
        varchar nome_classe_mapa NOT NULL
    }

    t_tipo_mapa {
        varchar id_tipo_mapa PK
        varchar nome_tipo_mapa NOT NULL
    }

    t_anos {
        varchar id_ano PK
        integer ano NOT NULL
    }

    t_regiao {
        varchar id_regiao PK
        varchar nome_regiao NOT NULL
        varchar abrangencia
    }

    t_escala {
        varchar codigo_escala PK
        varchar nome_escala NOT NULL
    }

    t_cor {
        varchar codigo_cor PK
        varchar nome_cor NOT NULL
    }

    t_tipo_regionalizacao {
        varchar id_tipo_regionalizacao PK
        varchar nome_tipo_regionalizacao NOT NULL
    }

    t_tema {
        integer id_tema PK
        varchar codigo_tema NOT NULL
        varchar nome_tema NOT NULL
    }

    t_tipo_tema {
        varchar id_tipo_tema PK
        varchar codigo_tipo_tema NOT NULL
        varchar nome_tipo_tema NOT NULL
    }

    t_municipios {
        varchar codmun PK
        varchar nommun NOT NULL
        varchar sigla_uf NOT NULL DEFAULT "BA"
        varchar nome_uf NOT NULL DEFAULT "Bahia"
        varchar codigo_regiao
        varchar nome_regiao
        varchar codigo_territorio
        varchar nome_territorio
        timestamp data_criacao
        timestamp data_atualizacao
        boolean ativo DEFAULT true
    }

    %% TABELAS DE RELACIONAMENTO N:N

    t_classe_mapa_tipo_mapa {
        varchar id_classe_mapa FK
        varchar id_tipo_mapa FK
    }

    t_regionalizacao_regiao {
        varchar id_tipo_regionalizacao FK
        varchar id_regiao FK
    }

    t_tipo_tema_tema {
        varchar id_tipo_tema FK
        integer id_tema FK
    }

    %% TABELAS DE PUBLICAÇÃO

    t_publicacao {
        integer id_publicacao PK
        varchar id_classe_mapa FK
        varchar id_tipo_mapa FK
        varchar id_ano FK
        varchar id_regiao FK
        varchar codigo_escala FK
        varchar codigo_cor FK
        varchar id_tipo_regionalizacao FK
        integer id_tema FK
        varchar id_tipo_tema FK
        uuid globalid UK
    }

    t_publicacao_municipios {
        integer id_publicacao_municipio PK
        varchar codmun FK
        varchar nommun NOT NULL
        varchar id_classe_mapa FK
        varchar id_tipo_mapa FK
        varchar id_ano FK
        uuid globalid UK
    }

    %% TABELAS DE ATTACHMENTS (SDE)

    t_publicacao__attach {
        integer objectid PK
        integer attachmentid
        uuid globalid UK
        uuid rel_globalid FK
        varchar content_type DEFAULT "application/pdf"
        varchar att_name NOT NULL
        integer data_size NOT NULL
        bytea data NOT NULL
    }

    t_publicacao_municipios_attach {
        integer attachmentid PK
        uuid rel_globalid FK
        varchar content_type
        varchar att_name
        bigint data_size
        bytea data
        uuid globalid UK
    }
    
    %% ========================================================================
    %% RELACIONAMENTOS N:N
    %% ========================================================================

    t_classe_mapa ||--o{ t_classe_mapa_tipo_mapa : "permite"
    t_tipo_mapa ||--o{ t_classe_mapa_tipo_mapa : "associa"

    t_tipo_tema ||--o{ t_tipo_tema_tema : "agrupa"
    t_tema ||--o{ t_tipo_tema_tema : "pertence"

    t_tipo_regionalizacao ||--o{ t_regionalizacao_regiao : "define"
    t_regiao ||--o{ t_regionalizacao_regiao : "faz_parte"

    %% ========================================================================
    %% RELACIONAMENTOS TABELAS DE PUBLICAÇÃO - DOMÍNIOS
    %% ========================================================================

    t_classe_mapa ||--o{ t_publicacao : "classifica"
    t_tipo_mapa ||--o{ t_publicacao : "define_tipo"
    t_anos ||--o{ t_publicacao : "ano_ref"
    t_regiao ||--o{ t_publicacao : "localiza"
    t_escala ||--o{ t_publicacao : "define_escala"
    t_cor ||--o{ t_publicacao : "coloriza"
    t_tipo_regionalizacao ||--o{ t_publicacao : "regionaliza"
    t_tema ||--o{ t_publicacao : "tematiza"
    t_tipo_tema ||--o{ t_publicacao : "tipo_tema"

    %% ========================================================================
    %% RELACIONAMENTOS PUBLICAÇÕES MUNICIPAIS
    %% ========================================================================

    t_classe_mapa ||--o{ t_publicacao_municipios : "classifica"
    t_tipo_mapa ||--o{ t_publicacao_municipios : "define_tipo"
    t_anos ||--o{ t_publicacao_municipios : "ano_ref"
    t_municipios ||--o{ t_publicacao_municipios : "municipio"

    %% ========================================================================
    %% RELACIONAMENTOS ATTACHMENTS (SDE)
    %% ========================================================================

    t_publicacao ||--o{ t_publicacao__attach : "anexa_pdf"
    t_publicacao_municipios ||--o{ t_publicacao_municipios_attach : "anexa_pdf"
```

---

# 📊 Legenda do Diagrama ER

## Convenções de Nomenclatura

### Prefixos de Tabelas
- **`t_`** - Tabelas (Padrão do schema `dados_mapoteca`)

### Sufixos de Campos
- **`PK`** - Primary Key (Chave Primária)
- **`FK`** - Foreign Key (Chave Estrangeira)
- **`UK`** - Unique Key (Chave Única)

## Tipos de Entidades

### 🏷️ Tabelas de Domínio (9 tabelas)
Armazenam os domínios e valores controlados do sistema:

1. **`t_classe_mapa`** - Mapa ou Cartograma (2 registros)
2. **`t_tipo_mapa`** - Estadual, Regional, Municipal (3 registros)
3. **`t_anos`** - Anos de referência (33 registros)
4. **`t_escala`** - Escalas cartográficas (9 registros)
5. **`t_cor`** - Colorido ou Preto e Branco (2 registros)
6. **`t_tipo_tema`** - Categorias de temas (6 registros)
7. **`t_tipo_regionalizacao`** - Tipos de divisão regional (11 registros)
8. **`t_regiao`** - Regiões geográficas (106 registros)
9. **`t_tema`** - Temas dos mapas (55 registros)

### 🏘️ Tabela de Municípios (1 tabela)
Cadastro territorial detalhado:

10. **`t_municipios`** - Municípios da Bahia (417 registros)

### 🔗 Tabelas de Relacionamento N:N (3 tabelas)
Gerenciam relacionamentos muitos-para-muitos:

11. **`t_classe_mapa_tipo_mapa`** - Combinações classe x tipo (6 registros)
12. **`t_regionalizacao_regiao`** - Regiões por tipo de regionalização (229 registros)
13. **`t_tipo_tema_tema`** - Temas por categoria (55 registros)

### 📄 Tabelas de Publicação (2 tabelas)
Armazenam as publicações de mapas:

14. **`t_publicacao`** - Publicações estaduais e regionais
15. **`t_publicacao_municipios`** - Publicações municipais

### 📎 Tabelas de Attachments (2 tabelas)
Armazenam arquivos PDF (SDE Attachments):

16. **`t_publicacao__attach`** - Anexos das publicações estaduais/regionais
17. **`t_publicacao_municipios_attach`** - Anexos das publicações municipais

## Cardinalidades dos Relacionamentos

| Símbolo | Significado | Exemplo |
|---------|-------------|---------|
| `\|\|--o{` | Um para muitos (1:N) | Um tema pode ter muitos mapas |
| `\|\|--\|\|` | Um para um (1:1) | Não usado neste modelo |
| `}o--o{` | Muitos para muitos (N:N) | Temas pertencem a múltiplos tipos |

## Estrutura Hierárquica

```
┌─────────────────────────────────────────────────────────┐
│                    PUBLICAÇÃO                            │
└────────────────────┬────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
   ┌────▼─────┐             ┌────▼────┐
   │  CLASSE  │             │  TIPO   │
   │  (O QUE) │             │ (ONDE)  │
   └────┬─────┘             └────┬────┘
        │                        │
   ┌────┴────┐          ┌────────┼────────┐
   │         │          │        │        │
  MAPA   CARTOGRAMA  ESTADUAL REGIONAL MUNICIPAL
```

## Fluxo de Dados

### 1. Cadastro de Nova Publicação
```
┌──────────────┐
│ Usuário      │
│ Experience   │
│ Builder      │
└──────┬───────┘
       │
       ▼
┌──────────────────┐
│ 1. Seleciona:    │
│    - Classe      │──────┐
│    - Tipo        │      │
│    - Tema        │      │
│    - Escala      │      │
│    - Ano         │      │
│    - Colorização │      │
└──────────────────┘      │
       │                  │
       ▼                  │
┌──────────────────┐      │
│ 2. Upload PDF    │      │
│    (Attachment   │      │
│     SDE)         │      │
└──────────────────┘      │
       │                  │
       ▼                  │
┌──────────────────┐      │
│ 3. Gravar em:    │      │
│    f_mapa_*      │◄─────┘
└──────┬───────────┘
       │
       ├────────────────────┐
       │                    │
       ▼                    ▼
┌──────────────┐   ┌──────────────────┐
│ h_publicacao │   │ m_attachment_    │
│ (Trigger     │   │ metadata         │
│  automático) │   │ (Metadados PDF)  │
└──────────────┘   └──────────────────┘
```

### 2. Consulta de Mapas (Experience Builder)
```
┌──────────────┐
│ Usuário      │
│ busca mapas  │
└──────┬───────┘
       │
       ▼
┌──────────────────────┐
│ Views de             │
│ Compatibilidade:     │
│                      │
│ - v_mapa_estadual    │
│ - v_mapa_regional    │
│ - v_mapa_municipal   │
│ - v_todos_mapas      │
└──────┬───────────────┘
       │
       │ JOIN com tabelas dimensionais
       │
       ▼
┌──────────────────────┐
│ Resultado com:       │
│ - Dados do mapa      │
│ - GlobalID           │
│ - Attachments        │
└──────────────────────┘
```

### 3. Dropdown em Cascata (Exemplo)
```
┌─────────────────────┐
│ 1. Seleciona        │
│    Tipo de Tema     │
│    [Meio Ambiente]  │
└──────┬──────────────┘
       │
       │ Query:
       │ SELECT tema 
       │ FROM d_tipo_tema_tema
       │ WHERE id_tipo_tema = ?
       │
       ▼
┌─────────────────────┐
│ 2. Dropdown Temas   │
│    [Bacias Hidro]   │
│    [Biomas]         │
│    [Flora Ameaçada] │
└─────────────────────┘
```

## Índices Principais

```sql
-- Índices para Performance de Dropdowns
idx_tipo_tema_tema_tipo     ON d_tipo_tema_tema(id_tipo_tema)
idx_tipo_tema_tema_tema     ON d_tipo_tema_tema(id_tema)
idx_tipo_reg_regiao_tipo    ON d_tipo_regionalizacao_regiao(id_tipo_regionalizacao)

-- Índices para Filtros Comuns
idx_estadual_ano            ON f_mapa_estadual(ano)
idx_estadual_tema           ON f_mapa_estadual(id_tema)
idx_estadual_publicado      ON f_mapa_estadual(publicado)

-- Índices para Attachments
idx_att_global_id           ON m_attachment_metadata(global_id)
idx_att_versao_atual        ON m_attachment_metadata(is_versao_atual)
idx_att_hash_md5            ON m_attachment_metadata(hash_md5)
```

## Triggers Automáticos

```sql
-- Auditoria (h_publicacao)
trg_audit_mapa_estadual     AFTER INSERT/UPDATE/DELETE ON f_mapa_estadual
trg_audit_mapa_regional     AFTER INSERT/UPDATE/DELETE ON f_mapa_regional
trg_audit_mapa_municipal    AFTER INSERT/UPDATE/DELETE ON f_mapa_municipal

-- Timestamp Automático
trg_update_timestamp_*      BEFORE UPDATE ON f_mapa_*
                           → Atualiza data_atualizacao
```

## Constraints Importantes

```sql
-- Chaves Únicas
uk_classe_codigo           UNIQUE (codigo_classe)
uk_tema_codigo             UNIQUE (codigo_tema)
uk_municipio_ibge          UNIQUE (codigo_ibge)

-- Check Constraints
ck_estadual_ano            CHECK (ano >= 1900 AND ano <= 2100)
ck_tipo_mapa_municipal     CHECK (tipo_mapa_municipal IN ('vigente', '2010'))
ck_att_tipo_entidade       CHECK (tipo_entidade IN ('estadual', 'regional', 'municipal'))
```

## Dados Iniciais

### Classes e Tipos
```
d_classe_mapa:
  01 - Mapa
  02 - Cartograma

d_tipo_mapa:
  01 - Estadual
  02 - Regional
  03 - Municipal

d_classe_mapa_tipo_mapa (6 combinações):
  Mapa + Estadual ✓
  Mapa + Regional ✓
  Mapa + Municipal ✓
  Cartograma + Estadual ✓
  Cartograma + Regional (novo)
  Cartograma + Municipal (novo)
```

### Domínios Principais
```
d_tipo_tema:        7 categorias
d_tema:            15 temas (expandível)
d_escala:           9 escalas
d_colorizacao:      2 tipos
d_tipo_regional:    6 tipos
d_regiao:          28+ regiões
d_municipio:      417 municípios
```

## Estatísticas Esperadas (Após Migração)

```
f_mapa_estadual:     225 Mapas + 88 Cartogramas = 313 registros
f_mapa_regional:      36 Mapas +  0 Cartogramas =  36 registros (+ novos)
f_mapa_municipal:    417 Mapas +  0 Cartogramas = 417 registros (+ novos)
                    ────────────────────────────────────────────────
TOTAL:                                             766 registros iniciais
```

## Observações Técnicas

### SDE Attachments
- **Feature Classes**: Criados via ArcGIS Pro/ArcMap
- **GlobalID**: Habilitado automaticamente nos feature classes
- **Tabelas SDE**: `*__ATTACH` criadas automaticamente ao habilitar attachments
- **Storage**: PDFs armazenados como BLOB no PostgreSQL

### Auditoria
- **Formato**: JSON (jsonb) para flexibilidade
- **Dados**: Estado completo antes/depois (row_to_json)
- **Trigger**: Automático em todas as operações
- **Retenção**: Sem prazo (histórico completo)

### Views de Compatibilidade
- Mantêm estrutura dos CSVs atuais
- Permitem que as 4 aplicações existentes funcionem sem modificação
- Incluem GlobalID para acesso aos attachments

## Características Técnicas

### GlobalID e Integração ArcGIS
- **UUID Fields:** `globalid` em tabelas de publicação para integração com ArcGIS
- **SDE Attachments:** Sistema de armazenamento compatível com ESRI
- **Relationships:** Uso de `rel_globalid` para conectar attachments

### Armazenamento de Arquivos
- **BYTEA:** Campo para armazenamento binário de PDFs
- **Metadata:** Campos para content_type, nome e tamanho dos arquivos
- **Performance:** Índices otimizados para consultas de attachments

### Estrutura de Dados
- **Schema:** `dados_mapoteca` no database `mapoteca`
- **Normalização:** 3NF aplicada
- **Integridade:** FKs implementadas com restrições apropriadas
- **Performance:** Índices otimizados para consultas frequentes

## Índices Principais

```sql
-- Performance em domínios
CREATE INDEX idx_t_tema_codigo ON t_tema(codigo_tema);
CREATE INDEX idx_t_tipo_tema_codigo ON t_tipo_tema(codigo_tipo_tema);
CREATE INDEX idx_t_municipios_codmun ON t_municipios(codmun);

-- Performance em relacionamentos N:N
CREATE INDEX idx_t_classe_mapa_tipo_mapa_tipo ON t_classe_mapa_tipo_mapa(id_tipo_mapa);
CREATE INDEX idx_t_tipo_tema_tema_tema ON t_tipo_tema_tema(id_tema);

-- Performance em publicações
CREATE INDEX idx_t_publicacao_classe_tipo ON t_publicacao(id_classe_mapa, id_tipo_mapa);
CREATE INDEX idx_t_publicacao_globalid ON t_publicacao(globalid);

-- Performance em attachments
CREATE INDEX idx_t_publicacao_attach_rel_globalid ON t_publicacao__attach(rel_globalid);
```

## Views Recomendadas

```sql
-- View completa de publicações
CREATE VIEW vw_publicacao_completa AS
SELECT p.*, cm.nome_classe_mapa, tm.nome_tipo_mapa, a.ano,
       r.nome_regiao, e.nome_escala, cor.nome_cor,
       tr.nome_tipo_regionalizacao, t.codigo_tema, t.nome_tema,
       tt.codigo_tipo_tema, tt.nome_tipo_tema
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

-- View de publicações com anexos
CREATE VIEW vw_publicacao_anexos AS
SELECT p.*, att.att_name, att.data_size, att.content_type
FROM t_publicacao p
JOIN t_publicacao__attach att ON p.globalid = att.rel_globalid;
```

---

**Versão:** 2.0
**Data:** 2025-11-17
**Database:** mapoteca
**Schema:** dados_mapoteca
**Total de Tabelas:** 18
**Total de Relacionamentos:** 25+
**PostgreSQL:** 14+
