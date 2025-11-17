# Sistema de Automação da Mapoteca Digital Product Requirements Document (PRD)

## Goals and Background Context

### Goals

- Automatizar completamente o processo de cadastro e publicação de mapas eliminando tarefas manuais de Excel/CSV
- Reduzir tempo de publicação de 30 minutos para 5 minutos por mapa (80% de redução)
- Eliminar 100% dos erros de digitação e formatação através de validação automática
- Manter total compatibilidade com as 4 aplicações existentes da Mapoteca Digital sem modificações
- Liberar 40% do tempo dos 2 técnicos especializados para atividades analíticas de maior valor

### Background Context

A Mapoteca Digital do SEIGEO atualmente depende de um processo manual baseado em planilhas Excel onde os 2 técnicos especializados gastam tempo significativo em tarefas repetitivas de cópia/cola para construção de URLs e organização de metadados. Este processo causa inconsistências, erros e consome recurso humano extremamente especializado que poderia ser dedicado à análise e curadoria do acervo. A infraestrutura tecnológica necessária (PostgreSQL, ArcGIS Enterprise, Experience Builder) já está disponível, mas não está sendo utilizada de forma integrada para automatizar o processo.

Este projeto visa transformar a Mapoteca Digital de sistema passivo para plataforma ativa através da criação de uma aplicação low-code em Experience Builder que substitui completamente o processo manual, mantendo total compatibilidade com as aplicações existentes enquanto oferece ganhos imediatos de produtividade e qualidade.

### Change Log

| Date | Version | Description | Author |
|------|---------|-------------|---------|
| 2025-10-15 | 1.0 | Initial PRD creation based on Project Brief | John (PM) |
| 2025-11-05 | 1.1 | Updated with ESRI ArcGIS Attachments functionality - PDF upload to PostgreSQL+SDE instead of fileserver URLs | Winston (Architect) |
| 2025-11-10 | 1.2 | Critical corrections to FR6 and FR7 - Updated FR6 to accurately describe 4 existing applications and FR7 to include all 6 publication types (4 existing + 2 new cartogram types) | System Admin |

---

## Requirements

### Functional

**FR1:** O sistema deve fornecer um formulário em Experience Builder para cadastro de novos mapas com campos para Tipo de Tema, Tema, escala e metadados básicos.

**FR2:** O sistema deve implementar dropdowns inteligentes com seleção em cascata baseada no dicionário de dados existente (Tipos de Tema → Temas específicos).

**FR3:** O sistema deve permitir upload direto de arquivos PDF através da funcionalidade Attachments do ArcGIS, armazenando os arquivos no banco de dados PostgreSQL com estrutura SDE, eliminando completamente o uso de fileserver e URLs externas.

**FR4:** O sistema deve gravar diretamente nas tabelas PostgreSQL substituindo completamente o processo de arquivos CSV.

**FR5:** O sistema deve fornecer validação em tempo real de campos obrigatórios, formatação e consistência dos dados antes da publicação.

**FR6:** O sistema deve garantir que as 4 aplicações existentes (Mapas Estaduais, Mapas Regionais, Mapas Municipais e Cartogramas Estaduais) continuem funcionando sem qualquer modificação.

**FR7:** O sistema deve suportar os 6 tipos de publicação: Mapas Estaduais, Mapas Regionais, Mapas Municipais, Cartogramas Estaduais, Cartogramas Municipais e Cartogramas Regionais.

**FR8:** O sistema deve permitir que técnicos visualizem editem e excluam registros existentes quando necessário.

**FR9:** O sistema deve manter histórico de publicações para auditoria e controle de versão.

**FR10:** O sistema deve permitir consulta e filtragem dos mapas publicados por tema escala e outros critérios.

**FR11:** O sistema deve implementar gestão de Attachments ESRI/ArcGIS com controle de versão múltiplos PDFs por mapa e metadados de anexo (nome do arquivo, tamanho, data de upload, usuário responsável).

**FR12:** O sistema deve permitir visualização inline dos PDFs diretamente na interface do Experience Builder sem necessidade de download ou abertura em aplicações externas.

**FR13:** O sistema deve implementar controle de acesso granular aos Attachments baseado nas permissões do ArcGIS Portal e nos metadados do mapa.

**FR14:** O sistema deve suportar substituição e remoção de PDFs existentes mantendo histórico das versões anteriores para auditoria.

### Non Functional

**NFR1:** O sistema deve carregar o formulário principal em menos de 3 segundos em navegadores modernos.

**NFR2:** O sistema deve processar e gravar novas publicações em menos de 1 segundo (metadados) e uploads de PDF até 50MB em menos de 30 segundos.

**NFR3:** O sistema deve manter uptime de 99.5% considerando a infraestrutura ArcGIS Enterprise existente.

**NFR4:** O sistema deve utilizar apenas widgets nativos do Experience Builder sem customização ou programação.

**NFR5:** O sistema deve aproveitar a autenticação e autorização existente do ArcGIS Portal sem novas implementações de segurança.

**NFR6:** O sistema deve ser responsivo e funcionar em navegadores modernos (Chrome, Firefox, Edge, Safari) em Windows e macOS.

**NFR7:** O sistema deve suportar múltiplos usuários simultâneos sem degradação de performance.

**NFR8:** O sistema deve manter integridade referencial dos dados garantindo consistência entre todas as tabelas relacionadas.

**NFR9:** O sistema deve permitir rollback das publicações em caso de erros detectados após a gravação.

**NFR10:** O sistema deve gerar logs de auditoria para todas as operações de criação edição e exclusão de registros.

**NFR11:** O sistema deve garantir integridade dos Attachments SDE com validação de arquivos PDF e detecção de corrupção durante upload e storage.

**NFR12:** O sistema deve suportar concorrência de uploads múltiplos sem corrupção de dados ou perda de attachments.

**NFR13:** O sistema deve implementar compressão otimizada de PDFs no PostgreSQL+SDE sem comprometer qualidade visual dos mapas.

**NFR14:** O sistema deve manter backup automático dos Attachments através das rotinas de backup existentes do PostgreSQL com validação periódica de integridade.

---

## User Interface Design Goals

### Overall UX Vision

Criar uma interface profissional e eficiente que se integre perfeitamente ao ecossistema ArcGIS existente, minimizando a curva de aprendizado enquanto maximiza a produtividade. A interface deve priorizar velocidade e precisão no processo de cadastro de mapas, reduzindo clicks e validando dados em tempo real para prevenir erros antes da publicação.

### Key Interaction Paradigms

- **Formulário guiado:** Fluxo linear com validação progressiva que guia o técnico através dos campos necessários
- **Seleção em cascata:** Dropdowns inteligentes onde a seleção de Tipo de Tema filtra automaticamente as opções de Tema disponíveis
- **Autocompletar:** Sugestões automáticas baseadas em publicações anteriores para acelerar entrada de dados repetitivos
- **Upload arrastar-e-soltar:** Interface de upload moderna com drag & drop, preview do PDF e barra de progresso em tempo real
- **Visualização inline:** Preview do PDF diretamente no formulário antes da gravação final
- **Gestão de múltiplos PDFs:** Suporte a múltiplos anexos por mapa com organização visual clara
- **Feedback visual:** Indicadores claros de status (validando, erro, sucesso) para cada campo e para o processo geral

### Core Screens and Views

- **Tela Principal de Cadastro:** Formulário completo com área de upload drag & drop para PDFs e todos os campos metadados
- **Tela de Gestão de Attachments:** Interface dedicada para visualizar, substituir, versionar e remover PDFs anexados
- **Tela de Visualização de PDF:** Viewer integrado para preview inline dos PDFs com zoom e navegação
- **Tela de Consulta/Edição:** Lista filtrável de publicações existentes com indicadores visuais de attachments e opções de gestão
- **Tela de Upload em Lote:** Funcionalidade para upload múltiplo de PDFs para diferentes mapas simultaneamente
- **Dashboard de Status:** Visão geral das publicações recentes, métricas de uso de storage e estatísticas de attachments

### Accessibility: WCAG AA

O sistema deve atender aos padrões WCAG AA para garantir acessibilidade, incluindo contraste adequado, navegação por teclado, e compatibilidade com leitores de tela. Considerando o ambiente governamental, acessibilidade é requisito obrigatório.

### Branding

Manter identidade visual consistente com o padrão SEIGEO/DIGEO, utilizando cores, tipografia e elementos de interface já estabelecidos nas aplicações existentes da Mapoteca Digital. A interface deve ser reconhecível como parte integrante do ecossistema geoespacial da organização.

### Target Device and Platforms: Web Responsive

A aplicação deve ser responsiva e funcionar otimamente em desktops e laptops onde os técnicos realizam seu trabalho diário. Compatibilidade com tablets como dispositivo secundário para consultas e validações em campo.

---

## Technical Assumptions

### Repository Structure: Monorepo

Este projeto não utilizará repositório de código tradicional por ser 100% baseado em configuração do Experience Builder. A "solução" consiste em configurações exportadas do Experience Builder que podem ser versionadas através do sistema de controle do ArcGIS Portal. Mudanças são rastreadas através do próprio Portal e backups de configuração.

### Service Architecture

**CRITICAL DECISION** - Arquitetura baseada em ESRI ArcGIS Attachments com PostgreSQL+SDE:

- **Frontend:** ArcGIS Experience Builder (widgets nativos + Attachment Widget)
- **Backend:** PostgreSQL com PostGIS e SDE (já provisionado)
- **Storage:** PDFs armazenados diretamente no PostgreSQL através da estrutura SDE
- **Conexão:** Conexão direta do Experience Builder ao PostgreSQL+SDE via ArcGIS Data Store
- **Attachments:** Utilização nativa da funcionalidade ESRI Attachments API
- **Apps existentes:** Continuam consumindo as mesmas tabelas PostgreSQL sem modificações + nova camada de attachments
- **Eliminação:** Total eliminação de fileserver e URLs externas

Esta arquitetura aproveita toda a infraestrutura ESRI existente (Attachments API, SDE, PostgreSQL) para fornecer storage nativo, gerenciamento automático de versões e controle de acesso integrado sem desenvolvimento customizado.

### Testing Requirements

**CRITICAL DECISION** - Estratégia de teste focada em configuração e dados:

- **Configuração:** Validação de widgets e Attachment Widget no Experience Builder (testes manuais)
- **Upload/Download:** Testes específicos de upload/download de PDFs via ESRI Attachments API
- **Dados:** Testes de integração com PostgreSQL+SDE usando dados reais + PDFs
- **Compatibilidade:** Validação dos 4 apps existentes apontando para novas tabelas + funcionalidade de attachments
- **Performance:** Testes de carga com volume real de publicações e uploads simultâneos de PDFs até 50MB
- **Storage:** Validação de integridade dos PDFs armazenados no PostgreSQL+SDE
- **Versionamento:** Testes de substituição e controle de versão dos attachments
- **Aceitação:** Testes com os 2 técnicos usuários finais em ambiente de produção + cenários reais de upload

Não haverá testes unitários automatizados por não haver código customizado. Foco em validação funcional, de integração e de performance de upload.

### Additional Technical Assumptions and Requests

- **PostgreSQL Schema:** Schema das tabelas deve espelhar exatamente estrutura dos CSVs atuais para garantir migração transparente + novas tabelas SDE para attachments + estrutura flexível para suportar os 6 tipos de publicação (Mapas Estaduais, Regionais, Municipais + Cartogramas Estaduais, Municipais, Regionais)
- **ArcGIS Data Store:** Deve ser configurado para permitir escrita do Experience Builder nas tabelas PostgreSQL + funcionalidade SDE para attachments
- **ESRI Attachments:** SDE (Spatial Database Engine) deve estar configurado para suportar attachments de feature classes com tipo de dado PDF
- **Permissões:** Os 2 técnicos terão permissões de escrita nas tabelas PostgreSQL + permissões de upload/download de attachments através do ArcGIS Portal
- **Storage Capacity:** PostgreSQL existente deve ter capacidade suficiente para armazenar PDFs considerando crescimento estimado do acervo (10GB ano 1, 50GB ano 5)
- **Backup:** Rotinas de backup existentes do PostgreSQL devem cobrir as novas tabelas + tabelas SDE de attachments (validação de recuperação obrigatória)
- **Performance:** Queries dos dropdowns não devem impactar performance das aplicações existentes + upload de PDFs não deve degradar performance geral do sistema
- **Versionamento:** Mudanças nos formulários do Experience Builder devem poder ser revertidas + versionamento automático dos attachments mantido pelo SDE
- **Monitoring:** Logs do ArcGIS Portal devem capturar operações de criação/edição + logs específicos de upload/download de attachments
- **Security:** Autenticação existente do ArcGIS Portal é suficiente para controle de acesso + controle de acesso específico para attachments baseado em permissões de feature class
- **Integrity:** Validação automática de integridade dos PDFs durante upload e periodicamente através de rotinas de checksum
- **Compression:** Configuração otimizada de compressão no PostgreSQL+SDE para balancear storage vs performance de acesso aos PDFs

---

## Epic List

### Epic 1: Foundation & Data Migration - Estabelecer base de dados e migração inicial

Estabelecer a infraestrutura PostgreSQL necessária e migrar dados existentes dos arquivos CSV para as novas tabelas, criando a base para toda a automação enquanto permite validação inicial do novo sistema com dados reais.

### Epic 2: ESRI Attachments Implementation - Implementar sistema de upload de PDFs com SDE

Configurar e implementar a funcionalidade completa de ESRI Attachments com PostgreSQL+SDE, incluindo upload/download de PDFs, gestão de versões, visualização inline e integração total com o Experience Builder, eliminando completamente dependência de fileserver.

### Epic 3: Core Form Development - Construir formulário principal de cadastro

Desenvolver o formulário principal em Experience Builder com todos os campos obrigatórios, dropdowns inteligentes, área de upload de PDFs e validações, entregando a funcionalidade central de automação que substitui completamente o processo manual de Excel.

### Epic 4: Integration & Compatibility - Garantir compatibilidade com apps existentes

Configurar as 4 aplicações existentes da Mapoteca Digital para consumirem as novas tabelas PostgreSQL + nova funcionalidade de attachments, validando que a automação não quebra nenhuma funcionalidade existente e entrega valor imediato aos usuários finais.

### Epic 5: Attachment Management & Optimization - Desenvolver gestão avançada de PDFs

Implementar funcionalidades avançadas de gestão de attachments como substituição de versões, visualização inline, controle de acesso granular, upload em lote e dashboard de storage, transformando o sistema em uma solução completa de gestão do acervo digital.