# 🐛 Análise: Problemas de Contexto e Memória do Bot

## 💬 Conversa Problemática Analisada

**Situação:** Cliente Lucas (WhatsApp) agendou uma consulta, depois pediu agendar outra, mas o bot perdeu o contexto anterior e pediu informações de novo.

---

## 🔴 3 Problemas Identificados

### Problema 1: **Memória do Triage Não Persiste Entre Mensagens**

**O Código:**
```typescript
// router.ts:59-66
const agentPrompt = AGENT_PROMPT
  .replace("{triageName}", triage.name || "FALTANDO")
  .replace("{triageEmail}", triage.email || "FALTANDO")
  .replace("{triageCpf}", triage.cpf || "FALTANDO")
  // ... etc
```

**O Problema:**
- `triage` vem do state, mas o state é reiniciado a cada mensagem
- Se o lead não foi convertido para cliente, os dados ficam em memória **temporária apenas**
- Na próxima mensagem, `triage.name` volta a ser undefined
- Resultado: IA pede "nome completo" de novo "Você já sabe isso"

**Evidência na Conversa:**
```
[02:25] Lucas: "Quero agendar outra reunião"
[02:25] IA: "Ótimo! Por favor, me informe seu nome completo"
[02:26] Lucas: "Você já sabe isso"
[02:26] IA: "Desculpe, preciso que você me forneça novamente"
```

---

### Problema 2: **Sem Busca de Lead Existente Antes de Pedir Dados**

**O Código:**
```typescript
// prompts.ts:40-46
// TRIAGEM FLUIDA — coleta nome, email, cpf, etc
// Mas NUNCA verifica se o lead já existe!
```

**O Prompt Deveria:**
1. ✅ Receber WhatsApp
2. ❌ Buscar se há **lead existente** com esse WhatsApp
3. ❌ Se sim, carregar dados já coletados
4. ✅ Se não, iniciar coleta do zero

**O que Falta (Tool ou Lógica):**
```typescript
// Não existe:
const lead = await leadRepository.findByWhatsappNumber(whatsappNumber);
if (lead) {
  // Carregar: nome, email, cpf da conversa anterior
  // Pedir: só o que falta
}
```

**Evidência na Conversa:**
```
[02:22] IA: "Por favor, me informe seu nome completo"
[02:25] IA (mesma pessoa): "Por favor, me informe seu nome completo"
// IA não consultou se esse WhatsApp tem um lead registrado
```

---

### Problema 3: **Sem Recurso de "Contexto Curto Termo"**

**O Que Existe:**
- Sistema de `triage` que é um objeto em state
- Placeholders no prompt preenchidos dinamicamente

**O Que Falta:**
- Modo "continuação de triagem" que detecte quando o cliente está no meio de um fluxo
- Quando Lucas diz "Quero agendar outra reunião", a IA não deveria pedir TODOS os dados de novo
- Deveria dizer: "Ótimo! Vou agendar para Jonas Lacerda (CPF: 08662542425). Qual o tipo de caso dessa nova reunião?"

---

## 🔍 Raiz da Causa

### Fluxo Atual (Problemático):

```
Message 1: "Bom dia, consultar advogado"
  ↓
  IA coleta: nome, email, cpf, tipo, descrição, disponibilidade
  state.triage = { name: "Jonas", email: "Jonas@...", cpf: "086...", ... }
  ↓
  registrar_triagem() chamada
  ↓
  "Sua ficha foi registrada!"

Message 2: "Quero agendar outra reunião"
  ↓
  state é reiniciado (triage vazia)
  ↓
  .replace("{triageName}", triage.name || "FALTANDO")  ← undefined!
  ↓
  Prompt recebe "FALTANDO" para todos os campos
  ↓
  IA: "Preciso do seu nome completo novamente..."
```

### Fluxo Desejado (Correto):

```
Message 1: "Bom dia, consultar advogado"
  ↓
  Buscar: leadRepository.findByWhatsappNumber("+5585988...")
  ↓
  Se existe → carregar nome, email, cpf
  Se não existe → pedir dados

Message 2: "Quero agendar outra reunião"
  ↓
  Buscar: leadRepository.findByWhatsappNumber("+5585988...")
  ↓
  Encontra "Jonas Lacerda" registrado
  ↓
  Prompt diz: "Nome Completo: Jonas Lacerda (já registrado)"
  ↓
  IA: "Ótimo, Jonas! Para essa nova reunião, qual é o tipo de caso?"
```

---

## 🔧 Soluções Necessárias

### Solução 1: Criar Tool `buscar_lead_existente`

```typescript
// ai/src/tools/search_lead.ts
export const searchLeadTool = {
  name: 'buscar_lead_existente',
  description: 'Busca um lead existente pelo WhatsApp para carregar dados já coletados',
  input: { type: 'object', properties: { whatsappNumber: { type: 'string' } } },
  invoke: async ({ whatsappNumber }) => {
    const lead = await leadRepository.findByWhatsappNumber(whatsappNumber);
    if (lead) {
      return JSON.stringify({
        existe: true,
        nome: lead.name,
        email: lead.email,
        cpf: lead.cpf,
        caseType: lead.caseType,
        ja_agendou: !!lead.lastAppointmentDate
      });
    }
    return JSON.stringify({ existe: false });
  }
};
```

### Solução 2: Atualizar Prompt para Usar Lead Existente

```typescript
// prompts.ts
export const AGENT_PROMPT = `...
VERIFICAÇÃO INICIAL (A CADA MENSAGEM):
1. Se o lead JÁ FOI ENCONTRADO (você tem nome/email/cpf no histórico), NUNCA peça esses dados novamente.
2. Se o cliente pedir "agendar outra reunião" e você já tem os dados dele, diga:
   "Ótimo, [NOME]! Para essa nova reunião, qual é o tipo de caso? (a anterior era [TIPO_ANTERIOR])"
3. NUNCA preencha os placeholders com "FALTANDO" se você já colheu esses dados nesta conversa.
...
`;
```

### Solução 3: Atualizar Router para Carregar Lead

```typescript
// router.ts
export async function routerNode(state: ThemisStateType) {
  const { whatsappNumber, messages, triage } = state;

  // ✅ NOVO: Buscar lead existente se ainda não temos triage carregado
  let currentTriage = triage;
  if (!triage.name) {
    try {
      const existingLead = await leadRepository.findByWhatsappNumber(whatsappNumber);
      if (existingLead) {
        currentTriage = {
          name: existingLead.name,
          email: existingLead.email,
          cpf: existingLead.cpf,
          caseType: existingLead.caseType,
          caseDescription: existingLead.caseDescription,
          urgency: existingLead.urgency,
          contactAvailability: existingLead.contactAvailability,
        };
      }
    } catch (err) {
      console.warn('[Router] Erro ao buscar lead existente:', err);
    }
  }

  // ✅ Usar currentTriage em vez de triage
  const agentPrompt = AGENT_PROMPT
    .replace("{triageName}", currentTriage.name || "FALTANDO")
    .replace("{triageEmail}", currentTriage.email || "FALTANDO")
    // ... etc
}
```

---

## 📊 Impacto

| Aspecto | Antes | Depois |
|--------|-------|--------|
| **UX do Cliente** | Pede nome 2x | Reconhece cliente |
| **Confiança** | ❌ "Você não consegue consultar?" | ✅ "Ótimo, Jonas!" |
| **Eficiência** | 6 perguntas por novo agendamento | 1-2 perguntas (só o que falta) |
| **Conversão** | ⚠️ Cliente pode desistir | ✅ Fluxo fluido |

---

## 🎯 Prioridade

**🔴 ALTA** - Afeta UX crítica do bot. Cliente sente que a IA é "burra".

---

## 📝 Checklist de Implementação

- [ ] Criar `leadRepository.findByWhatsappNumber()`
- [ ] Criar tool `buscar_lead_existente`
- [ ] Adicionar lógica no router para carregar lead
- [ ] Atualizar prompt para detectar "reprompts" evitáveis
- [ ] Testar: segunda mensagem não pede dados de novo
- [ ] Testar: "agendar outra reunião" usa dados já coletados

---

## 🔗 Arquivos a Modificar

1. `ai/src/tools/search_lead.ts` (criar)
2. `ai/src/config/prompts.ts` (atualizar AGENT_PROMPT)
3. `ai/src/graph/nodes/router.ts` (adicionar busca de lead)
4. `server/src/repositories/implementations/lead.repository.ts` (adicionar método)
