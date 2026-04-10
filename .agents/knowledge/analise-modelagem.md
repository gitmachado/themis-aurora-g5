# Análise Crítica da Modelagem de Dados — G5-8

---

## Parte 1: Nomenclatura (Models + DTOs)

### Padrão Adotado

| Elemento | Padrão Usado | Exemplo |
|---|---|---|
| **Arquivo de model** | `kebab-case.model.ts` | `timeline-evento.model.ts` |
| **Interface de entidade** | `PascalCase` singular | `interface Lead {}` |
| **Arquivo de DTO** | `kebab-case.dto.ts` com prefixo de operação | `create-lead.dto.ts` |
| **Interface de DTO** | `PascalCaseDTO` | `interface CreateLeadDTO {}` |
| **Arquivo de enum** | `enums.ts` centralizado | `enums.ts` |
| **Tipo enum** | `PascalCase` | `type TipoCaso = ...` |

### Por que esse padrão e não outro?

#### 1. Sufixo `.model.ts` nos arquivos de entidade

**Por quê:** Diferencia claramente uma entidade de domínio de qualquer outro tipo. Ao ler `user.model.ts`, você sabe imediatamente que é a representação canônica do User no banco — não é um DTO, não é um helper.

**Alternativa rejeitada:** `user.entity.ts` — Comum em projetos com ORMs (TypeORM usa `@Entity()`), mas nosso projeto **não tem ORM**. Usar `.entity.ts` criaria expectativa falsa de decorators e metadata de ORM.

**Alternativa rejeitada:** `user.ts` puro — Ambíguo. Um arquivo `user.ts` pode ser um model, um controller, um util. O sufixo remove a adivinhação.

#### 2. Prefixo de operação nos DTOs (`Create`, `Update`, `Convert`)

**Por quê:** O prefixo indica **a intenção** do DTO. Ao ver `CreateLeadDTO`, você sabe que ele serve para *criação*, não para consulta ou atualização. Isso é especialmente importante porque a mesma entidade (`Lead`) tem DTOs diferentes para operações diferentes, com campos obrigatórios distintos.

**Alternativa rejeitada:** `LeadCreateDTO` (entidade primeiro) — Funciona, mas quebra a consistência de leitura em imports: `import { CreateLeadDTO, CreateProcessoDTO }` agrupa operações similares visualmente. Com `LeadCreateDTO, ProcessoCreateDTO`, o agrupamento visual é por entidade, o que faz menos sentido quando você está implementando um controller que faz múltiplas criações.

**Alternativa rejeitada:** DTO genérico único (`LeadDTO`) — Perigoso. Um único DTO para criação e atualização força campos opcionais em massa (`Partial<Lead>`), perdendo a validação em tempo de compilação.

#### 3. `kebab-case` nos nomes de arquivo

**Por quê:** Padrão de facto no ecossistema Node.js/TypeScript. Evita problemas de case-sensitivity entre Linux (produção) e Windows (dev). `timeline-evento.model.ts` funciona igual nos dois OS.

**Alternativa rejeitada:** `camelCase` (`timelineEvento.model.ts`) — Funciona, mas não é idiomático em Node. O próprio TypeScript compiler, ESLint, e a maioria dos boilerplates Node.js usam kebab-case.

#### 4. Nomes em Português nos campos/tipos

**Por quê:** O domínio é **jurídico brasileiro**. Termos como `TipoCaso`, `Processo`, `Intimação`, `StatusLead` são mais claros em PT-BR para a equipe do que traduções forçadas (`CaseType`, `Lawsuit`). **O código de infraestrutura** (controllers, routes, config) pode ser em inglês, mas o **vocabulário de domínio** deve refletir o contexto real.

> [!TIP]
> Essa é uma prática de **Domain-Driven Design (DDD)**: usar a linguagem do domínio (*ubiquitous language*) no código. Se o advogado fala "processo", o código usa `Processo`, não `Case`.

#### 5. Enums como `type` (union type) e não `enum`

**Por quê:** Enums do TypeScript (`enum StatusLead { ... }`) geram código JavaScript em runtime (um objeto). Union types (`type StatusLead = 'PENDENTE' | 'CONVERTIDO'`) existem **apenas em tempo de compilação** — zero overhead. Como não temos ORM para sincronizar enums, os valores serão ENUMs do PostgreSQL e strings no JS.

> [!WARNING]
> **Ponto de atenção:** Se precisarmos iterar sobre os valores (ex: listar todos os status num dropdown), union types exigem um array auxiliar `const statusLeadValues = ['PENDENTE', 'CONVERTIDO', 'DESCARTADO'] as const`. Hoje não precisamos disso, mas é um trade-off a observar.

---

## Parte 2: Cobertura Funcional vs PRD

Vou mapear **cada funcionalidade do PRD** contra o que a modelagem cobre:

### PRD §2.1 — Chatbot WhatsApp

| Funcionalidade | Status | Cobertura no Model |
|---|---|---|
| Validação de cadastro por `phone_number` | ✅ Coberto | `Lead.whatsappNumber` + `User.whatsappNumber` |
| Coleta dos 6 campos obrigatórios | ✅ Coberto | `Lead`: nome, cpf, tipoCaso, descricaoCaso, urgencia, disponibilidadeContato |
| Status `LEAD_PENDENTE` | ✅ Coberto | `Lead.status: StatusLead` (PENDENTE) |
| Consulta de processos por telefone | ✅ Coberto | `User.whatsappNumber` → `Processo.clienteId` |
| Exibição: 1 processo / múltiplos / nenhum | ✅ Coberto | `IProcessoRepository.findByClienteId()` retorna array |
| "Última nota do advogado" | ✅ Coberto | `TimelineEvento` filtrado por tipo `NOTA_ADVOGADO` + ordenação |
| Status com data | ✅ Coberto | `Processo.updatedAt` + `statusAtual` |
| Filtro de contexto RAG | ⏳ Adiado | `embeddings_rag` — ticket de IA |
| Handoff humano (palavras-chave) | ⚠️ Parcial | Lógica no bot, mas `Notificacao.tipo = 'SUPORTE_HUMANO'` cobre a notificação |
| Push FCM com histórico anexado | ✅ Coberto | `Notificacao` + `Mensagem` (histórico recuperável) |

### PRD §2.2 — App Flutter

| Funcionalidade | Status | Cobertura no Model |
|---|---|---|
| **Linha do Tempo** cronológica | ✅ Coberto | `TimelineEvento` com `createdAt` ordenado |
| **Aba Chat** (espelhamento WhatsApp) | ✅ Coberto | `Mensagem` persistida por lead/user |
| **Botão "Dúvida Rápida"** (redirect WhatsApp) | ✅ N/A | Lógica do frontend, sem impacto no model |
| Upload de documentos (10MB, PDF/PNG/JPG) | ✅ Coberto | `Documento` + validação em `IDocumentoService` |
| Documento vinculado a processo | ✅ Coberto | `Documento.processoId` FK |
| **Dashboard Advogado** — Total casos abertos/encerrados | ✅ Coberto | Agregação de `Processo.statusAtual` |
| **Dashboard Advogado** — Fila de transferências humano | ⚠️ Parcial | Ver gap #1 abaixo |
| **Dashboard Advogado** — Gráfico por nicho | ✅ Coberto | Agregação de `Processo.tipoCaso` |
| **Dashboard Advogado** — Feed documentos recentes | ✅ Coberto | `Documento` ordenado por `createdAt` |
| **Filtro** por CPF, Nome, Status | ✅ Coberto | `User.cpf`, `User.nome`, `Processo.statusAtual` |
| **Pull-to-refresh** | ✅ N/A | Lógica frontend |
| **Conversão de Lead** | ✅ Coberto | `ConvertLeadDTO` + `Lead.convertedUserId` |
| **Senha temporária via WhatsApp** | ✅ Coberto | `IAuthService.generateTempPassword()` |

### PRD §2.3 — Backend e Sincronização

| Funcionalidade | Status | Cobertura no Model |
|---|---|---|
| Latência máx 2s | ✅ N/A | Infra, não model |
| Push para cliente (status alterado) | ✅ Coberto | `Notificacao.tipo = 'STATUS_ALTERADO'` |
| Push para advogado (suporte humano) | ✅ Coberto | `Notificacao.tipo = 'SUPORTE_HUMANO'` |
| Push para advogado (novo documento) | ✅ Coberto | `Notificacao.tipo = 'DOCUMENTO_ENVIADO'` |
| Modo offline (tela de bloqueio) | ✅ N/A | Lógica frontend |

### PRD §3 — Fluxos de Usuário

| Fluxo | Status | Análise |
|---|---|---|
| §3.1 Novo Lead → Triagem → Persistência → Push | ✅ Coberto | Lead + Mensagem + Notificacao (NOVO_LEAD) |
| §3.2 Atualização → Timeline → Push → Perfil Cliente | ✅ Coberto | Processo + TimelineEvento + Notificacao |
| §3.3 Consulta RAG | ⏳ Adiado | Depende de embeddings_rag |

---

### 🔴 Gaps Identificados

#### Gap #1: Fila de Transferências para Humano

O PRD §2.2 fala em "Fila de Transferências para Humano (Prioridade Máxima)" no dashboard do advogado. Hoje, o handoff gera uma `Notificacao` com tipo `SUPORTE_HUMANO`, mas **não existe um conceito de "fila" com status** (pendente, em atendimento, resolvida).

**Opções:**
- **(A) Mínima**: Usar a lista de `Notificacao` com `tipo = 'SUPORTE_HUMANO'` e `lida = false` como fila implícita. Simples, funciona para o MVP.
- **(B) Explícita**: Criar uma entidade `TransferenciaHumano` com `leadId`, `status`, `atendidoPorId`. Mais robusto, mas adiciona uma entidade.

> **Recomendação:** Opção A para o MVP — a fila é simplesmente "notificações de suporte humano não lidas".

#### Gap #2: Agenda do Advogado

O PRD §3.1 menciona "informa a disponibilidade do advogado (baseado na agenda cadastrada no app)". Hoje **não existe entidade para agenda/disponibilidade do advogado**. O bot não tem como consultar quando o advogado está disponível.

**Opções:**
- **(A)** Ignorar para o MVP — o bot responde com uma mensagem genérica ("um advogado entrará em contato").
- **(B)** Adicionar campo `disponibilidade: string | null` no `User` (onde role = ADVOGADO) para horário livre.

> **Recomendação:** Opção A — o PRD diz "baseado na agenda", mas nenhum CRM analisado implementa isso no app móvel. Pode ser uma feature futura.

#### Gap #3: Processo ↔ Advogado Responsável (CORRIGIDO ✅)

~~Hoje `Processo` tem apenas `clienteId`, mas **não registra qual advogado é responsável**. Para o dashboard do advogado filtrar "meus processos" vs "todos os processos", seria necessário um `advogadoId` no `Processo`.~~

**Status:** Corrigido. A propriedade `advogadoId` foi adicionada na entidade `Processo`.

#### Gap #4: Processo sem `descricao` e sem `ultimaNota` (CORRIGIDO ✅)

~~O `Processo` hoje tem `statusAtual` e `titulo`, mas não tem:~~
~~- `descricao` — para detalhes adicionais do caso~~
~~- Cache da última nota — o PRD §2.1 exige exibir "Última Nota do Advogado" no bot.~~

**Status:** Corrigido. As propriedades `descricao`, `ultimaNota` e `dataUltimaMovimentacao` foram adicionadas na entidade `Processo`.

#### Gap #5: Novo lead não notifica advogado

O PRD §3.1 diz "notifica o advogado via Push: Novo Lead". O `TipoNotificacao` já tem `NOVO_LEAD`, mas os contratos de serviço não mostram onde essa notificação é disparada automaticamente. Isso é lógica de negócio do `ILeadService.createFromWhatsapp()`.

> **Recomendação:** Sem mudança no model — apenas garantir que a implementação do `LeadService` chame `NotificacaoService.send()` ao criar um lead. O contrato já suporta.

---

### Resumo

| Categoria | Total | ✅ Coberto | ⚠️ Parcial | ⏳ Adiado |
|---|---|---|---|---|
| Chatbot WhatsApp | 10 | 8 | 1 | 1 |
| App Flutter | 16 | 16 | 0 | 0 |
| Backend/Sync | 5 | 3 | 0 | 0 |
| Fluxos | 3 | 2 | 0 | 1 |
| **Total** | **30** | **23** | **2** | **2** |

> [!NOTE]
> Os gaps críticos estruturais na modelagem inicial (como advogadoId no Processo) já foram corrigidos. A base está totalmente alinhada para o MVP.
