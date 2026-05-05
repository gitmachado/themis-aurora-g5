# 02 — Arquitetura do Bot (LangGraph)

## Por que LangGraph e não Agentes ReAct puros?

Conforme nosso módulo de LangChain: **"Transição da autonomia total (Agentes ReAct) para fluxos estruturados (LangGraph)"**.

O nosso bot precisa de **previsibilidade** — estamos lidando com dados jurídicos e leads de clientes reais. Não podemos ter um agente "criativo" inventando campos ou pulando etapas de validação. O LangGraph nos dá:

- ✅ Fluxos determinísticos com arestas condicionais
- ✅ Estado tipado como "única fonte da verdade"
- ✅ Human-in-the-loop (handoff) com `interrupt`
- ✅ Persistência de memória de curto prazo por thread (conversa)
- ✅ Streaming de tokens para resposta em tempo real

---

## Diagrama do Grafo

```
                    ┌──────────────┐
                    │   ENTRY      │
                    │ (Webhook)    │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │  ROUTER      │
                    │ (Identifica) │
                    └──────┬───────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
              ▼            ▼            ▼
     ┌────────────┐ ┌───────────┐ ┌──────────┐
     │ TRIAGE     │ │ STATUS    │ │ RAG      │
     │ (Lead Novo)│ │ (Cliente) │ │ (Dúvida) │
     └─────┬──────┘ └─────┬─────┘ └────┬─────┘
           │              │             │
           │              │             │
           ▼              ▼             ▼
     ┌──────────────────────────────────────┐
     │         HANDOFF CHECK                │
     │  (Precisa de humano?)                │
     └──────────┬───────────┬───────────────┘
                │           │
           SIM  │           │  NÃO
                ▼           ▼
     ┌──────────────┐ ┌──────────────┐
     │  HANDOFF     │ │  RESPONSE    │
     │  (Pausa bot) │ │  (Envia msg) │
     └──────────────┘ └──────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │  SYNC        │
                    │ (Salva msg)  │
                    └──────────────┘
```

---

## State Schema (TypeScript/Zod)

O estado é o "cérebro" da conversa. Cada thread (número de WhatsApp) mantém seu próprio estado.

```typescript
import { Annotation } from "@langchain/langgraph";

const ThemisState = Annotation.Root({
  // Identidade
  whatsappNumber: Annotation<string>,
  userType: Annotation<"UNKNOWN" | "LEAD" | "CLIENT">,
  userId: Annotation<string | null>,          // UUID do users se existir
  leadId: Annotation<string | null>,          // UUID do leads se em triagem

  // Histórico de mensagens (memória curto prazo)
  messages: Annotation<BaseMessage[]>({
    reducer: (a, b) => a.concat(b),           // Reducer de append
  }),

  // Triagem — dados coletados
  triage: Annotation<{
    name: string | null,
    cpf: string | null,
    caseType: string | null,
    caseDescription: string | null,
    urgency: string | null,
    contactAvailability: string | null,
    currentStep: "NAME" | "CPF" | "CASE_TYPE" | "DESCRIPTION" | "URGENCY" | "AVAILABILITY" | "DONE",
  }>,

  // Controle de fluxo
  currentNode: Annotation<string>,
  needsHandoff: Annotation<boolean>,
  handoffReason: Annotation<string | null>,

  // Configuração do escritório (carregado 1x)
  config: Annotation<{
    toneOfVoice: string,
    serviceHoursStart: string,
    serviceHoursEnd: string,
    awayMessage: string,
  }>,
});
```

---

## Descrição dos Nós

### 1. `router` — Nó de Roteamento
**Responsabilidade**: Decidir qual fluxo executar.

```
SE whatsappNumber NÃO existe em users → userType = "UNKNOWN"
  SE já existe em leads com status PENDING → userType = "LEAD" (continua triagem)
  SENÃO → userType = "UNKNOWN" (inicia triagem)
SE whatsappNumber EXISTE em users → userType = "CLIENT"
```

**Aresta Condicional**:
- `UNKNOWN` → `triage_node`
- `LEAD` (triagem em andamento) → `triage_node`
- `CLIENT` + mensagem parece consulta de status → `status_node`
- `CLIENT` + mensagem é dúvida genérica → `rag_node`
- Qualquer + palavras-chave de handoff → `handoff_node`

**Implementação**: Este nó usa o LLM com `withStructuredOutput` para classificar a intenção:

```typescript
const routerSchema = z.object({
  intent: z.enum(["TRIAGE", "STATUS_QUERY", "LEGAL_QUESTION", "HANDOFF_REQUEST", "GREETING"]),
  confidence: z.number(),
});
```

### 2. `triage_node` — Coleta de Dados do Lead
**Responsabilidade**: Coletar os 6 campos obrigatórios de forma conversacional.

- Usa um sub-fluxo sequencial: Nome → CPF (valida formato) → Tipo de Caso → Descrição → Urgência → Disponibilidade
- O campo `triage.currentStep` controla em qual etapa está
- **Validações determinísticas** (Regex para CPF, enum para tipo de caso)
- Ao completar, chama `POST /leads` via Tool

### 3. `status_node` — Consulta de Processos
**Responsabilidade**: Buscar processos do cliente e formatar resposta.

- Tool chama `GET /processes/my` com JWT do contexto
- Se 1 processo → mostra status direto
- Se N processos → lista numerada
- Se 0 → oferece abertura de novo caso

### 4. `rag_node` — Resposta por RAG
**Responsabilidade**: Buscar na base de conhecimento e responder.

- Usa o pipeline RAG: Query → Embed → Vector Search (pgvector) → Contexto → LLM
- Prompt defensivo: "Responda APENAS com base no contexto fornecido"
- Se confiança baixa → aciona `needsHandoff = true`

### 5. `handoff_node` — Transferência para Humano
**Responsabilidade**: Pausar o bot e notificar o advogado.

- Ativado por palavras-chave: `ajuda`, `falar com alguem`, `advogado`
- Ativado por falha do RAG (sem contexto relevante)
- Envia notificação ao advogado via `POST /notifications`
- Usa `interrupt()` do LangGraph para pausar o grafo

### 6. `sync_node` — Sincronização
**Responsabilidade**: Garantir que toda mensagem seja persistida.

- Chama `POST /messages/sync` a cada troca de mensagem
- Formato: `{ whatsappNumber, content, sender: "BOT" | "CLIENT" }`

---

## Tools (Ferramentas do Agente)

Seguindo as boas práticas do nosso resumo: nomes em `snake_case`, schemas via Zod.

| Tool | Descrição | Endpoint |
|------|-----------|----------|
| `check_user_exists` | Verifica se telefone pertence a um cliente | Consulta direta ao banco ou `GET /users?whatsapp=` |
| `create_lead` | Cria lead com os 6 campos coletados | `POST /leads` (API Key) |
| `get_client_processes` | Lista processos de um cliente | `GET /processes/my` (JWT) |
| `sync_message` | Salva mensagem no backend | `POST /messages/sync` (API Key) |
| `search_knowledge_base` | Busca semântica na base de PDFs | Query local no pgvector |
| `notify_lawyer` | Dispara notificação de handoff | `POST /notifications` (API Key) |
| `get_bot_config` | Lê configurações do escritório | `GET /configurations` |

---

## Memória

### Curto Prazo (por conversa)
- **Gerenciada por**: Thread ID = `whatsappNumber`
- **Persistência**: PostgreSQL Checkpointer (`@langchain/langgraph-checkpoint-postgres`)
- **Otimização**: `trim` nas últimas 20 mensagens para economia de tokens

### Longo Prazo (entre conversas)
- **Store com namespace**: `["Themis", whatsappNumber]`
- **Conteúdo**: Preferências do cliente, histórico de interações resumido
- **Tipo**: Semântica (para personalização futura)

---

## Runtime Context (Mochila Técnica)

Informações invisíveis ao modelo, usadas pelas tools:

```typescript
const runtimeContext = {
  apiBaseUrl: "http://localhost:3000",
  apiKey: process.env.BOT_API_KEY,      // Para endpoints de API Key
  whatsappToken: process.env.WA_TOKEN,  // Para enviar mensagens
  currentTime: new Date().toISOString(),
};
```

---

## Segurança e Guardrails

| Proteção | Implementação |
|----------|---------------|
| **PII em logs** | Regex para mascarar CPF nos logs internos |
| **Prompt Injection** | Guardrail determinístico (Regex) + validação de intent |
| **Limite de tokens** | Trim de histórico a cada 20 mensagens |
| **Fora do horário** | Retorna `config.awayMessage` sem acionar LLM |
| **Mensagem não-texto** | Responde educadamente que só processa texto (v1) |
