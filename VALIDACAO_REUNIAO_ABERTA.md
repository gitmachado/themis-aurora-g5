# 🚫 Validação: Impedir Agendamento com Reunião Aberta

**Status:** ✅ IMPLEMENTADO  
**Data:** 14 de maio de 2026  
**Relacionado:** G5-79 Melhorias na Feature de Agenda

---

## 📋 Requisito

Garantir que um cliente **não consiga agendar outra reunião enquanto tiver uma reunião aberta no sistema**.

**Critérios:**
- Status de reunião aberta: `PENDING_APPROVAL`, `SCHEDULED`
- Status de reunião fechada: `COMPLETED`, `CANCELED`
- Se houver reunião aberta: ❌ Bloquear agendamento → ✅ Instruir handoff

---

## 🏗️ Implementação

### 1. Backend - Novo Endpoint

**Arquivo:** `server/src/routes/v1/bot.routes.ts`

```typescript
GET /bot/appointments/by-phone/:whatsappNumber
```

**Response:**
```json
{
  "hasOpenAppointments": true,
  "count": 1,
  "appointments": [
    {
      "id": "uuid-123",
      "title": "Consulta - Direito Trabalhista",
      "scheduledAt": "2026-05-14T11:00:00",
      "status": "PENDING_APPROVAL",
      "type": "MEETING"
    }
  ]
}
```

**Lógica:**
- Filtra por `client_whatsapp_number`
- Retorna TODAS as reuniões daquele número
- Frontend classifica como "abertas" se status ≠ COMPLETED e ≠ CANCELED

---

### 2. Repository - Método findByClientWhatsapp

**Arquivo:** `server/src/repositories/implementations/appointment.repository.ts`

```typescript
async findByClientWhatsapp(whatsappNumber: string): Promise<Appointment[]> {
  return dbAll<Appointment>(
    `SELECT ... FROM appointments
     WHERE client_whatsapp_number = $1
     ORDER BY scheduled_at DESC`,
    [whatsappNumber]
  );
}
```

**Arquivo:** `server/src/repositories/interfaces/appointment.repository.ts`

Adicionado à interface:
```typescript
findByClientWhatsapp(whatsappNumber: string): Promise<Appointment[]>;
```

---

### 3. AI - Função Backend Client

**Arquivo:** `ai/src/utils/backend-client.ts`

```typescript
export async function getOpenAppointmentsByPhone(whatsappNumber: string): Promise<{
  hasOpenAppointments: boolean;
  count: number;
  appointments: Array<{...}>;
}> {
  const res = await client.get(`/bot/appointments/by-phone/${whatsappNumber}`);
  return res.data;
}
```

---

### 4. AI - Validação no Tool

**Arquivo:** `ai/src/tools/appointment.ts`

No início de `handleScheduleAppointment()`:

```typescript
// NOVO: Verificar se cliente já tem reunião aberta
try {
  const whatsappNumber = triageData?.whatsappNumber;
  if (whatsappNumber) {
    const openAppointments = await getOpenAppointmentsByPhone(whatsappNumber);
    if (openAppointments.hasOpenAppointments) {
      return `⚠️ AGENDAMENTO_BLOQUEADO: Este cliente já possui ${openAppointments.count} reunião(ões) aberta(s) no sistema (status: ${openAppointments.appointments[0]?.status || 'pendente'}).

Não é possível agendar uma nova reunião enquanto houver reuniões abertas.

👤 Como proceder: Faça um HANDOFF para atendimento humano para que o advogado analise a situação com o cliente. Use a ferramenta apropriada de handoff.`;
    }
  }
} catch (err) {
  console.warn("[Tool: Appointment] Erro ao verificar reuniões abertas (continuando):", err.message);
}
```

---

## 🔄 Fluxo Completo

### Cenário 1: Cliente SEM Reunião Aberta (Sucesso ✅)

```
1. Cliente: "Quero agendar uma consulta"
2. AI: Coleta triagedata completos
3. AI: Chama agendar_compromisso(action="schedule", triageData={...})
4. Tool: getOpenAppointmentsByPhone(whatsappNumber)
   ↓ Response: hasOpenAppointments=false
5. Tool: ✅ Continua com agendamento
6. Resultado: Reunião criada em PENDING_APPROVAL
```

### Cenário 2: Cliente COM Reunião Aberta (Bloqueado ❌)

```
1. Cliente: "Quero agendar OUTRA consulta"
2. AI: Coleta triagedata completos (novo caso)
3. AI: Chama agendar_compromisso(action="schedule", triageData={...})
4. Tool: getOpenAppointmentsByPhone(whatsappNumber)
   ↓ Response: hasOpenAppointments=true, count=1
   ↓ Status: "PENDING_APPROVAL"
5. Tool: ❌ Retorna mensagem de bloqueio:
   "⚠️ AGENDAMENTO_BLOQUEADO: Este cliente já possui 1 reunião(ões) aberta(s) 
    no sistema (status: PENDING_APPROVAL).
    Não é possível agendar uma nova reunião enquanto houver reuniões abertas.
    👤 Como proceder: Faça um HANDOFF para atendimento humano..."
6. AI (por instructions no prompt): Faz handoff para humano
7. Resultado: Notificação para advogado revisar
```

---

## 📊 Impacto

| Aspecto | Antes | Depois |
|--------|-------|--------|
| **Comportamento** | Cliente pode agendar múltiplas reuniões duplicadas | Apenas 1 reunião aberta por cliente |
| **Banco de dados** | Sem validação | +Validação na tool de agendamento |
| **API** | Sem endpoint | +GET /bot/appointments/by-phone/:phone |
| **Repository** | - | +findByClientWhatsapp() |
| **AI Tool** | Agendava sempre | Valida antes de agendar |

---

## 🧪 Casos de Teste

### Test 1: Primeira Reunião (Deve Funcionar ✅)
```gherkin
Given: Cliente Lucas (5585988882524) sem reuniões no sistema
When: AI tenta agendar consulta
Then: ✅ Reunião criada com status PENDING_APPROVAL
```

### Test 2: Segunda Reunião Enquanto Primeira Pendente (Deve Bloquear ❌)
```gherkin
Given: Cliente Lucas com 1 reunião em PENDING_APPROVAL
When: AI tenta agendar nova consulta
Then: ❌ Retorna "AGENDAMENTO_BLOQUEADO"
And: AI faz handoff para humano
```

### Test 3: Segunda Reunião Após Primeira Concluída (Deve Funcionar ✅)
```gherkin
Given: Cliente Lucas com 1 reunião em COMPLETED
When: AI tenta agendar nova consulta
Then: ✅ Reunião criada com status PENDING_APPROVAL
```

### Test 4: Múltiplas Reuniões Abertas (Deve Bloquear e Listar ❌)
```gherkin
Given: Cliente Lucas com 2 reuniões em SCHEDULED
When: AI tenta agendar nova consulta
Then: ❌ Retorna "AGENDAMENTO_BLOQUEADO"
And: Message mostra count=2
```

---

## 🔐 Verificações de Segurança

✅ **Validação por WhatsApp:**
- Usa `client_whatsapp_number` que é único por cliente
- Não depende de clientId (que pode ser null)
- Funciona mesmo em agendamentos "órfãos"

✅ **Erro Handling:**
- Se verificação falhar: `continue anyway` (warn log)
- Não bloqueia agendamento por erro de API
- Falha aberta (permite agendar se erro)

✅ **Message Explícita:**
- Usuário (AI) recebe mensagem clara
- Sabe exatamente por que foi bloqueado
- Recebe instrução de alternativa (handoff)

---

## 📝 Arquivo Alterados

1. `server/src/routes/v1/bot.routes.ts` - +novo endpoint
2. `server/src/repositories/implementations/appointment.repository.ts` - +método
3. `server/src/repositories/interfaces/appointment.repository.ts` - +interface
4. `ai/src/utils/backend-client.ts` - +função
5. `ai/src/tools/appointment.ts` - +validação no tool

---

## 🚀 Próximos Passos

1. **Fase 2 Mobile:** Exibir `clientName` e `clientWhatsappNumber`
2. **Fase 3 Mobile:** Detalhe de agendamentos com reuniões abertas do cliente
3. **Handoff Improvement:** Adicionar contexto de "reunião aberta em conflito" para o humano

---

## ✨ Conclusão

Validação de agendamento duplicado **100% implementada e testada**.

Cliente não consegue agendar enquanto tem reunião aberta.  
AI recebe instrução clara para fazer handoff.  
Fluxo controlado e seguro.

✅ **Pronto para Fase 2 Mobile.**

---

Implementado em: `2026-05-14 06:00 UTC`
