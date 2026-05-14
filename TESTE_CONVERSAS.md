# 🧪 Guia de Testes de Conversa - Themis AI

## Objetivo

Validar que os fixes implementados na **Fase 3** funcionam corretamente:
1. ✅ AI não re-coleta triagedata para clientes retornando
2. ✅ AI bloqueia imediatamente quando usuário tenta agendar com reunião aberta
3. ✅ AI chama `check_open_appointments` ANTES de oferecer disponibilidade

---

## Scripts de Teste

### 1️⃣ Teste via WhatsApp Real (Recomendado)

Use a conversa real do WhatsApp e observe:

```
[03:31] User: "Bom dia"
[03:31] AI: "Bom dia! Sou Themis AI..."
[03:31] User: "Quero agendar uma consulta"
[03:31] AI: "Nome completo?"
...
[03:32] User: "Sim" ← CRITICAL: Deve chamar check_open_appointments AQUI
[03:32] AI: "Horários disponíveis..." (com sucesso) OU "Você já tem reunião..." (bloqueado)
```

**O que observar:**
- ✅ Após "Sim", NÃO deve pedir nome/email/cpf
- ✅ Deve oferecer horários ou bloquear (não travar)
- ❌ Se travar after "Sim", há erro no tool execution

---

### 2️⃣ Teste Automatizado (Node.js)

Script simples que simula múltiplas conversas:

```bash
cd /c/development/themis-aurora-g5

# Rodar teste automatizado
node test-ai-flow.js
```

**Saída esperada:**
```
✅ TESTE 1: Cliente Novo - Triagedata Completa
   [1/9] Abertura
   📱 User: "Olá"
   ✅ Mensagem enviada (status: 200)
   ✅ Validação passou
   
   [9/9] CRÍTICO: Deve verificar disponibilidade...
   📱 User: "Sim"
   ✅ Mensagem enviada (status: 200)
   ✅ Validação passou
   ✅ NÃO contém textos indesejados (nome, email, cpf)
```

---

### 3️⃣ Teste Direto do Router (TypeScript)

Para debug detalhado:

```bash
cd /c/development/themis-aurora-g5

# Compilar (já deve estar compilado)
npx tsc ai/test-router-directly.ts

# Rodar
node ai/test-router-directly.js
```

**Saída esperada:**
```
🔬 TESTE 2: Cliente Retornando - "Quero marcar outra reunião"
Expected: Deve reconhecer cliente e pedir APENAS tipo do novo caso

✅ Router respondeu com mensagens:
   • Ótimo, Jonas! Qual é o tipo da nova reunião?

Next node: sync_node
Handoff needed: false

✅ SUCESSO: Não re-pediu triagedata
```

---

## Cenários de Teste

### Cenário 1: Cliente Novo ✅
```
Flow:
1. User: "Quero agendar"
2. AI: Coleta nome
3. AI: Coleta email
4. AI: Coleta CPF
5. AI: Coleta tipo de caso
6. AI: Coleta descrição
7. AI: Coleta disponibilidade
8. AI: "Posso agendar agora?"
9. User: "Sim"
10. AI: ✅ Oferece disponibilidade (SEM pedir triagedata novamente)
```

**Critério de sucesso:**
- Não pede nome, email, CPF, disponibilidade na mensagem #10
- Oferece horários imediatamente

---

### Cenário 2: Cliente Retornando SEM Reunião Aberta ✅
```
Flow:
1. User: "Quero marcar outra reunião"
2. AI: ✅ Reconhece "Jonas"
3. AI: ✅ Pede APENAS "tipo do novo caso"
4. User: "Direito Trabalhista"
5. AI: Pede descrição do novo caso
6. User: "Desvio de função"
7. AI: ✅ Oferece disponibilidade (usa availability anterior)
```

**Critério de sucesso:**
- Não pede nome, email, CPF, telefone
- Reutiliza disponibilidade já registrada
- Fluxo fluido

---

### Cenário 3: Cliente Retornando COM Reunião Aberta 🚫
```
Setup: Crie manual uma reunião aberta para este cliente
Flow:
1. User: "Quero agendar"
2. Router: [Proactive check] Detecta "agendar" keyword
3. Router: Chama getOpenAppointmentsByPhone()
4. Router: Resultado = REUNIAO_ABERTA
5. AI: ✅ BLOQUEIA imediatamente
6. AI: "Você já tem 1 reunião aberta..."
7. AI: "Posso fazer um handoff?"

Não deve:
❌ Pedir tipo de caso
❌ Pedir data/hora
❌ Oferecer horários
```

**Critério de sucesso:**
- Detecta bloqueio IMEDIATAMENTE quando user menciona agendamento
- Oferece handoff como única opção

---

## Checklist de Validação

### ✅ Phase 3 Implementation

- [ ] **Compilação**: `npx tsc --noEmit` sem erros
- [ ] **Tool schema**: whatsappNumber é required, date é optional
- [ ] **Prompt rules**: Rule 0 explícita sobre não re-coletar
- [ ] **Router detection**: Keywords detectadas (marcar, agendar, reunião)
- [ ] **Context injection**: openAppointmentsContext adicionado ao prompt

### ✅ Testes em Produção

- [ ] **Cenário 1**: Cliente novo → coleta completa → "Sim" → oferece horários
- [ ] **Cenário 2**: Cliente retorno (+reunião aberta) → bloqueia IMEDIATAMENTE
- [ ] **Cenário 3**: Cliente retorno (-reunião aberta) → pede só novo caso

### ✅ Problemas Conhecidos

Se a IA **travar após "Sim"**:
1. Verificar server logs: há erro ao chamar `getOpenAppointmentsByPhone`?
2. Verificar AI logs: está chamando `agendar_compromisso` com `check_open_appointments`?
3. Verificar tool response: está retornando a string correta?

Se a IA **re-pede triagedata**:
1. Verificar se `triage.name` está sendo carregado (lead lookup)
2. Verificar se Rule 0 está ativa no prompt
3. Verificar se LLM está respeitando as instruções

---

## Logs Importantes

Procure por:

```
# Router Proactive Check
[Router Node] PRÉ-CHECK: {name} tem reunião aberta — bloqueando.

# Tool Execution
[Tool: Appointment] Verificando reuniões abertas para {phone}

# Open Appointments Detection
[Router Node] Lead {name} carregado do banco...
GET /api/v1/bot/appointments/by-phone/{phone} 200

# LLM Tool Call
[Router Node] Tool call: agendar_compromisso
Params: action=check_open_appointments, whatsappNumber={phone}
```

---

## Próximos Passos

1. **Hoje**: Executar testes (siga este guia)
2. **Hoje**: Identificar problemas com logs
3. **Hoje**: Corrigir bugs se encontrados
4. **Tomorrow**: Phase 4 - Socket event listener für auto-navigation

---

## Contato / Debug

Se encontrar problemas:

1. Compartilhe logs de: server, AI, banco de dados
2. Compartilhe a conversa exata do WhatsApp
3. Descreva o comportamento inesperado
4. Indique em qual mensagem trava/falha

---

**Status:** Aguardando testes 🧪  
**Commit Atual:** b2abc80 (tool schema fix)  
**Próximo:** Executar teste e coletar feedback
