# 05 — Integração com o Backend

## Princípio: O Bot é um Consumidor da API

O módulo de IA **não acessa o banco diretamente** para operações de escrita. Ele usa os endpoints da API protegidos por `apiKeyMiddleware`. Isso garante que todas as regras de negócio e validações do backend sejam respeitadas.

**Exceção**: Para leitura de embeddings (vector search), o módulo de IA conecta diretamente ao PostgreSQL via `pgvector`, pois o backend não tem endpoints de busca vetorial.

---

## Endpoints Existentes que o Bot Usa

### 1. Criar Lead — `POST /api/v1/leads`
**Auth**: `x-api-key: {BOT_API_KEY}`

```json
// Request
{
  "whatsappNumber": "5511999999999",
  "name": "Maria da Silva",
  "cpf": "12345678900",
  "caseType": "Labor",
  "caseDescription": "Demitida sem justa causa...",
  "urgency": "High",
  "contactAvailability": "Afternoon"
}

// Response 201
{
  "id": "uuid",
  "status": "PENDING",
  ...
}
```

### 2. Sincronizar Mensagem — `POST /api/v1/messages/sync`
**Auth**: `x-api-key: {BOT_API_KEY}`

```json
// Request
{
  "whatsappNumber": "5511999999999",
  "content": "Olá, preciso de ajuda",
  "sender": "CLIENT",
  "whatsappMessageId": "wamid.xxx"
}
```

### 3. Consultar Processos — `GET /api/v1/processes/my`
**Auth**: `Authorization: Bearer {JWT do cliente}`

> ⚠️ **Problema**: Este endpoint exige JWT do cliente. O bot precisa de uma forma de consultar processos por telefone.

**Solução proposta**: Criar endpoint `GET /api/v1/processes/by-phone/:whatsappNumber` protegido por API Key. **Isso é uma task para o Maurício** (backend).

### 4. Histórico de Mensagens — `GET /api/v1/messages/:whatsappNumber`
**Auth**: `Authorization: Bearer {JWT}`

> Mesmo problema do anterior. Precisamos de acesso via API Key.

---

## Endpoints que PRECISAM ser Criados no Backend

| Endpoint | Método | Auth | Descrição |
|----------|--------|------|-----------|
| `/api/v1/users/by-phone/:number` | GET | API Key | Verifica se telefone pertence a um cliente |
| `/api/v1/processes/by-phone/:number` | GET | API Key | Lista processos de um cliente por telefone |
| `/api/v1/configurations` | GET | API Key | Lê configurações do escritório (tom, horários) |
| `/api/v1/notifications` | POST | API Key | Cria notificação para advogado (handoff) |

> **Nota**: O endpoint de notificações já existe como `POST /notifications` protegido por auth, mas o bot precisa usar API Key. Avaliar se criamos uma rota separada `/bot/notifications` ou adicionamos suporte a API Key no existente.

---

## Contrato de Autenticação

```
┌─────────────────┐         ┌──────────────────┐
│  Módulo de IA   │──────── │  Backend API     │
│  (ai:3001)      │  HTTP   │  (server:3000)   │
│                 │         │                  │
│  Header:        │         │  Middleware:      │
│  x-api-key: xxx │────────▶│  apiKeyMiddleware │
└─────────────────┘         └──────────────────┘
```

O `apiKeyMiddleware` já existe e valida a chave estática definida em `server/.env` como `API_KEY`.

---

## Fluxo de Dados Completo

```
WhatsApp ──webhook──▶ AI Module ──HTTP──▶ Backend API ──SQL──▶ PostgreSQL
                          │                                        ▲
                          │                                        │
                          └──────── pgvector (leitura direta) ─────┘
```

1. Mensagem chega via webhook do WhatsApp no módulo de IA (porta 3001)
2. IA processa e decide a ação
3. IA chama endpoints do backend para persistência (leads, mensagens)
4. IA consulta pgvector diretamente para RAG
5. IA envia resposta de volta via WhatsApp Cloud API

---

## Formato de Sincronização de Mensagens

Cada mensagem trocada (entrada e saída) DEVE ser sincronizada:

```typescript
// Mensagem do cliente (recebida via webhook)
await syncMessage({
  whatsappNumber: "5511999999999",
  content: "texto da mensagem",
  sender: "CLIENT",
  whatsappMessageId: "wamid.xxx",
});

// Resposta do bot
await syncMessage({
  whatsappNumber: "5511999999999",
  content: "resposta do bot",
  sender: "BOT",
  whatsappMessageId: null,
});
```

Isso garante que o **Client Chat Mirror** no Flutter sempre terá o histórico completo.
