# Briefing do Projeto: Sistema de Automação da Mapoteca Digital

## Visão Geral

Este projeto tem como objetivo automatizar completamente o processo de cadastro e publicação de mapas da Mapoteca Digital do SEIGEO, substituindo o trabalho manual baseado em planilhas Excel por uma solução low-code integrada com o ecossistema ArcGIS existente.

## Problema Atual

Atualmente, 2 técnicos especializados gastam tempo significativo em tarefas repetitivas de cópia/cola de planilhas Excel para construção de URLs e organização de metadados. Este processo manual:

- Consome 30 minutos por mapa
- Gera inconsistências e erros de digitação/formatação
- Ocupa recurso humano extremamente especializado que poderia dedicar-se à análise e curadoria

## Solução Proposta

Desenvolvimento de uma aplicação low-code em ArcGIS Experience Builder que:

- Reduz tempo de publicação de 30 minutos para 5 minutos por mapa (80% de redução)
- Elimina 100% dos erros de digitação através de validação automática
- Mantém total compatibilidade com as 4 aplicações existentes
- Libera 40% do tempo dos técnicos para atividades analíticas

## Principais Funcionalidades

### 1. Sistema de Cadastro
- Formulário em Experience Builder com campos para Tipo de Tema, Tema, escala e metadados
- Dropdowns inteligentes com seleção em cascata
- Upload direto de arquivos PDF via ESRI Attachments
- Validação em tempo real de dados

### 2. Gestão de PDFs
- Armazenamento direto no PostgreSQL com estrutura SDE
- Visualização inline de PDFs sem download necessário
- Controle de versão e substituição de arquivos
- Upload arrastar-e-soltar

### 3. Suporte a Aplicações
- Compatibilidade total com as 4 aplicações existentes:
  - Mapas Estaduais
  - Mapas Regionais
  - Mapas Municipais
  - Cartogramas Estaduais
- Suporte a 2 novos tipos: Cartogramas Municipais e Regionais

### 4. Gestão de Dados
- Edição e exclusão de registros
- Histórico de publicações para auditoria
- Consulta e filtragem avançada
- Logs de auditoria completos

## Requisitos Técnicos

### Performance
- Carregamento do formulário em < 3 segundos
- Processamento de publicações em < 1 segundo
- Upload de PDFs até 50MB em < 30 segundos
- Uptime de 99.5%

### Plataforma
- Frontend: ArcGIS Experience Builder (widgets nativos)
- Backend: PostgreSQL com PostGIS e SDE (já provisionado)
- Storage: PDFs em PostgreSQL via estrutura SDE
- Sem dependência de fileserver ou URLs externas

### Acessibilidade
- Padrões WCAG AA
- Navegação por teclado
- Compatibilidade com leitores de tela

## Epic Principais

1. **Foundation & Data Migration**: Estrutura PostgreSQL e migração de dados CSV
2. **ESRI Attachments Implementation**: Sistema completo de upload/Download de PDFs
3. **Core Form Development**: Formulário principal substituindo processo Excel
4. **Integration & Compatibility**: Garantir funcionamento dos 4 apps existentes
5. **Attachment Management & Optimization**: Gestão avançada de PDFs

## Benefícios Esperados

- **Produtividade**: 80% de redução no tempo por mapa
- **Qualidade**: Eliminação completa de erros manuais
- **Recursos**: 40% do tempo dos técnicos liberado para análise
- **Escalabilidade**: Sistema preparado para crescimento do acervo
- **Integração**: Solução 100% compatível com infraestrutura existente

## Público-Alvo

- **Primário**: 2 técnicos especializados responsáveis pelo cadastro atual
- **Secundário**: Usuários finais das 4 aplicações existentes da Mapoteca
- **Terciário**: Equipe de TI responsável pela manutenção do sistema

## Cronograma Estimado

O projeto está dividido em 5 épics, com foco principal nas funcionalidades críticas de automação e compatibilidade, podendo ser entregue em fases para garantir valor contínuo aos usuários.

## Budget

Aproveita toda infraestrutura ArcGIS existente (PostgreSQL, ArcGIS Enterprise, Experience Builder), sendo necessários apenas recursos para configuração, migração de dados e implementação das novas funcionalidades.