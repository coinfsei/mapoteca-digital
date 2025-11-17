# 🗺️ Feature Services Configuration - Mapoteca Digital

## 📋 Visão Geral

Este documento detalha a configuração dos Feature Services do ArcGIS para a Mapoteca Digital, incluindo a publicação das tabelas PostgreSQL e configuração de Attachments.

---

## 🎯 Objetivo dos Feature Services

Os Feature Services funcionam como a **camada de backend** do sistema, expondo as tabelas PostgreSQL através de APIs REST nativas do ArcGIS, permitindo:

- ✅ CRUD (Create, Read, Update, Delete) de registros
- ✅ Queries e filtros avançados
- ✅ Upload/download de attachments (PDFs)
- ✅ Autenticação integrada com ArcGIS Portal
- ✅ Versionamento e controle de transações

**IMPORTANTE:** NÃO criar API REST customizada. Usar Feature Services nativos do ArcGIS.

---

## 📊 Feature Services a Serem Criados

### 1. **FS_Mapoteca_Dominios** (Tabelas de Lookup)

**Propósito:** Fornecer dados de domínio para dropdowns e validações

**Feature Layers:**
```
├── t_classe_mapa              (2 registros)
├── t_tipo_mapa                (3 registros)
├── t_anos                     (33 registros)
├── t_escala                   (9 registros)
├── t_cor                      (2 registros)
├── t_tipo_tema                (6 registros)
├── t_tipo_regionalizacao      (11 registros)
├── t_regiao                   (106 registros)
└── t_tema                     (55 registros)
```

**Configurações:**
- **Capabilities:** Query, Sync
- **Max Records:** 1000
- **Allow Geometry Updates:** false (não espacial)
- **Enable Z Values:** false
- **Enable M Values:** false

**Índices Recomendados:**
```sql
-- Já criados no script 01-setup-schema-CORRECTED.sql
CREATE INDEX idx_t_classe_mapa_nome ON t_classe_mapa(nome_classe_mapa);
CREATE INDEX idx_t_tipo_mapa_nome ON t_tipo_mapa(nome_tipo_mapa);
CREATE INDEX idx_t_tema_codigo ON t_tema(codigo_tema);
```

---

### 2. **FS_Mapoteca_Relacionamentos** (Tabelas N:N)

**Propósito:** Validações em cascata para dropdowns

**Feature Layers:**
```
├── t_classe_mapa_tipo_mapa    (6 combinações válidas)
├── t_regionalizacao_regiao    (229 relacionamentos)
└── t_tipo_tema_tema           (55 relacionamentos)
```

**Configurações:**
- **Capabilities:** Query
- **Max Records:** 500
- **Allow Geometry Updates:** false

**Queries Importantes:**
```javascript
// Exemplo: Buscar tipos de mapa válidos para uma classe
where: "id_classe_mapa = '01'"
outFields: ["id_tipo_mapa"]

// Exemplo: Buscar temas válidos para um tipo de tema
where: "id_tipo_tema = 'TTM01'"
outFields: ["id_tema"]
```

---

### 3. **FS_Mapoteca_Municipios**

**Propósito:** Dados de municípios da Bahia

**Feature Layers:**
```
└── t_municipios               (417 registros)
```

**Configurações:**
- **Capabilities:** Query
- **Max Records:** 500
- **Allow Geometry Updates:** false
- **Definition Query:** `ativo = true` (apenas municípios ativos)

---

### 4. **FS_Mapoteca_Publicacoes** ⭐ PRINCIPAL

**Propósito:** Gestão de publicações (CRUD completo)

**Feature Layers:**
```
├── t_publicacao               (Estaduais/Regionais)
└── t_publicacao_municipios    (Municipais)
```

**Configurações:**
- **Capabilities:** Create, Delete, Query, Update, Editing, Sync
- **Max Records:** 2000
- **Allow Geometry Updates:** false
- **Enable Attachments:** **TRUE** ⚠️
- **Max Attachment Size:** 50 MB
- **Supported Attachment Types:** application/pdf

**GlobalID:** Obrigatório para Attachments
```sql
-- Já configurado no schema
globalid UUID NOT NULL DEFAULT uuid_generate_v4() UNIQUE
```

**Operações Suportadas:**
```javascript
// CREATE
POST /FS_Mapoteca_Publicacoes/0/addFeatures

// READ
GET /FS_Mapoteca_Publicacoes/0/query

// UPDATE
POST /FS_Mapoteca_Publicacoes/0/updateFeatures

// DELETE
POST /FS_Mapoteca_Publicacoes/0/deleteFeatures

// ATTACHMENTS
POST /FS_Mapoteca_Publicacoes/0/{objectId}/addAttachment
GET /FS_Mapoteca_Publicacoes/0/{objectId}/attachments
DELETE /FS_Mapoteca_Publicacoes/0/{objectId}/deleteAttachments
```

---

## 🔧 Configuração Passo a Passo

### Pré-requisitos

1. ✅ ArcGIS Enterprise 10.9+ ou ArcGIS Online
2. ✅ ArcGIS Server com licença Advanced
3. ✅ PostgreSQL 14+ com SDE instalado
4. ✅ Database Connection configurada no ArcGIS Pro
5. ✅ Usuário com permissão de publicação

---

### Passo 1: Registrar Database no ArcGIS Server

**Via ArcGIS Server Manager:**

```
1. Acessar: https://servidor:6443/arcgis/manager
2. Site → Data Store → Register Database
3. Configurar:
   - Name: mapoteca_db
   - Type: PostgreSQL
   - Server: 10.28.246.75
   - Database: mapoteca
   - Schema: dados_mapoteca
   - Authentication: Database
   - Username: dados_mapoteca
   - Password: [senha]
```

**Validar Conexão:**
```sql
-- Testar query no ArcGIS Server
SELECT COUNT(*) FROM dados_mapoteca.t_classe_mapa;
-- Deve retornar: 2
```

---

### Passo 2: Criar Feature Services no ArcGIS Pro

**1. Abrir ArcGIS Pro**

**2. Conectar ao PostgreSQL:**
```
Catalog Pane → Databases → New Database Connection
- Database Platform: PostgreSQL
- Instance: 10.28.246.75
- Authentication Type: Database authentication
- User name: dados_mapoteca
- Password: [senha]
- Database: mapoteca
```

**3. Adicionar Tabelas ao Mapa:**
```
Catalog → Database Connection → dados_mapoteca schema
Arrastar tabelas para o mapa (sem geometria - standalone tables)
```

**4. Configurar Propriedades das Tabelas:**

Para **t_publicacao**:
```
Right-click → Properties → General
- Enable Attachments: ✓
- GlobalID Field: globalid
- Attachment Table: t_publicacao__attach
- Relationship Class: rel_globalid
```

Para **t_publicacao_municipios**:
```
Right-click → Properties → General
- Enable Attachments: ✓
- GlobalID Field: globalid
- Attachment Table: t_publicacao_municipios_attach
- Relationship Class: rel_globalid
```

**5. Publicar Feature Service:**
```
Share → Web Layer → Publish Web Layer

Configuration:
- Name: FS_Mapoteca_Publicacoes
- Summary: Feature Service para gestão de publicações da Mapoteca Digital
- Tags: mapoteca, publicacoes, bahia, sei
- Layer Type: Feature
- Location: My Content (ou pasta específica)

Settings → Configuration:
✓ Feature Access
✓ Create, Delete, Query, Sync, Update, Editing
✓ Enable Attachments (para t_publicacao e t_publicacao_municipios)

Settings → Feature Access:
- Maximum Records: 2000
- Allow Geometry Updates: false

Settings → Attachments:
- Max Attachment Size: 50 MB
- Supported Types: application/pdf
```

---

### Passo 3: Configurar Relacionamentos para Attachments

**Criar Relationship Classes:**

```python
# Script Python no ArcGIS Pro
import arcpy

# Configurar workspace
arcpy.env.workspace = "Database Connections/mapoteca.sde"

# Criar relacionamento para publicações estaduais/regionais
arcpy.management.CreateRelationshipClass(
    origin_table="dados_mapoteca.t_publicacao",
    destination_table="dados_mapoteca.t_publicacao__attach",
    out_relationship_class="dados_mapoteca.t_publicacao__ATTACHREL",
    relationship_type="COMPOSITE",
    forward_label="Attachments",
    backward_label="Features",
    message_direction="FORWARD",
    cardinality="ONE_TO_MANY",
    origin_primary_key="globalid",
    origin_foreign_key="rel_globalid"
)

# Criar relacionamento para publicações municipais
arcpy.management.CreateRelationshipClass(
    origin_table="dados_mapoteca.t_publicacao_municipios",
    destination_table="dados_mapoteca.t_publicacao_municipios_attach",
    out_relationship_class="dados_mapoteca.t_publicacao_municipios__ATTACHREL",
    relationship_type="COMPOSITE",
    forward_label="Attachments",
    backward_label="Features",
    message_direction="FORWARD",
    cardinality="ONE_TO_MANY",
    origin_primary_key="globalid",
    origin_foreign_key="rel_globalid"
)

print("Relationship classes criadas com sucesso!")
```

---

### Passo 4: Configurar Permissões

**Via ArcGIS Portal:**

```
1. Acessar Feature Service publicado
2. Settings → Sharing
3. Configurar:
   - Share with: Organization (ou grupo específico)
   - Access: Editor (para os 2 técnicos)
   - Viewer: Everyone in Organization (para consultas)

4. Settings → Feature Layers → Editing
   - Allow editors to:
     ✓ Add features
     ✓ Delete features
     ✓ Update features
     ✓ Add, update, delete attachments
   - Track created and updated info: ✓
```

---

## 🧪 Testes de Validação

### Teste 1: Query Básico

```javascript
// Via ArcGIS REST API
https://servidor/arcgis/rest/services/FS_Mapoteca_Publicacoes/FeatureServer/0/query

Parâmetros:
{
  "where": "1=1",
  "outFields": "*",
  "returnGeometry": false,
  "f": "json"
}

// Deve retornar registros em JSON
```

### Teste 2: Validação em Cascata

```javascript
// Buscar tipos válidos para classe '01' (Mapa)
https://servidor/arcgis/rest/services/FS_Mapoteca_Relacionamentos/FeatureServer/0/query

Parâmetros:
{
  "where": "id_classe_mapa = '01'",
  "outFields": "id_tipo_mapa",
  "returnGeometry": false,
  "f": "json"
}

// Deve retornar: ['01', '02', '03'] (Estadual, Regional, Municipal)
```

### Teste 3: Upload de Attachment

```javascript
// Upload PDF para uma publicação
POST https://servidor/arcgis/rest/services/FS_Mapoteca_Publicacoes/FeatureServer/0/1/addAttachment

Form Data:
- attachment: [arquivo PDF, máx 50MB]
- f: json

// Deve retornar:
{
  "addAttachmentResult": {
    "objectId": 1,
    "globalId": "{UUID}",
    "success": true
  }
}
```

### Teste 4: Listar Attachments

```javascript
// Listar PDFs de uma publicação
GET https://servidor/arcgis/rest/services/FS_Mapoteca_Publicacoes/FeatureServer/0/1/attachments

// Deve retornar:
{
  "attachmentInfos": [
    {
      "id": 1,
      "name": "mapa_bahia_2024.pdf",
      "size": 5242880,
      "contentType": "application/pdf"
    }
  ]
}
```

---

## 📋 Checklist de Configuração

### Feature Services

- [ ] Database registrada no ArcGIS Server
- [ ] Conexão PostgreSQL testada e funcionando
- [ ] FS_Mapoteca_Dominios publicado (9 layers)
- [ ] FS_Mapoteca_Relacionamentos publicado (3 layers)
- [ ] FS_Mapoteca_Municipios publicado (1 layer)
- [ ] FS_Mapoteca_Publicacoes publicado (2 layers)

### Attachments

- [ ] Attachments habilitados em t_publicacao
- [ ] Attachments habilitados em t_publicacao_municipios
- [ ] GlobalIDs configurados corretamente
- [ ] Relationship classes criadas
- [ ] Tamanho máximo 50MB configurado
- [ ] Tipo permitido: application/pdf

### Testes

- [ ] Query básico funcionando
- [ ] Validação em cascata testada
- [ ] Upload de PDF testado (<50MB)
- [ ] Download de PDF testado
- [ ] Listagem de attachments testada
- [ ] Exclusão de attachment testada

### Segurança

- [ ] Permissões configuradas no Portal
- [ ] Editores (2 técnicos) identificados
- [ ] Viewers (organização) configurados
- [ ] Autenticação ArcGIS Enterprise ativa

---

## 🔗 URLs dos Feature Services

```
Base URL: https://servidor/arcgis/rest/services/

Feature Services:
├── FS_Mapoteca_Dominios/FeatureServer
├── FS_Mapoteca_Relacionamentos/FeatureServer
├── FS_Mapoteca_Municipios/FeatureServer
└── FS_Mapoteca_Publicacoes/FeatureServer
    ├── /0 (t_publicacao)
    └── /1 (t_publicacao_municipios)
```

---

## 📊 Queries Úteis para Experience Builder

### Carregar Dropdown de Classes
```javascript
const queryParams = {
  where: "1=1",
  outFields: ["id_classe_mapa", "nome_classe_mapa"],
  orderByFields: "id_classe_mapa",
  returnGeometry: false
};
```

### Validar Combinação Classe + Tipo
```javascript
const queryParams = {
  where: `id_classe_mapa = '${classeId}' AND id_tipo_mapa = '${tipoId}'`,
  outFields: ["id_classe_mapa"],
  returnGeometry: false
};
// Se returnCountOnly = 0, combinação inválida
```

### Carregar Temas por Tipo
```javascript
const queryParams = {
  where: `id_tipo_tema = '${tipoTemaId}'`,
  outFields: ["id_tema"],
  returnGeometry: false
};
// Usar resultado para filtrar dropdown de temas
```

---

## ⚠️ Troubleshooting

### Erro: "Unable to enable attachments"
**Causa:** GlobalID não configurado
**Solução:**
```sql
-- Adicionar GlobalID se não existir
ALTER TABLE t_publicacao
ADD COLUMN globalid UUID DEFAULT uuid_generate_v4() UNIQUE;
```

### Erro: "Attachment too large"
**Causa:** PDF > 50MB
**Solução:** Comprimir PDF ou dividir em partes

### Erro: "Invalid relationship"
**Causa:** rel_globalid não corresponde a globalid válido
**Solução:** Validar integridade referencial
```sql
SELECT * FROM vw_orphan_attachments;
```

---

**Versão:** 1.0
**Data:** 2025-11-17
**Próximo:** EXPERIENCE-BUILDER-CONFIG.md
**Status:** ✅ Pronto para Implementação
