# Decisão 0010: Sistema de Agenda, Prazos Críticos e Agendamento via IA

### 1. Título
`Decisão 0010: Integração de Agenda Jurídica e Lembrete Proativo de Prazos`

### 2. Status
- **Activated**

### 3. Contexto
- **Problema:** O gerenciamento manual de prazos processuais gera estresse e risco de preclusão para os advogados. Além disso, alinhar horários disponíveis para reuniões com clientes demanda trocas sucessivas de mensagens no WhatsApp, consumindo tempo produtivo.
- **Alternativas Consideradas:** 
  1. *Integração com Google Calendar/Outlook externa:* Descartada para o MVP devido à complexidade de gerenciar múltiplos fluxos OAuth2 e o escopo de Single-Tenant/VM Única aprovado no [ADR-0006](0006-deploy-mvp-e-hardening.md).
  2. *Agenda nativa no próprio banco (PostgreSQL):* Mantém a coesão arquitetural, garante latência mínima para o RAG/IA consultar e facilita a aplicação direta do RBAC/Ownership local.
- **Limitações:** Necessidade de garantir que a IA não sofra com condições de corrida ao reservar slots e manter o sincronismo imediato com o app Flutter.

### 4. Decisão
- Criar a entidade de domínio `Appointment` nativa no PostgreSQL (driver `pg`), acessível via endpoints REST protegidos.
- Capacitar o assistente virtual (LangChain) no WhatsApp com uma tool específica para consultar `slots` livres e confirmar agendamentos de reuniões de forma autônoma.
- Implementar um *background worker* temporizado no servidor Node.js para monitorar compromissos do tipo `DEADLINE` e notificar o advogado via Firebase Cloud Messaging (FCM) com 24h de antecedência.
- **Justificativa:** Centraliza o ciclo de vida do cliente e do processo em uma única plataforma (Themis), reforçando a proposta de valor do sistema de eliminar ruídos na comunicação e reduzir a carga operacional do escritório.

### 5. Consequências
- **Positivas:**
  - Redução drástica da carga mental do advogado em relação a prazos.
  - Experiência "Uau" para o cliente final, que consegue marcar reuniões direto pelo WhatsApp de forma fluida.
  - Total rastreabilidade na Linha do Tempo do processo quando um evento é agendado.
- **Negativas:**
  - Maior responsabilidade do backend no gerenciamento de concorrência de horários.
  - O advogado precisará manter sua disponibilidade atualizada no aplicativo para evitar que a IA proponha horários onde ele tenha compromissos externos não cadastrados.
