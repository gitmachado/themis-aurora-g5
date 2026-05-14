# 🧪 Próximo Teste - Plano de Ação

## Objetivo

Testar o fluxo completo com a conversa real do WhatsApp e validar se todos os fixes funcionam corretamente.

---

## ✅ Preparação

Antes de testar, verifique:

```bash
# 1. Verificar branch correta
git branch
# Esperado: feature/g5-79-sistema-agenda-prazos

# 2. Verificar últimos commits
git log --oneline -5
# Esperado: 2bdba9a 📝docs / e792c5e 📝docs / ...

# 3. Compilar AI
cd ai && npx tsc --noEmit
# Esperado: (sem saída = sucesso)

# 4. Relançar serviços
docker-compose restart themis-ai themis-server
# Aguardar ~10 segundos até estabilizar

# 5. Verificar logs
docker-compose logs -f themis-ai | head -20
# Esperado: Sem erros na inicialização
```

---

## 🧪 Teste 1: Cliente Novo (5 minutos)

### Conversa Esperada

```
[User] Bom dia
[AI] Bom dia! Eu sou a Themis AI...

[User] Quero agendar uma consulta
[AI] Para que eu possa ajudá-lo a agendar...preciso coletar algumas informações.
      Por favor, me informe seu nome completo.

[User] João Silva
[AI] Obrigado, João! Agora, por favor, me informe seu e-mail...

[User] joao@example.com
[AI] Ótimo, João! Agora, por favor, me informe seu CPF.

[User] 12345678901
[AI] Obrigado, João! Agora, preciso saber qual é o tipo de caso...

[User] Direito Civil
[AI] Perfeito, João! Agora, por favor, me forneça uma breve descrição do seu caso...

[User] Disputa contratual
[AI] Obrigado pela informação, João. Agora, por fim, qual é a sua disponibilidade de contato?
     Você prefere ser contatado pela manhã, à tarde ou à noite?

[User] Tarde
[AI] Sua ficha foi registrada, João! Posso agendar uma consulta com o advogado para você agora?

[User] Sim                                    ← CRITICAL TEST POINT
[AI] ← ESPERADO: "Ótimo! Vou verificar os horários disponíveis..."
     "Horários disponíveis em [data]: 10:00, 11:00, 14:00, 15:00..."
     NÃO deve pedir nome, email, cpf novamente ✅

[User] 14:00
[AI] Perfeito! Sua reunião está pré-reservada para [data] às 14:00.
     O advogado revisará sua solicitação...
```

### Se Travar na linha "Sim":

1. **Aguarde até 10 segundos** (sistema pode ser lento)
2. **Se continuar travado:**
   - Capture TODAS as linhas de log do servidor
   - Procure por: `[Router Node]`, `[Tool:`, `ERROR`
   - Compartilhe comigo

---

## 🧪 Teste 2: Cliente Retornando (ou reusar número anterior)

### Setup
- Use o MESMO número de WhatsApp do Teste 1
- Aguarde 2 segundos para entrar em nova conversa

### Conversa Esperada

```
[User] Oi, quero marcar outra reunião
[AI] Olá, João! Como posso ajudar?  ← Deve reconhecer
     Qual é o tipo do novo caso?     ← NÃO deve pedir nome/email/cpf

[User] Direito Trabalhista
[AI] Perfeito! Por favor, me forneça uma breve descrição...

[User] Desvio de função
[AI] Sua ficha foi registrada! Posso agendar uma consulta?

[User] Claro                           ← Alternative affirmative
[AI] ← ESPERADO: Oferece horários (sem hang)
     ← NÃO deve pedir triagedata novamente

[User] 15:00
[AI] Perfeito! Sua reunião está pré-reservada para [data] às 15:00...
```

### Validações

✅ AI reconheceu "João"  
✅ NÃO pediu nome/email/cpf/telefone  
✅ Respondeu rapidamente (< 5 seg)  
✅ Ofereceu horários  

---

## 🧪 Teste 3: Verificar Logs Depois de "Sim"

### Abra terminal e execute:

```bash
docker-compose logs themis-ai 2>&1 | grep -E "\[Router|Tool:" | tail -20
```

### Procure por EXATAMENTE:

```
[Router Node] Message received: "Sim" | wantsToBook: true
[Router Node] 🔍 PRÉ-CHECK: Detectado booking intent para João
[Router Node] ✅ getOpenAppointmentsByPhone retornou: { hasOpenAppointments: false,...
[Tool: Appointment] CHECK_OPEN_APPOINTMENTS iniciado para 558...
[Tool: Appointment] Resultado recebido: { hasOpenAppointments: false, count: 0 }
[Tool: Appointment] Retornando SUCESSO (sem reunião aberta)
```

✅ Se ver LogS: Sistema funcionando  
❌ Se NÃO ver Logs: Debugar conforme DEBUG_FLOW.md

---

## 🚨 Se Algo Quebrar

### 1️⃣ AI não responde após "Sim" (hang)

Execute:
```bash
docker-compose logs themis-ai 2>&1 | tail -100
```

Procure por:
- ❌ `Error` ou `ERRO`
- ❌ `timeout`
- ❌ Exception stack trace

Compartilhe TODA a saída.

### 2️⃣ AI pede triagedata novamente

Isso significa que o cliente NÃO foi reconhecido.  
Verifique:
- WhatsApp number está correto?
- Are dois testes com DIFERENTES números?  
- Lead foi criado no primeiro teste?

Execute:
```bash
# Ver se lead existe
curl -X GET "http://localhost:3000/api/v1/bot/leads/by-phone/55XXXXX" \
  -H "Authorization: Bearer TOKEN"
```

### 3️⃣ Tool não é chamado

Procure em logs:
```
[Tool: Appointment] CHECK_OPEN_APPOINTMENTS iniciado
```

Se não aparecer = LLM não chamou tool

Solução possível:
- Prompt pode estar truncada
- LLM pode estar rejeitar o tool call schema
- Testar com `/reset` do LLM?

---

## 📊 Checklist de Teste

- [ ] Cliente novo: triagedata coletada
- [ ] Cliente novo: "Sim" respondido em < 5 seg
- [ ] Cliente novo: sem pedir triagedata novamente
- [ ] Cliente novo: horários oferecidos
- [ ] Cliente retorno: reconhecido por nome
- [ ] Cliente retorno: não re-pediu triagedata
- [ ] Router logs mostram PRÉ-CHECK
- [ ] tool logs mostram CHECK_OPEN_APPOINTMENTS
- [ ] Sem erros ou timeouts nos logs
- [ ] Appointment criado com status PENDING_APPROVAL

---

## 📞 Quando Relatar Problema

Com as informações:
1. **Logs completos** (from `docker-compose logs`)
2. **Mensagem exata** onde trava/falha
3. **Número de WhatsApp** usado
4. **Timestamp** do teste

Irei debugar e iterar até resolver.

---

## ✅ Quando Está Funcionando

Se todos os testes passarem:
1. Criar novo commit: `git commit -m "✅test: G5-79 all flows working end-to-end"`
2. Começar Phase 4: Auto-navigate após aprovação
3. Implementar socket listeners

---

**Status:** Pronto para testar  
**Última Atualização:** 2026-05-14 (Commit 2bdba9a)  

🚀 **Boa sorte com os testes!**
