# 🚀 Deployment Guide - Mapoteca Digital

## 📋 Visão Geral

Guia completo para deploy da Mapoteca Digital em ambiente de produção, cobrindo desde a instalação do banco de dados até a configuração do Experience Builder.

**Tempo total estimado:** 4-6 horas

---

## 🎯 Pré-requisitos

### Hardware Mínimo

**Servidor de Banco de Dados:**
- CPU: 4 cores
- RAM: 16 GB
- Disco: 100 GB SSD
- OS: Oracle Linux / RHEL / Ubuntu Server

**ArcGIS Enterprise:**
- CPU: 8 cores
- RAM: 32 GB
- Disco: 200 GB SSD
- OS: Windows Server 2019+ / RHEL 8+

### Software Necessário

- ✅ PostgreSQL 14+ com PostGIS
- ✅ ArcGIS Enterprise 10.9+ (Server + Portal + Data Store)
- ✅ ArcGIS Pro 3.0+ (para publicação)
- ✅ Experience Builder Developer Edition ou Online

### Licenças

- ✅ ArcGIS Enterprise Advanced
- ✅ Extensão Publisher (para publicação)
- ✅ Licenças nomeadas para 2 técnicos (Editor role)

### Acesso

- ✅ Credenciais de administrador PostgreSQL
- ✅ Credenciais de administrador ArcGIS Portal
- ✅ Acesso SSH ao servidor (10.28.246.75)
- ✅ Portas liberadas: 5432 (PostgreSQL), 6443 (ArcGIS Server), 7443 (Portal)

---

## 📦 FASE 1: Preparação do Banco de Dados

### Passo 1.1: Validar Ambiente PostgreSQL

```bash
# SSH no servidor
ssh dados_mapoteca@10.28.246.75

# Verificar versão do PostgreSQL
psql --version
# Deve retornar: PostgreSQL 14.x ou superior

# Verificar serviço
sudo systemctl status postgresql
```

### Passo 1.2: Criar Database e Schema

```bash
# Conectar como postgres
sudo -u postgres psql

# Criar database
CREATE DATABASE mapoteca
  WITH OWNER = dados_mapoteca
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       LC_COLLATE = 'pt_BR.UTF-8'
       LC_CTYPE = 'pt_BR.UTF-8'
       CONNECTION LIMIT = -1;

# Conectar ao database
\c mapoteca

# Verificar conexão
SELECT current_database();
```

### Passo 1.3: Executar Scripts SQL

```bash
# Fazer upload dos scripts para o servidor
scp scripts/00-validate-environment.sql dados_mapoteca@10.28.246.75:/tmp/
scp scripts/01-setup-schema-CORRECTED.sql dados_mapoteca@10.28.246.75:/tmp/
scp scripts/02-populate-data-CORRECTED.sql dados_mapoteca@10.28.246.75:/tmp/
scp scripts/03-indexes-constraints-CORRECTED.sql dados_mapoteca@10.28.246.75:/tmp/
scp scripts/04-esri-integration-CORRECTED.sql dados_mapoteca@10.28.246.75:/tmp/

# Executar scripts em ordem
psql -d mapoteca -U dados_mapoteca -f /tmp/00-validate-environment.sql
psql -d mapoteca -U dados_mapoteca -f /tmp/01-setup-schema-CORRECTED.sql
psql -d mapoteca -U dados_mapoteca -f /tmp/02-populate-data-CORRECTED.sql
psql -d mapoteca -U dados_mapoteca -f /tmp/03-indexes-constraints-CORRECTED.sql
psql -d mapoteca -U dados_mapoteca -f /tmp/04-esri-integration-CORRECTED.sql
```

### Passo 1.4: Validar Instalação

```sql
-- Conectar ao database
psql -d mapoteca -U dados_mapoteca

-- Verificar tabelas criadas (deve retornar 18)
SELECT COUNT(*) FROM information_schema.tables
WHERE table_schema = 'dados_mapoteca';

-- Verificar dados populados
SELECT 't_classe_mapa' as tabela, COUNT(*) as registros FROM t_classe_mapa
UNION ALL
SELECT 't_tipo_mapa', COUNT(*) FROM t_tipo_mapa
UNION ALL
SELECT 't_anos', COUNT(*) FROM t_anos
UNION ALL
SELECT 't_classe_mapa_tipo_mapa', COUNT(*) FROM t_classe_mapa_tipo_mapa;

-- Resultado esperado:
-- t_classe_mapa: 2
-- t_tipo_mapa: 3
-- t_anos: 33
-- t_classe_mapa_tipo_mapa: 6
```

**✅ Checklist Fase 1:**
- [ ] PostgreSQL 14+ instalado e rodando
- [ ] Database `mapoteca` criado
- [ ] Schema `dados_mapoteca` criado
- [ ] 18 tabelas criadas
- [ ] Dados iniciais populados
- [ ] Índices e constraints criados
- [ ] Validações rodando corretamente

---

## 🗺️ FASE 2: Configuração do ArcGIS Enterprise

### Passo 2.1: Registrar Database Connection

**Via ArcGIS Server Manager:**

```
1. Acessar: https://10.28.246.75:6443/arcgis/manager
2. Login: admin / [senha]
3. Site → Data Stores → Register Database

Configurações:
  - Data Store Name: mapoteca_db
  - Database Platform: PostgreSQL
  - Instance: 10.28.246.75
  - Database: mapoteca
  - User: dados_mapoteca
  - Password: [senha do usuário dados_mapoteca]
  - Schema: dados_mapoteca

4. Validate Connection
5. Save
```

**Testar Conexão:**
```sql
-- Via ArcGIS Server REST API
https://10.28.246.75:6443/arcgis/rest/services/System/PublishingTools/GPServer

-- Ou via SQL
SELECT * FROM dados_mapoteca.t_classe_mapa;
```

### Passo 2.2: Configurar Feature Services no ArcGIS Pro

**Abrir ArcGIS Pro:**

```
1. Abrir ArcGIS Pro 3.0+
2. Sign In com credenciais do Portal
3. New Project → Mapoteca_FeatureServices.aprx
```

**Criar Database Connection:**

```
Catalog Pane → Databases → New Database Connection

Configurações:
  - Database Platform: PostgreSQL
  - Instance: 10.28.246.75
  - Authentication: Database authentication
  - User name: dados_mapoteca
  - Password: [senha]
  - Database: mapoteca
  - Schema: dados_mapoteca

Save As: mapoteca_sde.sde
```

**Adicionar Tabelas ao Projeto:**

```
1. Catalog → mapoteca_sde.sde → dados_mapoteca

2. Arrastar tabelas para o mapa (como standalone tables):
   ✓ t_classe_mapa
   ✓ t_tipo_mapa
   ✓ t_anos
   ✓ t_escala
   ✓ t_cor
   ✓ t_tipo_tema
   ✓ t_tipo_regionalizacao
   ✓ t_regiao
   ✓ t_tema
   ✓ t_classe_mapa_tipo_mapa
   ✓ t_regionalizacao_regiao
   ✓ t_tipo_tema_tema
   ✓ t_municipios
   ✓ t_publicacao (⚠️ habilitar attachments)
   ✓ t_publicacao_municipios (⚠️ habilitar attachments)
```

**Configurar Attachments em t_publicacao:**

```
1. Right-click t_publicacao → Properties
2. General Tab:
   ✓ Enable Attachments
   - GlobalID Field: globalid
   - Attachment Table: t_publicacao__attach
   - Relationship Field: rel_globalid
3. Apply
```

**Configurar Attachments em t_publicacao_municipios:**

```
1. Right-click t_publicacao_municipios → Properties
2. General Tab:
   ✓ Enable Attachments
   - GlobalID Field: globalid
   - Attachment Table: t_publicacao_municipios_attach
   - Relationship Field: rel_globalid
3. Apply
```

### Passo 2.3: Publicar Feature Services

**Publicar FS_Mapoteca_Dominios:**

```
1. Select tables: t_classe_mapa, t_tipo_mapa, t_anos, t_escala,
                  t_cor, t_tipo_tema, t_tipo_regionalizacao,
                  t_regiao, t_tema

2. Share → Web Layer → Publish Web Layer

Configuration:
  - Name: FS_Mapoteca_Dominios
  - Summary: Tabelas de domínio para dropdowns
  - Tags: mapoteca, dominios, lookup
  - Layer Type: Feature
  - Location: My Content / Mapoteca

Settings:
  ✓ Feature Access
  Capabilities: Query, Sync
  Max Records: 1000
  Allow Geometry Updates: false

3. Analyze → Publish
```

**Publicar FS_Mapoteca_Relacionamentos:**

```
1. Select tables: t_classe_mapa_tipo_mapa,
                  t_regionalizacao_regiao,
                  t_tipo_tema_tema

2. Share → Web Layer → Publish Web Layer

Configuration:
  - Name: FS_Mapoteca_Relacionamentos
  - Summary: Tabelas N:N para validações em cascata
  - Tags: mapoteca, relacionamentos, validacoes
  - Layer Type: Feature

Settings:
  ✓ Feature Access
  Capabilities: Query
  Max Records: 500

3. Analyze → Publish
```

**Publicar FS_Mapoteca_Publicacoes:** ⭐

```
1. Select tables: t_publicacao, t_publicacao_municipios

2. Share → Web Layer → Publish Web Layer

Configuration:
  - Name: FS_Mapoteca_Publicacoes
  - Summary: Gestão de publicações com Attachments
  - Tags: mapoteca, publicacoes, crud
  - Layer Type: Feature

Settings:
  ✓ Feature Access
  ✓ Enable Attachments (IMPORTANTE!)
  Capabilities: Create, Delete, Query, Update, Editing, Sync
  Max Records: 2000
  Max Attachment Size: 50 MB
  Supported Types: application/pdf

3. Analyze → Publish
```

### Passo 2.4: Configurar Permissões

```
1. Acessar Portal: https://portal.arcgis.com
2. Content → My Content → FS_Mapoteca_Publicacoes
3. Settings → Sharing:
   - Share with: Organization
   - Access Level:
     • Editors: grupo_mapoteca_editores (2 técnicos)
     • Viewers: Everyone in Organization

4. Settings → Feature Layer → Editing:
   ✓ Allow editors to add features
   ✓ Allow editors to delete features
   ✓ Allow editors to update features
   ✓ Allow editors to add/update/delete attachments
   ✓ Track who created and last updated features
```

**✅ Checklist Fase 2:**
- [ ] Database Connection registrada no ArcGIS Server
- [ ] Feature Services publicados (3 services)
- [ ] Attachments habilitados em t_publicacao
- [ ] Attachments habilitados em t_publicacao_municipios
- [ ] Permissões configuradas
- [ ] Testado via REST API

---

## 🎨 FASE 3: Configuração do Experience Builder

### Passo 3.1: Criar Novo Experience

```
1. Acessar: https://experience.arcgis.com
2. Create New → Blank (ou partir de template)
3. Name: Mapoteca Digital - Cadastro
4. Tags: mapoteca, cadastro, sei
5. Summary: Sistema de cadastro de mapas da Mapoteca Digital
```

### Passo 3.2: Configurar Data Sources

```
1. Data → Add Data
2. Search for:
   ✓ FS_Mapoteca_Dominios
   ✓ FS_Mapoteca_Relacionamentos
   ✓ FS_Mapoteca_Publicacoes
3. Add All
```

### Passo 3.3: Layout Principal

```
1. Drag widgets:
   - Header (top)
   - List (left, 30% width)
   - Form (center, 50% width)
   - Attachment (bottom of form)
   - Button Group (bottom)

2. Configure layout:
   - Enable responsive design
   - Set breakpoints: 1024px, 768px, 480px
```

### Passo 3.4: Configurar Form Widget

**Consultar:** `docs/EXPERIENCE-BUILDER-CONFIG.md` para configuração completa

**Campos obrigatórios:**
```
1. id_classe_mapa (dropdown)
2. id_tipo_mapa (dropdown com validação)
3. id_ano (dropdown)
4. id_tipo_regionalizacao (dropdown)
5. id_regiao (dropdown em cascata)
6. id_tipo_tema (dropdown)
7. id_tema (dropdown em cascata)
8. codigo_escala (dropdown)
9. codigo_cor (dropdown)
```

### Passo 3.5: Configurar Validações

**Consultar:** `docs/VALIDATIONS-LOGIC.md` para lógica completa

**Implementar:**
1. ✅ Validação Classe + Tipo
2. ✅ Cascata Tipo Regionalização → Região
3. ✅ Cascata Tipo Tema → Tema
4. ✅ Validação de PDF (tipo, tamanho)

### Passo 3.6: Configurar Attachment Widget

```
Settings:
  ✓ Allow Add: true
  ✓ Allow Delete: true
  ✓ Allow Edit: false
  ✓ Drag and Drop: true
  ✓ Show Preview: true
  ✓ Inline Viewer: true
  Max File Size: 52428800 (50MB)
  Supported Types: ['application/pdf']
```

### Passo 3.7: Publicar Experience

```
1. Settings → General:
   - Name: Mapoteca Digital
   - URL: /mapoteca-cadastro
   - Thumbnail: [upload logo]

2. Settings → Sharing:
   ✓ Share with Organization
   Access: grupo_mapoteca_editores

3. Save → Publish
```

**✅ Checklist Fase 3:**
- [ ] Experience criado
- [ ] Data Sources conectados
- [ ] Form Widget configurado
- [ ] Validações implementadas
- [ ] Attachment Widget configurado
- [ ] Experience publicado
- [ ] URL acessível

---

## 🧪 FASE 4: Testes de Integração

### Teste 1: CRUD de Publicação

```
1. Acessar: https://experience.arcgis.com/mapoteca-cadastro
2. Login com usuário editor
3. Preencher formulário completo
4. Upload de PDF (10MB)
5. Salvar
6. Verificar:
   ✓ Registro criado em t_publicacao
   ✓ PDF salvo em t_publicacao__attach
   ✓ GlobalID relacionado corretamente
   ✓ Lista atualizada
```

### Teste 2: Validações em Cascata

```
1. Selecionar Classe: Mapa (01)
2. Selecionar Tipo: Municipal (03)
3. Verificar: Aceito (combinação válida)
4. Selecionar Classe: Mapa (01)
5. Selecionar Tipo: [tipo inválido]
6. Verificar: Erro mostrado + campo limpo
```

### Teste 3: Upload de Attachment

```
1. Selecionar PDF válido (5MB)
2. Verificar: Upload com sucesso
3. Selecionar PDF grande (60MB)
4. Verificar: Erro "Arquivo muito grande"
5. Selecionar arquivo .docx
6. Verificar: Erro "Apenas PDFs permitidos"
```

### Teste 4: Compatibilidade com Apps Existentes

```
1. Acessar: App Mapas Estaduais
2. Verificar: Dados visíveis
3. Acessar: App Mapas Regionais
4. Verificar: Dados visíveis
5. Acessar: App Mapas Municipais
6. Verificar: Dados visíveis
7. Acessar: App Cartogramas Estaduais
8. Verificar: Dados visíveis
```

**✅ Checklist Fase 4:**
- [ ] CRUD funcionando
- [ ] Validações em cascata OK
- [ ] Upload de PDF OK
- [ ] Download de PDF OK
- [ ] 4 apps existentes funcionando
- [ ] Performance < 3s carregamento
- [ ] Performance < 1s salvamento

---

## 📊 FASE 5: Monitoramento e Manutenção

### Configurar Monitoramento

**PostgreSQL:**
```sql
-- Criar view de monitoramento
CREATE VIEW vw_monitor_storage AS
SELECT
    'Publicações Estaduais/Regionais' as tipo,
    COUNT(*) as total_publicacoes,
    (SELECT COUNT(*) FROM t_publicacao__attach) as total_attachments,
    pg_size_pretty(SUM(data_size)) as storage_usado
FROM t_publicacao
UNION ALL
SELECT
    'Publicações Municipais',
    COUNT(*),
    (SELECT COUNT(*) FROM t_publicacao_municipios_attach),
    pg_size_pretty(SUM(data_size))
FROM t_publicacao_municipios;
```

**ArcGIS Server:**
```
1. Server Manager → Logs
2. Configure log level: INFO
3. Monitor:
   - Request count
   - Response time
   - Error rate
```

### Backup Automático

```bash
# Criar script de backup
#!/bin/bash
# /opt/scripts/backup-mapoteca.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup/mapoteca"
DB="mapoteca"
USER="dados_mapoteca"

# Backup do database
pg_dump -U $USER -d $DB -F c -f $BACKUP_DIR/mapoteca_$DATE.dump

# Backup dos attachments (apenas estrutura, dados já no DB)
psql -U $USER -d $DB -c "\
COPY (SELECT * FROM dados_mapoteca.vw_attachment_stats) \
TO '$BACKUP_DIR/attachments_stats_$DATE.csv' CSV HEADER;"

# Manter últimos 30 dias
find $BACKUP_DIR -name "*.dump" -mtime +30 -delete

echo "Backup concluído: $DATE"
```

**Agendar via cron:**
```bash
# Executar backup diário às 2h
0 2 * * * /opt/scripts/backup-mapoteca.sh
```

---

## 📋 Checklist Final de Deploy

### Database
- [ ] PostgreSQL 14+ instalado
- [ ] Database `mapoteca` criado
- [ ] Schema `dados_mapoteca` com 18 tabelas
- [ ] Dados iniciais populados
- [ ] Índices e constraints criados
- [ ] Backup configurado

### ArcGIS Enterprise
- [ ] Database Connection registrada
- [ ] Feature Services publicados
- [ ] Attachments habilitados
- [ ] Permissões configuradas
- [ ] Testado via REST API

### Experience Builder
- [ ] Experience criado e publicado
- [ ] Form Widget configurado
- [ ] Validações implementadas
- [ ] Attachment Widget configurado
- [ ] URL acessível

### Testes
- [ ] CRUD completo testado
- [ ] Validações em cascata OK
- [ ] Upload/download de PDF OK
- [ ] 4 apps existentes funcionando
- [ ] Performance OK (<3s / <1s)

### Produção
- [ ] Monitoramento configurado
- [ ] Backup automático ativo
- [ ] Logs habilitados
- [ ] Documentação atualizada
- [ ] Usuários treinados

---

## 📞 Suporte e Contatos

**Equipe Técnica:**
- DBA: [nome] - [email]
- ArcGIS Admin: [nome] - [email]
- Suporte: [email-suporte]

**Documentação:**
- Feature Services: `docs/FEATURE-SERVICES-CONFIG.md`
- Experience Builder: `docs/EXPERIENCE-BUILDER-CONFIG.md`
- Validações: `docs/VALIDATIONS-LOGIC.md`
- Migration Guide: `MIGRATION-GUIDE.md`

---

**Versão:** 1.0
**Data:** 2025-11-17
**Status:** ✅ Pronto para Deploy
