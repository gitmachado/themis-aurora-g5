# 📊 RELATÓRIO COMPLETO: Fluxo de Agenda desde a IA

**Data**: 2026-05-14  
**Status**: ✅ IMPLEMENTADO COM LIMITAÇÕES  
**Versão**: G5-79 + Approval Workflow

---

## 1. VISÃO GERAL DO FLUXO

```
Cliente → WhatsApp → IA (LangGraph) → DECISION TREE
                        ↓
    ┌────────────────────┼────────────────────┐
    ↓                    ↓                     ↓
[Triagem]         [Consulta Info]      [AGENDAR REUNIÃO]
    ↓                    ↓                     ↓
Backend Triagem   Knowledge RAG        Tool: agendar_compromisso
    ↓                    ↓                     ↓
Lead Created      Context Returned    Backend API: POST /appointments
                                             ↓
                               Appointment criado (PENDING_APPROVAL)
                                             ↓
                               Cliente notificado no WhatsApp
                                             ↓
                          [NOVO] Advogado aprova/rejeita
                                             ↓
                          Status → SCHEDULED / CANCELADO
```

---

## 2. TOOLS DISPONÍVEIS PARA A IA

### 📋 Lista de Tools

| Tool | Nome no LangChain | Status | Descrição |
|------|-------------------|--------|-----------|
| **agendar_compromisso** | `appointmentTool` | ✅ Ativo | Verifica disponibilidade + agenda reuniões |
| **ativar_atendimento_humano** | `handoffTool` | ✅ Ativo | Transfere para advogado humano |
| **consultar_processos** | `processStatusTool` | ✅ Ativo | Retorna status de processos |
| **registrar_triagem** | `leadTriageTool` | ✅ Ativo | Cria novo lead com dados da triagem |
| **pesquisar_conhecimento** | `knowledgeSearchTool` | ✅ Ativo | RAG para documentos do escritório |

### Tools Localizadas

- **Arquivo**: `ai/src/tools/index.ts`
- **Carregadas em**: `ai/src/graph/nodes/router.ts`
- **Acesso**: `toolsByName` dictionary com nomes em português

---

## 3. ANÁLISE DETALHADA: Tool agendar_compromisso

### ✅ Funções

#### 3.1 check_availability
**Objetivo**: Mostrar horários livres ao cliente

**Parâmetros**:
```typescript
{
  action: "check_availability",
  lawyerId: string,  // ID do advogado
  date: string       // YYYY-MM-DD
}
```

**Fluxo**:
1. IA chama com data específica
2. Backend verifica `/api/v1/appointments/slots`
3. Retorna lista de horários disponíveis
4. IA apresenta opções ao cliente em português

**Resposta Esperada**:
```
"✓ Horários disponíveis em 20/05: 09:00, 10:00, 11:30, 14:00, 15:30
Apresente essas opções ao cliente e use a ação 'schedule' quando ele escolher uma."
```

#### 3.2 schedule
**Objetivo**: Efetivamente agendar a reunião

**Parâmetros**:
```typescript
{
  action: "schedule",
  lawyerId: string,           // ✓ Obrigatório
  clientPhone: string,        // ✓ Obrigatório
  date: string,              // ✓ Obrigatório (YYYY-MM-DD)
  time: string,              // ✓ Obrigatório (HH:mm)
  title: string,             // ✓ Obrigatório
  description?: string,      // Opcional
  durationMinutes?: number   // Padrão: 60
}
```

**Validações**:
- ✅ Zod schema no frontend
- ✅ Backend valida conflitos
- ✅ Verifica se cliente existe (por WhatsApp)
- ✅ Valida duração mínima (15 min)

---

## 4. FLUXO ATUAL: ANTES vs AGORA

### ANTES (G5-79 Inicial)
```
Cliente pede reunião
      ↓
IA chama: check_availability
      ↓
IA apresenta horários
      ↓
Cliente escolhe
      ↓
IA chama: schedule
      ↓
Appointment criado com status: SCHEDULED
      ↓
Cliente notificado
      ↓
✅ Fim
```

### AGORA (Com Approval Workflow - Implementado)
```
Cliente pede reunião
      ↓
IA chama: check_availability
      ↓
IA apresenta horários
      ↓
Cliente escolhe
      ↓
IA chama: schedule
      ↓
Appointment criado com status: PENDING_APPROVAL + created_by_ai: true
      ↓
Cliente notificado: "Pré-reservado, aguarde aprovação do advogado"
      ↓
[NOVO] Advogado vê na app:
  - Badge com contador de pendentes
  - Acesso a tela de aprovação
  - Pode editar, resetar, pedir reagendamento
      ↓
Advogado aprova: Status → SCHEDULED
      ↓
Cliente notificado: "Reunião confirmada"
      ↓
✅ Fim
```

---

## 5. STATUS DO AGENDAMENTO NA IA

### ❌ PROBLEMA CRÍTICO IDENTIFICADO

**Descrição**: A IA NÃO tém instruções no prompt do sistema para QUANDO agendar reuniões.

**Localização do Problema**:
- Arquivo: `ai/src/config/prompts.ts` (linhas 1-67)
- Tipo: Prompt de Sistema (AGENT_PROMPT)

**O que está faltando**:
```
AGENDAR REUNIÕES:
- Você DEVE oferecer agendamento quando o cliente expressar interesse em reunir com advogado
- Use a tool 'agendar_compromisso' com action="check_availability" primeiro
- Apresente opções disponíveis
- Aguarde cliente escolher horário
- Confirme com schedule
- Informar status: "Aguardando aprovação do advogado"
```

### Current Behavior

**Atualmente**, a IA:
- ✅ Tem acesso à tool (ela existe)
- ✅ Consegue chamar se explicitamente instruída
- ❌ NÃO é instruída a oferecer proativamente
- ❌ NÃO sabe que agora cria PENDING_APPROVAL (não SCHEDULED)
- ❌ NÃO avisa cliente sobre estado pendente de aprovação

---

## 6. BACKEND: API ENDPOINTS DISPONÍVEIS

### Appointments CRUD

| Método | Endpoint | Status | Descrição |
|--------|----------|--------|-----------|
| GET | `/api/v1/appointments` | ✅ | Lista compromissos (com filtros) |
| GET | `/api/v1/appointments/:id` | ✅ | Detalhe do compromisso |
| POST | `/api/v1/appointments` | ✅ | Criar compromisso |
| PATCH | `/api/v1/appointments/:id` | ✅ | Atualizar compromisso |
| DELETE | `/api/v1/appointments/:id` | ✅ | Deletar compromisso |
| GET | `/api/v1/appointments/slots` | ✅ | Horários disponíveis |

### Approval Endpoints (NOVO)

| Método | Endpoint | Status | Descrição |
|--------|----------|--------|-----------|
| GET | `/api/v1/appointments/pending` | ✅ Implementado | Listar pendentes |
| PATCH | `/api/v1/appointments/:id/approve` | ✅ Implementado | Aprovar com edições |
| PATCH | `/api/v1/appointments/:id/reject` | ✅ Implementado | Rejeitar |
| PATCH | `/api/v1/appointments/:id/reset-to-ai-version` | ✅ Implementado | Reverter edições |
| POST | `/api/v1/appointments/:id/reschedule-request` | ✅ Implementado | Pedir IA reagendar |
| GET | `/api/v1/appointments/:id/reschedule-suggestions` | ✅ Implementado | Ver sugestões |
| PATCH | `/api/v1/reschedule-suggestions/:id/accept` | ✅ Implementado | Aceitar sugestão |
| PATCH | `/api/v1/reschedule-suggestions/:id/reject` | ✅ Implementado | Rejeitar sugestão |

---

## 7. DATABASE: NOVO SCHEMA

### Coluna Appointments

| Coluna | Tipo | Novo? | Descrição |
|--------|------|-------|-----------|
| id | UUID | ✗ | PK |
| lawyer_id | UUID | ✗ | FK users |
| client_id | UUID | ✗ | FK users |
| title | VARCHAR | ✗ | Título do compromisso |
| description | TEXT | ✗ | Descrição |
| type | VARCHAR | ✗ | MEETING/DEADLINE/HEARING/OTHER |
| scheduled_at | TIMESTAMPTZ | ✗ | Data/hora |
| status | VARCHAR | ✗ | **AGORA**: SCHEDULED/COMPLETED/CANCELED/PENDING_APPROVAL |
| **created_by_ai** | BOOLEAN | ✅ **NOVO** | Flag: criado por IA |
| **ai_created_at** | TIMESTAMPTZ | ✅ **NOVO** | Timestamp da criação pela IA |
| **ai_original_data** | JSONB | ✅ **NOVO** | Backup da proposta original da IA |
| **approved_by_lawyer_id** | UUID | ✅ **NOVO** | FK users - advogado que aprovou |
| **approved_at** | TIMESTAMPTZ | ✅ **NOVO** | Timestamp da aprovação |

### Nova Tabela: ai_reschedule_suggestions

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| id | UUID | PK |
| appointment_id | UUID | FK appointments |
| lawyer_id | UUID | FK users |
| instruction | TEXT | Instrução do advogado (ex: "não segunda") |
| suggested_datetime | TIMESTAMPTZ | Nova data/hora sugerida |
| suggested_title | VARCHAR | Título sugerido |
| suggested_description | TEXT | Descrição sugerida |
| status | VARCHAR | PENDING/ACCEPTED/REJECTED/SUPERSEDED |
| created_at | TIMESTAMPTZ | Criação |
| updated_at | TIMESTAMPTZ | Última atualização |

### Triggers

- ✅ `prevent_ai_direct_scheduling()` - Previne AI criar com status SCHEDULED
- ✅ `update_ai_reschedule_suggestions_updated_at` - Atualiza timestamp

---

## 8. FRONTEND: TELAS E COMPONENTES

### Screens (Flutter)

| Tela | Arquivo | Status | Descrição |
|------|---------|--------|-----------|
| **LawyerScheduleScreen** | `lawyer_schedule_screen.dart` | ✅ Atualizado | Badge com contador no header |
| **LawyerAppointmentDetailScreen** | `lawyer_appointment_detail_screen.dart` | ✅ Atualizado | Botões approve/reject/reset/reschedule |
| **LawyerAppointmentApprovalScreen** | `lawyer_appointment_approval_screen.dart` | ✅ **NOVO** | Lista de pendentes |

### Componentes Adicionados

- ✅ AI Indicator Badge (amarelo com ⚡)
- ✅ Approval Buttons (Aprovar/Rejeitar)
- ✅ Reset Button (voltar à proposta original)
- ✅ Reschedule Bottom Sheet
- ✅ Status Badge para PENDING_APPROVAL (warning color)

### Roteamento

```dart
// Novo
static const String lawyerAppointmentApprovalRoute = '/lawyer-appointment-approval';

// App Router carrega corretamente em app_router.dart
```

---

## 9. FLUXOS DE NEGÓCIO: CASOS DE USO

### Caso 1: Cliente Comum (+95%)

```
1. Cliente chega com dúvida jurídica
2. IA oferece esclarecimentos
3. Cliente NÃO demonstra interesse em reunião
4. IA FAZ HANDOFF ou finaliza conversa
5. ✅ Sem agendamento
```

**Status**: ✅ Funciona corretamente hoje

### Caso 2: Cliente Quer Agendar - SEM IA

```
1. Cliente: "Gostaria de agendar"
2. IA oferece horários (check_availability)
3. Cliente escolhe
4. IA cria com schedule → PENDING_APPROVAL
5. Cliente notificado: "Aguardando aprovação"
6. Advogado aprova na app
7. Cliente notificado: "Confirmado"
8. ✅ Tudo pronto
```

**Status**: ✅ Fluxo completo implementado

### Caso 3: Cliente Quer Agendar - COM REJEIÇÃO

```
1. Cliente pede reunião
2. IA cria → PENDING_APPROVAL
3. Cliente: "Perfeito"
4. Advogado abre app → vê pendente
5. Advogado rejeita (motivo: já tem cliente)
6. Cliente notificado: "Não foi possível"
7. IA oferece novo slot
8. ✅ Loop continua
```

**Status**: ✅ Implementado

### Caso 4: Advogado Edita Antes de Aprovar

```
1. Cliente marca 15:30 segunda
2. IA cria → PENDING_APPROVAL
3. Advogado abre detalhes
4. Advogado muda para 16:00
5. Advogado clica "Aprovar"
6. Appointment atualizado
7. Cliente notificado com novo horário
8. ✅ Aprovado com edição
```

**Status**: ✅ Implementado

### Caso 5: Advogado Quer Reagendar Pela IA

```
1. Cliente marca segunda 14:00
2. IA cria → PENDING_APPROVAL
3. Advogado clica "Pedir IA Reagendar"
4. Advogado: "Não segunda, veja terça"
5. **[TODO]** IA recebe instrução e propõe novo horário
6. **[TODO]** Advogado aceita/rejeita sugestão
7. **[TODO]** Cliente notificado com novo horário
```

**Status**: ⚠️ **50% IMPLEMENTADO**
- ✅ UI feita para solicitar instrução
- ✅ Backend endpoint criado
- ❌ IA não tem lógica para receber instrução e reagendar
- ❌ IA não propõe novos horários

---

## 10. O QUE ESTÁ FUNCIONANDO ✅

| Feature | Implementado | Testado |
|---------|--------------|---------|
| IA acessa tool agendar_compromisso | ✅ | Parcial |
| Check availability | ✅ | Parcial |
| Schedule appointment | ✅ | Parcial |
| Criar com PENDING_APPROVAL | ✅ | Não (migration pending) |
| Advogado aprovar | ✅ | Não (migration pending) |
| Advogado rejeitar | ✅ | Não (migration pending) |
| Advogado resetar a AI version | ✅ | Não (migration pending) |
| UI de aprovação | ✅ | Não (migration pending) |
| Notificações | ⚠️ | Parcial |
| Reset a AI version | ✅ | Não (migration pending) |
| Request reschedule | ✅ Backend | Não (migration pending) |

---

## 11. O QUE ESTÁ FALTANDO ❌

### 🔴 CRÍTICO

1. **Prompt do Sistema Incompleto**
   - IA não tem instruções para QUANDO agendar
   - IA não sabe que agora cria PENDING_APPROVAL
   - IA não comunica o novo fluxo ao cliente

   **Arquivo afetado**: `ai/src/config/prompts.ts`
   
   **Impacto**: IA raramente vai agendar, e quando o faz, não comunica estado de confiabilidade

2. **Lógica de IA para Reagendamento**
   - Endpoint existe, mas IA não tem callback para receber instrução
   - IA não propõe novos horários baseado em instrução
   - Sistema de fila/webhook para IA reagendar não existe

   **Arquivo afetado**: Não existe ainda
   
   **Impacto**: Fluxo de reagendamento é incompleto

3. **Testes TODO**
   - Nenhum teste E2E criado
   - Nenhuma validação de segurança testada
   - Trigger SQL não foi validado

   **Impacto**: Risco de bugs em produção

### ⚠️ MODERADO

4. **Notificações WhatsApp**
   - Backend envia OK, mas webhook WhatsApp não está wired
   - Cliente não recebe confirmações em tempo real

5. **Sincronização de Contadores**
   - Badge na tela mostra "0" hardcoded
   - Precisa de integração com API para fetch real-time

6. **Estado de Sugestões de Reschedule**
   - UI mostra "Aguardando IA..." mas nunca atualiza
   - Polling ou WebSocket não implementado

---

## 12. MIGRATION STATUS

### ⚠️ MIGRATION PRECISA SER EXECUTADA

```bash
# Após docker:reset, isso é automático:
npm run docker:reset

# Isso vai executar em sequência:
1. schema.sql (base)
2. seed.sql (dados)
3. 03-add_appointment_approval_workflow.sql (NOVO - adicionado)
```

**Status**: ✅ Docker-compose já foi atualizado

---

## 13. CHECKLIST: O QUE FAZER AGORA

### Fase 1: Validar (HOJE)
- [ ] Executar `npm run docker:reset`
- [ ] Verificar se migration rodou sem erro
- [ ] Verificar se table `ai_reschedule_suggestions` foi criada
- [ ] Testar endpoint GET /appointments/pending (deve retornar vazio ou list)

### Fase 2: Instruir IA (PRÓXIMA SPRINT)
- [ ] Adicionar seção AGENDAR REUNIÕES ao AGENT_PROMPT
- [ ] Instruir IA quando oferecer agendamento
- [ ] Instruir IA sobre novo status PENDING_APPROVAL
- [ ] Instruir IA a avisar cliente "Aguardando aprovação do advogado"
- [ ] Testar fluxo completo: Cliente → IA → Appointment PENDING → Advogado aprova

### Fase 3: Reagendamento (FUTURE)
- [ ] Implementar webhook para IA receber instrução de reagendamento
- [ ] IA gera novos slots baseado em instrução
- [ ] Advogado vê sugestões e aceita/rejeita
- [ ] Implementar polling/WebSocket para updates em tempo real

### Fase 4: Qualidade
- [ ] Escrever testes E2E
- [ ] Testar segurança (trigger SQL)
- [ ] Integrar notificações WhatsApp real
- [ ] Implementar contador dinâmico de pendentes

---

## 14. SUMÁRIO EXECUTIVO

| Aspecto | Status | Notas |
|---------|--------|-------|
| **Database** | ✅ 95% | Migration pronta, precisa rodar |
| **Backend API** | ✅ 100% | Todos endpoints implementados |
| **AI Tools** | ⚠️ 50% | Tool existe, prompt precisa atualizar |
| **Frontend** | ✅ 95% | UI pronta, badge hardcoded |
| **Integration** | ❌ 30% | Webhooks e notificações faltam |
| **Tests** | ❌ 0% | Nenhum teste escrito |
| **Docs** | ✅ 80% | LANGGRAPH_APPOINTMENT_TOOL.md existe |

---

## 15. CONCLUSÃO

✅ **A implementação está ~70% completa**

- ✅ Arquitetura de BD: Pronta
- ✅ Endpoints de API: Prontos
- ✅ UI/UX: Pronto
- ⚠️ Prompt de IA: Incompleto
- ❌ Reagendamento automático: Incompleto
- ❌ Notificações: Parcial
- ❌ Testes: Não iniciado

**Próximo Passo Crítico**: Atualizar `AGENT_PROMPT` em `ai/src/config/prompts.ts` para instruir quando agendar e comunicar o novo fluxo ao cliente.
