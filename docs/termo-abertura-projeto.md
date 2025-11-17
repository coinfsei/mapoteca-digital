# 📋 Termo de Abertura do Projeto
## Sistema de Automação da Mapoteca Digital

**Data de Elaboração:** 14 de Novembro de 2025
**Versão:** 1.0
**Elaborado por:** John (Project Manager)
**Aprovado por:** [Preencher]
**Código do Projeto:** MAPOTECA-2025-001

---

## 🎯 1. Justificativa do Projeto

### 1.1 Contexto Atual
A Mapoteca Digital do SEIGEO atualmente opera com um processo manual baseado em planilhas Excel onde 2 técnicos especializados gastam tempo significativo em tarefas repetitivas de cópia/cola para construção de URLs e organização de metadados. Este processo causa:

- **Ineficiência Operacional:** 30 minutos por mapa para processamento manual
- **Riscos de Qualidade:** Erros consistentes de digitação e formatação
- **Ocupação de Recursos Especializados:** Técnicos altamente qualificados em tarefas de baixo valor agregado
- **Limitações de Escalabilidade:** Dificuldade para expandir o acervo de forma sustentável

### 1.2 Alinhamento Estratégico
Este projeto está alinhado com:
- **Objetivo Institucional:** Modernização de processos governamentais
- **Transformação Digital:** Adoção de tecnologias ESRI ArcGIS já disponíveis
- **Otimização de Recursos:** Realocação de pessoal especializado para atividades analíticas
- **Gestão do Conhecimento:** Preservação e organização do acervo cartográfico

### 1.3 Problema a Resolver
**Processo Manual Ineficiente** → **Sistema Automatizado Integrado**

---

## 🎯 2. Objetivos e Metas

### 2.1 Objetivo Principal
**Automatizar completamente o processo de cadastro e publicação de mapas** da Mapoteca Digital, eliminando tarefas manuais e maximizando a eficiência operacional.

### 2.2 Objetivos Específicos (SMART)

| Objetivo | Métrica | Meta | Prazo |
|----------|---------|------|-------|
| **Redução de Tempo** | Tempo por publicação | Reduzir de 30 min para 5 min | 80% |
| **Eliminação de Erros** | Taxa de erros de digitação | Reduzir para 0% | 100% |
| **Liberação de Recursos** | Tempo de técnicos disponível | Aumentar em 40% | Fase 2 |
| **Compatibilidade** | Apps funcionando sem modificações | Manter 100% | Immediate |
| **Performance** | Tempo de carregamento | < 3 segundos | NFR1 |

### 2.3 Metas de Negócio
- **Produtividade:** Capacidade de publicar 6x mais mapas no mesmo tempo
- **Qualidade:** Consistência e padronização completas dos metadados
- **Escalabilidade:** Sistema preparado para crescimento do acervo
- **Adoção:** Aceitação e uso pleno pelos 2 técnicos especializados

---

## 📋 3. Escopo Detalhado

### 3.1 Escopo Incluído (IN SCOPE)

#### **Epic 1: Foundation & Data Migration**
- [ ] Criação da estrutura PostgreSQL necessária
- [ ] Migração dos dados existentes dos arquivos CSV
- [ ] Validação inicial com dados reais

#### **Epic 2: ESRI Attachments Implementation**
- [ ] Configuração de ESRI Attachments com PostgreSQL+SDE
- [ ] Upload/download de PDFs
- [ ] Gestão de versões de anexos
- [ ] Visualização inline de PDFs
- [ ] Eliminação completa de fileserver

#### **Epic 3: Core Form Development**
- [ ] Formulário principal em Experience Builder
- [ ] Dropdowns inteligentes com seleção em cascata
- [ ] Área de upload de PDFs
- [ ] Validações em tempo real
- [ ] Substituição completa do processo Excel

#### **Epic 4: Integration & Compatibility**
- [ ] Configuração das 4 aplicações existentes
- [ ] Consumo das novas tabelas PostgreSQL
- [ ] Validação de compatibilidade
- [ ] Entrega de valor imediato aos usuários

#### **Epic 5: Attachment Management & Optimization**
- [ ] Funcionalidades avançadas de gestão de PDFs
- [ ] Substituição de versões
- [ ] Controle de acesso granular
- [ ] Upload em lote
- [ ] Dashboard de storage

### 3.2 Escopo Excluído (OUT OF SCOPE)

❌ **Modificações nas 4 aplicações existentes**
❌ **Desenvolvimento customizado (fora widgets nativos)**
❌ **Novas funcionalidades não relacionadas à automação**
❌ **Migração de outros sistemas para Mapoteca**
❌ **Desenvolvimento de aplicativos móveis**
❌ **Integração com sistemas externos**
❌ **Treinamento de usuários finais (apenas documentação)**

### 3.3 Requisitos Obrigatórios

#### **Funcionais (FR1-FR14)**
- Formulário Experience Builder completo
- Upload via ESRI Attachments
- Gravação direta em PostgreSQL
- Validação em tempo real
- Compatibilidade com 4 apps existentes
- Suporte a 6 tipos de publicação
- Gestão completa de PDFs

#### **Não Funcionais (NFR1-NFR14)**
- Performance: < 3 segundos carregamento
- Upload: < 30 segundos para 50MB
- Uptime: 99.5%
- Responsivo em navegadores modernos
- Uso apenas de widgets nativos
- Aproveitamento de autenticação existente

---

## 👥 4. Stakeholders e Papéis

### 4.1 Stakeholders Principais

| Nome | Papel | Interesses | Poder/Influência |
|------|-------|------------|-------------------|
| **Winston** | Arquiteto de Dados | Viabilidade técnica, qualidade | Alto |
| **John** | Gerente de Projeto | Entrega no prazo/orçamento | Alto |
| **System Admin** | Administrador do Sistema | Estabilidade, segurança | Médio |
| **Técnico 1** | Usuário Final | Facilidade de uso, produtividade | Médio |
| **Técnico 2** | Usuário Final | Eficiência, redução de erros | Médio |
| **Diretoria SEIGEO** | Sponsor | ROI, alinhamento estratégico | Alto |

### 4.2 Papéis e Responsabilidades

| Papel | Responsável | Principais Atividades |
|-------|-------------|-----------------------|
| **Project Manager** | John | Planejamento, controle, comunicação |
| **Technical Lead** | Winston | Arquitetura, desenvolvimento técnico |
| **Database Administrator** | System Admin | PostgreSQL, SDE, performance |
| **Business Analyst** | [A definir] | Requisitos, validação funcional |
| **Quality Assurance** | [A definir] | Testes, validação de qualidade |
| **End Users** | Técnicos 1 e 2 | Validação, aceite final |

### 4.3 Estrutura Organizacional

```
Diretoria SEIGEO (Sponsor)
    ↓
Gerente de Projeto (John)
    ├── Arquiteto de Dados (Winston)
    ├── Administrador do Sistema (System Admin)
    └── Usuários Finais (2 Técnicos)
```

---

## ⚠️ 5. Restrições e Premissas

### 5.1 Restrições (Constraints)

#### **Técnicas**
- ✅ **Plataforma:** 100% ArcGIS Experience Builder (widgets nativos)
- ✅ **Database:** PostgreSQL+SDE já provisionado
- ✅ **Integração:** Total compatibilidade com 4 apps existentes
- ✅ **Storage:** Eliminação completa de fileserver e URLs externas

#### **Organizacionais**
- ✅ **Recursos:** 2 técnicos especializados como usuários finais
- ✅ **Orçamento:** Aproveitamento de infraestrutura existente
- ✅ **Tempo:** Projeto deve entregar valor rapidamente

#### **Regulatórias**
- ✅ **Segurança:** Aproveitar autenticação ArcGIS Portal existente
- ✅ **Padrões:** Padrões WCAG AA para acessibilidade
- ✅ **Governo:** Conformidade com políticas de TI governamental

### 5.2 Premissas (Assumptions)

#### **Técnicas**
- ✅ ArcGIS Enterprise já está funcionando adequadamente
- ✅ PostgreSQL+SDE tem capacidade suficiente para storage
- ✅ Conexão entre Experience Builder e PostgreSQL é viável
- ✅ ESRI Attachments API suporta os requisitos de PDF

#### **Organizacionais**
- ✅ Os 2 técnicos estarão disponíveis para validação
- ✅ Sponsor terá autoridade para aprovar mudanças necessárias
- ✅ Recursos técnicos estarão disponíveis quando necessário

#### **Negócio**
- ✅ O processo atual é realmente manual e ineficiente
- ✅ A automação trará os benefícios esperados
- ✅ Usuários adotarão a nova solução

---

## 💰 6. Orçamento e Recursos

### 6.1 Estimativa de Esforço

| Epic | Dias Úteis | Recursos | Complexidade |
|------|------------|----------|--------------|
| Epic 1 - Foundation | 5 dias | DBA, Arquiteto | Média |
| Epic 2 - Attachments | 8 dias | Arquiteto, DBA | Alta |
| Epic 3 - Form Development | 6 dias | Developer, UX | Média |
| Epic 4 - Integration | 4 dias | Arquiteto, Tester | Média |
| Epic 5 - Optimization | 7 dias | Developer, DBA | Alta |
| **TOTAL** | **30 dias** | | |

### 6.2 Recursos Humanos

| Papel | Dedicção | Período | Custo Estimado |
|-------|----------|---------|----------------|
| Arquiteto de Dados | 50% | 6 semanas | [A definir] |
| Desenvolvedor ArcGIS | 70% | 4 semanas | [A definir] |
| DBA PostgreSQL | 30% | 6 semanas | [A definir] |
| QA Tester | 50% | 2 semanas | [A definir] |
| PM | 50% | 6 semanas | [A definir] |

### 6.3 Custos Diretos

- **Infraestrutura:** Aproveitamento (custo adicional zero)
- **Licenças:** ArcGIS já disponível (custo adicional zero)
- **Capacitação:** Documentação apenas (custo adicional mínimo)
- **Contingência:** 15% sobre recursos humanos

### 6.4 Análise de Viabilidade Econômica

#### **Investimento**
- **Desenvolvimento:** [valor a calcular]
- **Testes e Validação:** [valor a calcular]
- **Documentação:** [valor a calcular]

#### **Retorno**
- **Produtividade:** 80% de economia de tempo por mapa
- **Qualidade:** Eliminação 100% de erros manuais
- **Recursos:** 40% do tempo de técnicos liberado
- **Escalabilidade:** Capacidade de expansão sustentável

#### **Payback Estimado**
- **Período:** 3-6 meses
- **ROI:** [calcular baseado em economia de horas]

---

## ⏰ 7. Cronograma de Marco

### 7.1 Fases do Projeto

| Fase | Duração | Marco Principal | Status |
|------|---------|----------------|--------|
| **Planejamento** | 3 dias | Termo de Abertura Aprovado | ✅ Em Andamento |
| **Foundation** | 2 semanas | Database Migrado e Validado | 🔄 Pendente |
| **Development** | 3 semanas | Sistema Funcional | 🔄 Pendente |
| **Integration** | 1 semana | Apps Existentes Funcionando | 🔄 Pendente |
| **Testing** | 1 semana | Testes Concluídos | 🔄 Pendente |
| **Deployment** | 3 dias | Produção Ativa | 🔄 Pendente |
| **Closing** | 2 dias | Projeto Concluído | 🔄 Pendente |

### 7.2 Marcos Críticos (Milestones)

1. **M1 - Aprovação do Projeto:** [Data]
2. **M2 - Database Ready:** [+2 semanas]
3. **M3 - Core Functionality Working:** [+5 semanas]
4. **M4 - Integration Complete:** [+6 semanas]
5. **M5 - User Acceptance:** [+7 semanas]
6. **M6 - Go-Live:** [+8 semanas]
7. **M7 - Project Close:** [+8 semanas]

### 7.3 Dependencies

- **Críticas:** Disponibilidade do PostgreSQL+SDE
- **Externas:** Licenciamento ArcGIS válido
- **Recursos:** Disponibilidade dos técnicos para validação

---

## 🚨 8. Riscos e Mitigações

### 8.1 Análise de Riscos

| Risco | Probabilidade | Impacto | Estratégia de Mitigação |
|-------|---------------|---------|------------------------|
| **Problemas com ESRI Attachments** | Média | Alto | POC inicial, plano B de storage |
| **Incompatibilidade com Apps Existentes** | Baixa | Alto | Views de compatibilidade, teste cedo |
| **Performance Insuficiente** | Média | Médio | Índices otimizados, testes de carga |
| **Resistência dos Usuários** | Baixa | Médio | Envolvimento cedo, treinamento |
| **Problemas de Migração de Dados** | Média | Alto | Backup completo, validação rigorosa |
| **Indisponibilidade de Recursos** | Baixa | Alto | Planos de contingência, cross-training |

### 8.2 Planos de Contingência

#### **Contingência Técnica**
- **Storage Alternativo:** Fileserver temporário se Attachments falhar
- **Desenvolvimento Customizado:** Widget custom se nativos não suficientem
- **Rollback:** Manter processo atual em paralelo por 30 dias

#### **Contingência de Recursos**
- **Backup de Pessoal:** Cross-training entre equipe técnica
- **Recursos Externos:** Consultoria ESRI se necessário
- **Timeline Estendida:** Buffer de 20% no cronograma

---

## 📊 9. Critérios de Sucesso

### 9.1 Critérios de Sucesso do Projeto

#### **Métricas de Produto**
- [ ] **Performance:** Formulário carrega em < 3 segundos
- [ ] **Eficiência:** Publicação em < 5 minutos por mapa
- [ ] **Qualidade:** 0% erros de digitação/formatação
- [ ] **Compatibilidade:** 4 apps funcionando sem modificações

#### **Métricas de Projeto**
- [ ] **Cronograma:** Entrega dentro do prazo (±10%)
- [ ] **Orçamento:** Dentro do budget (±15%)
- [ ] **Escopo:** Todos requisitos entregues
- [ ] **Qualidade:** Todos testes aprovados

#### **Métricas de Adoção**
- [ ] **Uso:** 100% das publicações via novo sistema em 30 dias
- [ ] **Satisfação:** NPS > 8 dos usuários finais
- [ ] **Produtividade:** Aumento de 80% na velocidade de publicação

### 9.2 Fatores Críticos de Sucesso
1. **Alinhamento Técnico:** ESRI Attachments funcionando adequadamente
2. **Aceitação do Usuário:** Técnicos adotando nova solução
3. **Qualidade de Dados:** Migração bem-sucedida sem perdas
4. **Performance:** Sistema responsivo e eficiente
5. **Integração:** Apps existentes funcionando sem problemas

---

## ✅ 10. Aprovação

### 10.1 Assinaturas

| Nome | Papel | Assinatura | Data |
|------|-------|------------|------|
| **[Nome]** | Project Sponsor | | ____/____/2025 |
| **[Nome]** | Project Manager | | ____/____/2025 |
| **[Nome]** | Technical Lead | | ____/____/2025 |
| **[Nome]** | Business Owner | | ____/____/2025 |

### 10.2 Histórico de Mudanças

| Versão | Data | Mudança | Autor |
|--------|------|---------|-------|
| 1.0 | 14/11/2025 | Criação inicial do Termo de Abertura | John (PM) |
| | | | |

---

## 📎 11. Anexos

### 11.1 Documentos Referência
- Product Requirements Document (PRD) - `docs/prd.md`
- Briefing do Projeto - `docs/briefing.md`
- Data Architecture Redesign - `docs/data-architecture-redesign.md`
- Diagrama ER Completo - `docs/DIAGRAMA_ER_COMPLETO.md`

### 11.2 Templates e Formatos
- Matriz de RACI (a ser criada)
- Plano de Comunicação (a ser criado)
- Plano de Gerenciamento de Riscos (a ser criado)

---

**Status:** ✅ **EM APROVAÇÃO**
**Próximo Passo:** Apresentação ao Sponsor e stakeholders para aprovação formal
**Data Limite para Aprovação:** [Definir]

---

*Este documento constitui a autorização formal para iniciar o projeto Sistema de Automação da Mapoteca Digital.*