# 🐛 Debug Flow - AI Hang Issue

## Problem Summary

After Jonas says "Sim" to "Posso agendar uma consulta com o advogado para você agora?", the AI hangs and doesn't respond.

## Root Cause Analysis

### Hypothesis 1: Message Context Issue
- The `lastMessage` in router might not be "Sim" but something else
- The `messages` array might not include the latest "Sim" message

**Fix Applied:**
- Added "sim", "claro", "pode", "blz", "ok" to bookingKeywords
- Added detailed logging: `console.log('[Router Node] Message received: "${lastMessage}" | wantsToBook: ${wantsToBook}')`

### Hypothesis 2: Tool Schema Issue  
- `whatsappNumber` not being passed correctly
- `check_open_appointments` action not recognized

**Fixes Applied:**
- Made `whatsappNumber` **required** in schema
- Made `date` **optional** (not needed for this action)
- Added fallback: check for whatsappNumber in triageData if not injected

### Hypothesis 3: LLM Not Calling Tool
- LLM might not recognize "Sim" as valid booking confirmation
- Prompt might not be clear enough about when to call tool

**Fixes Applied:**
- Updated prompt with VERY explicit instructions for "Sim" response
- Added all variations: "Sim", "Claro", "Pode", "Blz", "OK", "Tudo bem"
- Made prompt say "IMMEDIATELY call check_open_appointments - NA MESMA MENSAGEM"

### Hypothesis 4: Tool Execution Failure
- Tool is called but crashes silently
- getOpenAppointmentsByPhone fails
- Response formatting is wrong

**Fixes Applied:**
- Added detailed console.log everywhere:
  - `[Tool: Appointment] CHECK_OPEN_APPOINTMENTS iniciado para {phone}`
  - `[Tool: Appointment] Chamando getOpenAppointmentsByPhone()...`
  - `[Tool: Appointment] Resultado recebido:` + full result
  - `[Tool: Appointment] Retornando BLOQUEIO` or `Retornando SUCESSO`

---

## How to Debug

### Step 1: Check Router Logs After "Sim"

Look for:
```
[Router Node] Message received: "Sim" | wantsToBook: true
[Router Node] 🔍 PRÉ-CHECK: Detectado booking intent para {name}
[Router Node] ✅ getOpenAppointmentsByPhone retornou: { hasOpenAppointments: false, count: 0, appointments: [] }
[Router Node] ✅ Cliente "{name}" não tem reuniões abertas — PODE AGENDAR.
```

**If you DON'T see these logs:**
- Router is not detecting "Sim" as booking intent
- Check if `lastMessage` contains "sim" keyword (case-insensitive)
- Verify triage.name is set (not null)

### Step 2: Check Tool Logs

Look for:
```
[Tool: Appointment] CHECK_OPEN_APPOINTMENTS iniciado para 5585988882{..}
[Tool: Appointment] Chamando getOpenAppointmentsByPhone(5585988882{..})...
[Tool: Appointment] Resultado recebido: { hasOpenAppointments: false, count: 0, appointments: [] }
[Tool: Appointment] Retornando SUCESSO (sem reunião aberta)
```

**If tool logs don't appear:**
- LLM never called the tool
- Check LLM output to see if it generated tool_calls

**If tool logs show error:**
```
[Tool: Appointment] ERRO ao verificar reuniões abertas: ...
```
- Backend API call failed
- Check server logs for errors

### Step 3: Check LLM Response

After tool returns, should see:
```
[Router Node] Tool call response: "NENHUMA_REUNIAO_ABERTA: Este cliente não tem reuniões abertas..."
```

Then LLM should generate:
```
[Router Node] Invocando reflexão pós-tool...
[Router Node] Resposta final gerada: "Ótimo! Vou verificar os horários disponíveis..."
```

**If final response doesn't appear:**
- LLM is not generating text after tool execution
- Check for LLM timeout or error
- Verify tool response format is correct

---

## Expected Log Sequence (Happy Path)

```
[Router Node] Message received: "Sim" | wantsToBook: true
[Router Node] 🔍 PRÉ-CHECK: Detectado booking intent para Jonas Lacerda
[Router Node] ✅ getOpenAppointmentsByPhone retornou: { hasOpenAppointments: false, ... }
[Router Node] ✅ Cliente "Jonas Lacerda" não tem reuniões abertas — PODE AGENDAR.

[Router Node] Invoca o modelo...
[Router Node] Modelo respondeu com tool_calls

[Router Node] Executando tool: agendar_compromisso
[Tool: Appointment] CHECK_OPEN_APPOINTMENTS iniciado para 5585988882...
[Tool: Appointment] Chamando getOpenAppointmentsByPhone()...
[Tool: Appointment] Resultado recebido: { hasOpenAppointments: false, count: 0 }
[Tool: Appointment] Retornando SUCESSO (sem reunião aberta)

[Router Node] Tool retornou: "NENHUMA_REUNIAO_ABERTA: Este cliente não tem..."
[Router Node] Invocando reflexão pós-tool...
[Router Node] Resposta final gerada: "Ótimo, Jonas!..."

[Router Node] → Retornando resposta ao sync_node
```

---

## Commands to Run

### 1. Tail Logs in Real-Time
```bash
# Server logs
tail -f /path/to/themis-server.log | grep "\[Router\|Tool:"

# AI logs
tail -f /path/to/themis-ai.log | grep "\[Router\|Tool:"
```

### 2. Trigger Conversation
```bash
# Send message via WhatsApp webhook
curl -X POST http://localhost:3000/api/v1/bot/webhook \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{
      "from": "5585988882001",
      "body": "Sim",
      "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
    }]
  }'
```

### 3. Check Database State
```bash
# Verify lead exists with triagedata
SELECT name, email, cpf, case_type FROM leads WHERE whatsapp_number = '5585988882001';

# Check if there are open appointments
SELECT id, title, status FROM appointments WHERE client_whatsapp_number = '5585988882001' AND status != 'COMPLETED' AND status != 'CANCELED';
```

---

## Troubleshooting By Symptom

### ❌ Symptom: "AI doesn't respond at all (no timeout)"
**Likely cause:** Tool not being called or LLM not generating response  
**Check:**
1. Are router logs showing "Detectado booking intent"?
2. Are tool logs showing "CHECK_OPEN_APPOINTMENTS iniciado"?
3. If no tool logs: LLM not calling tool → prompt issue

### ❌ Symptom: "Error in logs before hang"
**Likely cause:** API call failed or tool crashed  
**Check:**
1. Read full error message from logs
2. Check server/database connectivity
3. Verify whatsappNumber format (should be 55...)

### ❌ Symptom: "Tool called but no response"
**Likely cause:** getOpenAppointmentsByPhone hanging or crashing  
**Check:**
1. Is backend API responding?
2. Is database query slow?
3. Run: `curl http://localhost:3000/api/v1/bot/appointments/by-phone/5585988882001`

### ❌ Symptom: "Tool returns but AI still hangs"
**Likely cause:** LLM not generating response after tool result  
**Check:**
1. Is LLM rate-limited?
2. Is context window full?
3. Check if reflection step is timing out

---

## Quick Fixes to Try

1. **Restart AI Service**
   ```bash
   docker-compose restart themis-ai
   ```

2. **Check Tool Response Format**
   ```bash
   # Ensure it returns a valid string, not an object
   echo 'NENHUMA_REUNIAO_ABERTA: ...' # ✅ Good
   echo '{ "status": "success" }' # ❌ Bad
   ```

3. **Verify WhatsApp Number Format**
   ```bash
   # Should be: 55 + area code + number (11 digits total)
   # Example: 5585988882001 ✅
   # NOT: 85988882001 ❌
   ```

4. **Test Tool Directly**
   Create test script at `ai/test-tool-directly.ts`:
   ```typescript
   import { appointmentTool } from './src/tools/appointment.js';
   await appointmentTool.invoke({
     action: 'check_open_appointments',
     whatsappNumber: '5585988882001'
   });
   ```

---

## Next Steps

1. **Run the conversation again with "Sim" response**
2. **Capture logs from:
   - Router Node
   - Tool Appointment
   - Server API calls
3. **Share complete log output**
4. **We'll identify which step is failing**

---

**Status:** Awaiting detailed logs for debugging  
**Last Updated:** 2026-05-14 (after b351f2c commit)
