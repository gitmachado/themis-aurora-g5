# 07 — Tasks de Implementação

## Cronograma: Semana 2 (28/04 — 02/05)

A Semana 2 do cronograma é dedicada ao **"Cérebro" (IA e RAG)**. Temos **5 dias úteis** com 2 devs (Douglas e Aline).

> **⚠️ Contexto do time**: A Aline está em transição de carreira (6 meses em tech). A distribuição abaixo reflete isso: Douglas pega as partes arquiteturais e de integração complexa, enquanto Aline fica com tasks mais delimitadas, com escopo claro e orientação concreta. O Douglas deve estar disponível para pair programming nas tasks marcadas com 🤝.

---

## Sprint Board

### 🏗️ Fase 1 — Fundação (Dia 1-2)

| # | Task | Responsável | Estimativa | Depende de |
|---|------|-------------|-----------|------------|
| T01 | **Setup do módulo `ai/`**: init npm, tsconfig, Dockerfile, .env, estrutura de pastas | Douglas | 2h | — |
| T02 | **Habilitar pgvector**: Adicionar `CREATE EXTENSION vector` e tabela `knowledge_embeddings` ao schema.sql | Douglas | 1h | — |
| T03 | **State Schema**: Criar `ThemisState` com Annotation do LangGraph, tipagem completa com Zod | Douglas | 2h | — |
| T04 | **Checkpointer PostgreSQL**: Configurar `@langchain/langgraph-checkpoint-postgres` para persistência de estado | Douglas | 2h | T01 |
| T05 | **Script de teste local**: Criar `test-graph.ts` para invocar o grafo sem WhatsApp | Douglas | 1h | T01 |
| T06 | 🤝 **PDFs da base de conhecimento**: Pesquisar e montar 3-5 PDFs jurídicos de teste (FAQ, documentos por tipo de caso, regras do escritório) | Aline | 3h | — |

### 🧠 Fase 2 — Nós do Grafo (Dia 2-3)

| # | Task | Responsável | Estimativa | Depende de |
|---|------|-------------|-----------|------------|
| T07 | **Router Node**: Classificação de intenção com `withStructuredOutput` (TRIAGE/STATUS/RAG/HANDOFF) | Douglas | 3h | T03 |
| T08 | **Triage Node**: Coleta sequencial dos 6 campos com validação (CPF Regex, enums) | Douglas | 3h | T03 |
| T09 | **Status Node**: Consulta de processos via API + formatação de resposta | Douglas | 2h | T07 |
| T10 | **RAG Node**: Pipeline de query (embed → search → generate com prompt defensivo) | Douglas | 3h | T02 |
| T11 | **Handoff Node**: Detecção de palavras-chave + interrupt + notificação | Douglas | 2h | T07 |
| T12 | 🤝 **Sync Node**: Sincronização de mensagens via `POST /messages/sync` — função HTTP simples com axios | Aline | 2h | T01 |
| T13 | 🤝 **Validações da Triagem**: Criar funções puras de validação (CPF Regex, enum de tipo de caso, enum de urgência) usadas pelo T08 | Aline | 3h | — |

### 🔧 Fase 3 — Tools e RAG Pipeline (Dia 3-4)

| # | Task | Responsável | Estimativa | Depende de |
|---|------|-------------|-----------|------------|
| T14 | **Tools de API**: `create_lead`, `sync_message`, `get_client_processes`, `notify_lawyer` | Douglas | 3h | T01 |
| T15 | **Pipeline de Indexação**: Loader PDF → Splitter → Embeddings → pgvector | Douglas | 3h | T02 |
| T16 | 🤝 **Indexar PDFs de teste**: Rodar o pipeline do T15 com os PDFs do T06 e validar resultados | Aline | 2h | T06, T15 |
| T17 | **Montar o Grafo completo**: Conectar todos os nós com arestas condicionais | Douglas | 3h | T07-T12 |
| T18 | 🤝 **Prompts do bot**: Escrever e testar os prompts de sistema (tom de voz, triagem, RAG defensivo, handoff) em arquivo separado `prompts.ts` | Aline | 3h | — |

### 🌐 Fase 4 — WhatsApp e Integração (Dia 4-5)

| # | Task | Responsável | Estimativa | Depende de |
|---|------|-------------|-----------|------------|
| T19 | **Webhook receptor**: Express server na porta 3001, parsear payload do WhatsApp | Douglas | 2h | T01 |
| T20 | **Envio de resposta**: Função para enviar mensagem via WhatsApp Cloud API | Douglas | 2h | T19 |
| T21 | 🤝 **Config loader**: Tool `get_bot_config` para ler tom de voz e horários do banco (GET simples) | Aline | 2h | T01 |
| T22 | 🤝 **Lógica fora-do-horário**: Checar horário antes de acionar LLM (comparação de strings de hora) | Aline | 1h | T21 |
| T23 | 🤝 **Mensagem não-texto**: Tratar webhooks de áudio/imagem com resposta educada (if/else no tipo de mensagem) | Aline | 1h | T19 |
| T24 | **Docker Compose**: Adicionar serviço `ai` ao docker-compose.yml | Douglas | 1h | T01 |

### ✅ Fase 5 — Testes e Polish (Dia 5)

| # | Task | Responsável | Estimativa | Depende de |
|---|------|-------------|-----------|------------|
| T25 | **Teste E2E**: Simular fluxo completo de lead novo via script | Ambos | 2h | T17 |
| T26 | **Teste E2E**: Simular consulta de status + RAG | Ambos | 2h | T17 |
| T27 | 🤝 **Guardrails**: Implementar proteção contra prompt injection (lista de Regex patterns) | Aline | 2h | T17 |
| T28 | **Documentação**: README do módulo ai/ com instruções de setup | Douglas | 1h | T24 |

---

## Divisão por Responsável

### Douglas (Arquitetura + Grafo + Integração)
T01, T02, T03, T04, T05, T07, T08, T09, T10, T11, T14, T15, T17, T19, T20, T24, T28
**Total estimado: ~36h (~4.5 dias)**

> Douglas é o dono da arquitetura. Ele monta os nós, o grafo e as integrações. Deve reservar tempo para apoiar a Aline nas tasks marcadas com 🤝.

### Aline (Conteúdo + Validações + Funções Isoladas)
T06, T12, T13, T16, T18, T21, T22, T23, T27
**Total estimado: ~19h (~2.5 dias)**

> Aline foca em tasks com **escopo fechado e output concreto**: PDFs, funções de validação puras, prompts, e chamadas HTTP simples. Cada task dela produz um artefato claro que o Douglas consome.

### Ambos (Testes)
T25, T26
**Total estimado: ~4h**

---

## 🤝 Guia de Pair Programming

As tasks marcadas com 🤝 são oportunidades para o Douglas sentar com a Aline (15-30 min) para:
- **T06**: Alinhar quais PDFs são relevantes e o formato esperado
- **T12**: Explicar como funciona a chamada HTTP com axios e API Key
- **T13**: Mostrar o padrão de Regex para CPF e como tipar enums em TypeScript
- **T16**: Rodar junto o pipeline e explicar o que cada etapa faz
- **T18**: Revisar os prompts e testar no playground da OpenAI
- **T21/T22**: Explicar o padrão de leitura de config e a lógica de horários
- **T23**: Mostrar o formato do payload do WhatsApp e o que filtrar
- **T27**: Compartilhar exemplos de prompt injection e como o Regex protege

---

## Tasks para o Backend (Maurício)

Estes endpoints são **pré-requisitos** que o Maurício precisa criar ANTES da integração:

| Task Backend | Descrição | Prioridade |
|-------------|-----------|------------|
| **B01** | `GET /api/v1/users/by-phone/:number` (API Key) | 🔴 Urgente |
| **B02** | `GET /api/v1/processes/by-phone/:number` (API Key) | 🔴 Urgente |
| **B03** | `GET /api/v1/configurations` (API Key) | 🟡 Alta |
| **B04** | Suporte a API Key no `POST /notifications` | 🟡 Alta |

---

## Critérios de "Pronto" (Definition of Done)

- [ ] Bot responde mensagem de número desconhecido com fluxo de triagem
- [ ] Bot coleta os 6 campos e cria lead via API
- [ ] Bot consulta status de processos de clientes existentes
- [ ] Bot responde dúvidas jurídicas com base nos PDFs indexados
- [ ] Bot faz handoff quando necessário (palavra-chave ou falha RAG)
- [ ] Todas as mensagens são sincronizadas para o Chat Mirror do Flutter
- [ ] Bot respeita horário de atendimento
- [ ] Bot rejeita mensagens não-texto educadamente

---

## Ordem de Desenvolvimento Recomendada

```
Dia 1: T01 → T02 → T03 → T04 → T05 → T06  (Douglas: Setup | Aline: PDFs)
Dia 2: T07 → T08 → T12 → T13              (Douglas: Router+Triage | Aline: Sync+Validações)
Dia 3: T09 → T10 → T11 → T15 → T16 → T18  (Douglas: Nós+Pipeline | Aline: Indexação+Prompts)
Dia 4: T14 → T17 → T19 → T20 → T21 → T22  (Douglas: Tools+Grafo+WA | Aline: Config+Horário)
Dia 5: T23 → T24 → T25 → T26 → T27 → T28  (Polish + Testes conjuntos)
```
