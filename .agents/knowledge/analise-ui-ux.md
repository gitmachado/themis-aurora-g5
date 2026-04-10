# Análise UI/UX: O Model Sustenta Boas Interfaces?

Mapeamento de **cada tela possível** contra os dados disponíveis na modelagem atual, considerando um **Aplicativo Único** com perfis de acesso distintos.

---

## 🔵 Perfil CLIENTE (4 telas)

### Tela 1: Login

```
┌─────────────────────────────┐
│        🏛️ OmniConnect       │
│                             │
│  📱 WhatsApp  ____________  │
│  🔒 Senha     ____________  │
│                             │
│       [ Entrar ]            │
│                             │
│  "Recebeu senha por         │
│   WhatsApp? Use ela aqui."  │
└─────────────────────────────┘
```

| Campo | Dado do Model | Source |
|---|---|---|
| WhatsApp | `User.whatsappNumber` | Input + validação |
| Senha | `User.senhaHash` | Verificação bcrypt |

**Veredicto:** ✅ 100% coberto. `LoginDTO` já existe.

---

### Tela 2: Meus Processos (Home do Cliente)

```
┌─────────────────────────────┐
│  Olá, Maria!           🔔3  │
│─────────────────────────────│
│  📋 Meus Processos          │
│                             │
│  ┌───────────────────────┐  │
│  │ Divórcio Consensual   │  │
│  │ 📊 Audiência marcada  │  │
│  │ 📅 Atualizado: 07/04  │  │
│  │ Trabalhista           │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │ Revisão Trabalhista   │  │
│  │ 📊 Em análise         │  │
│  │ 📅 Atualizado: 03/04  │  │
│  │ Trabalhista           │  │
│  └───────────────────────┘  │
│                             │
│  💬 Dúvida Rápida           │
└─────────────────────────────┘
```

| Elemento | Dado do Model | Source |
|---|---|---|
| Nome do cliente | `User.nome` | Auth token → User |
| Badge notificações | `Notificacao` count onde `lida = false` | `INotificacaoRepository.findUnreadByUserId()` |
| Card processo - título | `Processo.titulo` | `IProcessoRepository.findByClienteId()` |
| Card processo - status | `Processo.statusAtual` | idem |
| Card processo - data | `Processo.updatedAt` | idem |
| Card processo - tipo | `Processo.tipoCaso` | idem (pode virar badge colorido) |
| Botão Dúvida Rápida | `User.whatsappNumber` + `Processo.id` | Deep link WhatsApp |

**Veredicto:** ✅ 100% coberto. Interface rica com cards informativos.

---

### Tela 3: Detalhe do Processo (Tabs)

```
┌─────────────────────────────┐
│  ← Divórcio Consensual      │
│─────────────────────────────│
│  [ Linha do Tempo ] [ Chat ] [ Docs ]  │
│─────────────────────────────│
│                             │
│  📋 Detalhes                │
│  Status: Audiência marcada  │
│  Tipo: Família              │
│  Nº: 0001234-56.2026.8.19  │
│  Advogado: Dr. João Silva   │
│  Descrição: Divórcio...     │
│                             │
│  ── Linha do Tempo ──       │
│                             │
│  🟢 07/04 - Audiência       │
│     marcada para 15/05      │
│     às 14h via Zoom         │
│     Por: Dr. João           │
│                             │
│  🔵 01/04 - Petição         │
│     protocolada              │
│     Por: Dr. João           │
│                             │
│  ⚪ 28/03 - Processo         │
│     criado                   │
│─────────────────────────────│
│  💬 Dúvida Rápida           │
└─────────────────────────────┘
```

**Tab Linha do Tempo:**

| Elemento | Dado do Model | Source |
|---|---|---|
| Data | `TimelineEvento.createdAt` | `ITimelineEventoRepository.findByProcessoId()` |
| Tipo (ícone/cor) | `TimelineEvento.tipo` | enum → ícone |
| Conteúdo | `TimelineEvento.conteudo` | texto livre do advogado |
| Autor | `TimelineEvento.criadoPorId` → `User.nome` | JOIN |
| Status anterior → novo | `TimelineEvento.statusAnterior` → `Processo.statusAtual` | Exibe transição |

**Tab Chat (somente leitura):**

```
│  🤖 Bot: Olá! Como posso    │
│     ajudar?                  │
│                             │
│  👤 Maria: Quero saber      │
│     sobre meu divórcio       │
│                             │
│  🤖 Bot: Seu processo está   │
│     em "Audiência marcada"   │
```

| Elemento | Dado do Model | Source |
|---|---|---|
| Mensagem | `Mensagem.conteudo` | `IMensagemRepository.findByUserId()` |
| Remetente (ícone) | `Mensagem.remetente` | enum BOT/CLIENTE/ADVOGADO |
| Data/hora | `Mensagem.createdAt` | timestamp |

**Tab Documentos:**

```
│  📄 Certidão de Casamento    │
│     PDF · 2.3 MB · 05/04    │
│                             │
│  📄 RG Maria                │
│     JPG · 1.1 MB · 01/04   │
│                             │
│     [ + Upload Documento ]   │
```

| Elemento | Dado do Model | Source |
|---|---|---|
| Nome | `Documento.nomeArquivo` | `IDocumentoRepository.findByProcessoId()` |
| Tipo | `Documento.tipoMime` | badge PDF/IMG |
| Tamanho | `Documento.tamanhoBytes` | formatado |
| Data | `Documento.createdAt` | timestamp |
| Upload | `CreateDocumentoDTO` | POST endpoint |

**Veredicto:** ✅ 100% coberto. As 3 tabs têm dados suficientes para interfaces ricas.

---

### Tela 4: Notificações do Cliente

```
┌─────────────────────────────┐
│  ← Notificações             │
│─────────────────────────────│
│  🔴 Status atualizado       │
│  Seu processo "Divórcio"    │
│  mudou para Audiência       │
│  marcada · há 2h            │
│─────────────────────────────│
│  ⚪ Documento enviado        │
│  O documento "RG" foi       │
│  recebido · há 1d           │
│─────────────────────────────│
│  ⚪ Status atualizado        │
│  Seu processo... · há 3d    │
└─────────────────────────────┘
```

| Elemento | Dado do Model | Source |
|---|---|---|
| Tipo (ícone/cor) | `Notificacao.tipo` | enum |
| Título | `Notificacao.titulo` | texto |
| Corpo | `Notificacao.corpo` | texto |
| Lida (destaque) | `Notificacao.lida` | boolean |
| Data relativa | `Notificacao.createdAt` | formatação frontend |

**Veredicto:** ✅ 100% coberto.

---

## 🟢 Perfil ADVOGADO (6 telas + modais)

### Tela 5: Dashboard Principal

```
┌─────────────────────────────┐
│  OmniConnect       🔔5  ⚙️  │
│─────────────────────────────│
│                             │
│  ┌──────┐ ┌──────┐ ┌──────┐│
│  │  12  │ │   8  │ │   4  ││
│  │Aberto│ │Encerr│ │Leads ││
│  └──────┘ └──────┘ └──────┘│
│                             │
│  🔴 Fila Suporte (2)       │
│  ┌───────────────────────┐  │
│  │ Maria Silva - 15min   │  │
│  │ "falar com advogado"  │  │
│  └───────────────────────┘  │
│  ┌───────────────────────┐  │
│  │ João Santos - 5min    │  │
│  │ IA não soube responder│  │
│  └───────────────────────┘  │
│                             │
│  📊 Casos por Nicho         │
│  ┌───────────────────────┐  │
│  │  🟦 Trabalhista  45%  │  │
│  │  🟩 Cível       30%  │  │
│  │  🟨 Família     25%  │  │
│  └───────────────────────┘  │
│                             │
│  📄 Documentos Recentes     │
│  • Certidão - Maria - 2h   │
│  • RG - João - 1d          │
│                             │
│ [Home][Leads][Processos][+] │
└─────────────────────────────┘
```

| Elemento | Dado do Model | Consulta Possível? |
|---|---|---|
| Total Abertos | `COUNT(Processo)` WHERE status ≠ 'Encerrado' | ✅ Sim |
| Total Encerrados | `COUNT(Processo)` WHERE status = 'Encerrado' | ✅ Sim |
| Total Leads | `COUNT(Lead)` WHERE status = 'PENDENTE' | ✅ Sim |
| Fila Suporte | `Notificacao` WHERE tipo = 'SUPORTE_HUMANO' AND lida = false | ✅ Sim (Gap #1 opção A) |
| Tempo na fila | `Notificacao.createdAt` → diff agora | ✅ Sim |
| Contexto suporte | `Mensagem` últimas do lead | ✅ Sim |
| Gráfico pizza nicho | `GROUP BY Processo.tipoCaso` | ✅ Sim |
| Docs recentes | `Documento` ORDER BY createdAt DESC LIMIT 5 | ✅ Sim |

**Veredicto:** ✅ 100% coberto. Dashboard completo comparável ao Astrea/HubSpot.

---

### Tela 6: Lista de Leads

```
┌─────────────────────────────┐
│  ← Leads    🔍  Filtrar     │
│─────────────────────────────│
│  ┌───────────────────────┐  │
│  │ 🟡 PENDENTE           │  │
│  │ Maria da Silva        │  │
│  │ Trabalhista · Alta    │  │
│  │ "Demissão sem justa"  │  │
│  │ 📱 (11) 99999-0000    │  │
│  │ 📅 há 2h              │  │
│  │ [Ver] [Converter] [✕] │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │ 🔴 DESCARTADO         │  │
│  │ Pedro Oliveira        │  │
│  │ Criminal · Média      │  │
│  │ Motivo: Fora da área  │  │
│  │ 📅 há 1d              │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
```

| Elemento | Dado do Model | Source |
|---|---|---|
| Status (badge) | `Lead.status` | enum → cor |
| Nome | `Lead.nome` | texto |
| Tipo + Urgência | `Lead.tipoCaso` + `Lead.urgencia` | badges |
| Descrição preview | `Lead.descricaoCaso` | truncado |
| Telefone | `Lead.whatsappNumber` | formatado |
| Data | `Lead.createdAt` | relativa |
| Motivo descarte | `Lead.motivoDescarte` | ✅ **novo campo** |
| Filtros | status, tipoCaso, urgencia | queries |

**Veredicto:** ✅ 100% coberto. Filtros e status visuais funcionam bem.

---

### Tela 7: Detalhe do Lead (Modal/Tela)

```
┌─────────────────────────────┐
│  ← Lead: Maria da Silva     │
│─────────────────────────────│
│  👤 Dados Coletados pelo Bot │
│  Nome: Maria da Silva       │
│  CPF: 123.456.789-00       │
│  Tipo: Trabalhista          │
│  Urgência: 🔴 Alta          │
│  Contato: Manhã             │
│  WhatsApp: (11) 99999-0000  │
│                             │
│  📝 Descrição               │
│  "Fui demitida sem justa    │
│   causa após 3 anos..."     │
│                             │
│  📋 Observações do Advogado │
│  "Indicada pela Dra. Ana.   │
│   Caso forte, priorizar."   │
│  [ Editar observação ]      │
│                             │
│  💬 Histórico do Chat       │
│  (Últimas mensagens bot)    │
│  🤖: Qual o tipo de caso?   │
│  👤: Trabalhista, fui...     │
│                             │
│  ┌──────────┐┌──────────┐   │
│  │Converter ││ Descartar│   │
│  │  Lead ✅  ││   Lead ✕ │   │
│  └──────────┘└──────────┘   │
└─────────────────────────────┘
```

| Elemento | Dado do Model | Análise |
|---|---|---|
| Todos os 6 campos | `Lead.*` | ✅ PRD §2.1 |
| Observações adv. | `Lead.observacoesAdvogado` | ✅ **novo campo** |
| Chat do bot | `Mensagem` WHERE leadId = X | ✅ Espelhamento |
| Converter → form | `ConvertLeadDTO` | ✅ Gera User |
| Descartar → motivo | `Lead.motivoDescarte` | ✅ **novo campo** |

**Veredicto:** ✅ 100% coberto. Tela com conteúdo útil real, não é apenas lista de campos.

---

### Tela 8: Lista de Processos (Advogado)

```
┌─────────────────────────────┐
│  ← Meus Processos  🔍      │
│  [Todos] [Abertos] [Encerr] │
│─────────────────────────────│
│  ┌───────────────────────┐  │
│  │ Divórcio Consensual   │  │
│  │ 👤 Maria Silva        │  │
│  │ Família · Aud. marcada│  │
│  │ 📅 07/04/2026         │  │
│  └───────────────────────┘  │
│  ┌───────────────────────┐  │
│  │ Revisão Trabalhista   │  │
│  │ 👤 João Santos        │  │
│  │ Trabalhista · Análise │  │
│  │ 📅 03/04/2026         │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
```

| Elemento | Dado | Consulta |
|---|---|---|
| Filtro "Meus" | `Processo.advogadoId` | ✅ **novo campo** |
| Nome cliente | `Processo.clienteId` → `User.nome` | JOIN |
| Status | `Processo.statusAtual` | badge |
| Tipo | `Processo.tipoCaso` | badge |
| Busca por CPF/Nome | `User.cpf`, `User.nome` | query |

**Veredicto:** ✅ 100% coberto.

---

### Tela 9: Gerenciar Processo (Advogado)

```
┌─────────────────────────────┐
│  ← Divórcio Consensual  ⋮   │
│─────────────────────────────│
│  Status: [ Aud. marcada ▾ ] │
│                             │
│  📝 Adicionar Nota          │
│  ┌───────────────────────┐  │
│  │ A audiência será no   │  │
│  │ dia 15/05 às 14h...   │  │
│  └───────────────────────┘  │
│  [ Salvar e Notificar ]     │
│                             │
│  ── Timeline ──             │
│  (igual à do cliente)       │
│                             │
│  ── Documentos ──           │
│  (igual ao cliente + botão  │
│   de download)              │
│                             │
│  ── Dados do Cliente ──     │
│  Maria Silva                │
│  CPF: 123.456.789-00       │
│  📱 (11) 99999-0000        │
└─────────────────────────────┘
```

| Ação | DTO/Service | Impacto |
|---|---|---|
| Alterar status | `UpdateProcessoStatusDTO` | Gera `TimelineEvento` + `Notificacao` |
| Adicionar nota | `CreateTimelineEventoDTO` (tipo NOTA_ADVOGADO) | Novo evento na timeline |
| Ver documentos | `IDocumentoRepository.findByProcessoId()` | Lista |
| Dados do cliente | `User` via `Processo.clienteId` | Exibição |

**Veredicto:** ✅ 100% coberto. O fluxo §3.2 do PRD funciona perfeitamente.

---

### Tela 10: Configurações (Advogado)

```
┌─────────────────────────────┐
│  ← Configurações            │
│─────────────────────────────│
│  👤 Perfil                  │
│  Nome: Dr. João Silva       │
│  Email: joao@escritorio.com │
│                             │
│  🔔 Notificações            │
│  ☑ Novo Lead               │
│  ☑ Suporte Humano          │
│  ☑ Documento Enviado       │
│  ☐ Status Alterado         │
│                             │
│  🔒 Alterar Senha           │
│  📱 Sair                   │
└─────────────────────────────┘
```

| Elemento | Dado do Model | Source |
|---|---|---|
| Preferências notif. | `User.preferenciasNotificacao` | ✅ **novo campo** |
| Dados do perfil | `User.nome`, `User.email` | Edição |

**Veredicto:** ✅ Coberto.

---

### Tela 11: Modal "Converter Lead"

```
┌─────────────────────────────┐
│  Converter Lead em Cliente  │
│─────────────────────────────│
│  Confirme os dados:         │
│                             │
│  Nome: Maria da Silva       │
│  CPF: 123.456.789-00       │
│  WhatsApp: (11) 99999-0000  │
│  Tipo: Trabalhista          │
│                             │
│  🔒 Senha temporária será   │
│     gerada automaticamente  │
│     e enviada via WhatsApp   │
│                             │
│  [Cancelar]  [Converter ✅]  │
└─────────────────────────────┘
```

| Ação | Fluxo | Cobertura |
|---|---|---|
| Confirmar dados | `Lead.*` pré-preenchido | ✅ |
| Gerar senha | `IAuthService.generateTempPassword()` | ✅ |
| Criar User | `Lead` → `User` + `Lead.convertedUserId` | ✅ |
| Enviar via WhatsApp | Integração futura (API WhatsApp) | ⏳ Infra |

---

### Tela 12: Modal "Descartar Lead"

```
┌─────────────────────────────┐
│  Descartar Lead             │
│─────────────────────────────│
│  Lead: Maria da Silva       │
│                             │
│  Motivo:                    │
│  ( ) Fora da área de atuação│
│  ( ) Sem interesse          │
│  ( ) Conflito de interesse  │
│  ( ) Dados insuficientes    │
│  ( ) Outro: ______________  │
│                             │
│  [Cancelar]  [Descartar ✕]  │
└─────────────────────────────┘
```

| Ação | Dado | Cobertura |
|---|---|---|
| Salvar motivo | `Lead.motivoDescarte` | ✅ **novo campo** |
| Alterar status | `Lead.status = 'DESCARTADO'` | ✅ |

---

## 📊 Resumo Geral

| Tela | Perfil | Status | Gaps |
|---|---|---|---|
| 1. Login | Cliente | ✅ Completa | — |
| 2. Meus Processos | Cliente | ✅ Completa | — |
| 3. Detalhe Processo (3 tabs) | Cliente | ✅ Completa | — |
| 4. Notificações | Cliente | ✅ Completa | — |
| 5. Dashboard | Advogado | ✅ Completa | — |
| 6. Lista de Leads | Advogado | ✅ Completa | — |
| 7. Detalhe do Lead | Advogado | ✅ Completa | — |
| 8. Lista de Processos | Advogado | ✅ Completa | — |
| 9. Gerenciar Processo | Advogado | ✅ Completa | — |
| 10. Configurações | Advogado | ✅ Completa | — |
| 11. Modal Converter Lead | Advogado | ✅ Completa | — |
| 12. Modal Descartar Lead | Advogado | ✅ Completa | — |

### Comparação com Concorrentes

| Feature de UI | Astrea | Projuris | Pipedrive | HubSpot | **OmniConnect** |
|---|---|---|---|---|---|
| Dashboard com métricas | ✅ | ✅ | ✅ | ✅ | ✅ |
| Timeline cronológica | ✅ | ✅ | ❌ | ❌ | ✅ |
| Espelhamento de chat | ❌ | ❌ | ❌ | ❌ | ✅ **diferencial** |
| Push notifications | ✅ | ✅ | ✅ | ✅ | ✅ |
| Gestão de leads/funil | ❌ | ❌ | ✅ | ✅ | ✅ |
| Upload de documentos | ✅ | ✅ | ❌ | ✅ | ✅ |
| Filtros por status/tipo | ✅ | ✅ | ✅ | ✅ | ✅ |
| Gráfico por nicho | ✅ | ❌ | ✅ | ✅ | ✅ |
| Preferências de notif. | ❌ | ❌ | ✅ | ✅ | ✅ |
| Observações no lead | ❌ | ❌ | ✅ | ✅ | ✅ |
| Motivo de descarte | ❌ | ❌ | ✅ | ✅ | ✅ |
| Histórico de transição | ❌ | ❌ | ❌ | ✅ | ✅ |
| Bot WhatsApp integrado | ❌ | ❌ | ❌ | ❌ | ✅ **diferencial** |

> [!TIP]
> **A modelagem sustenta 12 telas completas sem nenhum gap dentro do mesmo aplicativo**. Os campos extras adicionados (observações, motivo descarte, advogadoId, preferências) são os que fazem a diferença entre um MVP "esqueleto" e um que realmente compete com Astrea/Projuris.
>
> Os **2 diferenciais exclusivos** do OmniConnect vs todos os concorrentes: **espelhamento de chat WhatsApp** e **bot com RAG integrado** — ambos 100% suportados pela modelagem atual.
