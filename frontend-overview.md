# frontend-overview.md — OmniConnect G5

> Documento vivo de acompanhamento do desenvolvimento do **módulo mobile** (Flutter).
> Registra tudo que foi feito pela equipe de frontend e o que está sendo consolidado/evoluído
> pelo responsável técnico. Destinado a comunicação interna e handoff para o time.

---

## 1. Equipe e Responsabilidades

| Pessoa | Papel | Entregas no PR #21 |
|---|---|---|
| **Alan** | Frontend Mobile | Telas do Cliente (home, chats, documentos, processos, perfil, notificações) |
| **Lucas** | Frontend Mobile | Telas do Advogado (overview, leads, processos, clientes, documentos, IA, chats, perfil) |
| **Maurício** | Tech Lead / Arquitetura | Consolidação, revisão arquitetural, ajustes pós-PR |

---

## 2. Resumo da Implementação (PR #21 — Baseline)

O PR #21 consolida as entregas de **Alan (PR #18)** e **Lucas (PR #19)** sob a branch
`feat/G5-22-lawyer-profile-screens`, unificada contra `development`.

### 2.1 O que foi entregue

#### Módulo Cliente (Alan)
- **Home:** Cards de atualização de processo (`HeroUpdateCard`), card de acesso rápido à IA (`QuickAICard`) e card de notícias jurídicas (`LawNewsCard`)
- **Chats:** Lista de conversas (`ClientChatsScreen`) e espelho de chat (`ClientChatMirrorScreen`) com bubbles customizadas
- **Documentos:** Lista com filtros por tipo (`DocumentFilterChips`)
- **Processos:** Lista de processos e timeline visual com eventos (`TimelineEventTile`, `TimelineSummaryCard`)
- **Notificações:** Tela de notificações
- **Perfil:** Tela de perfil do cliente

#### Módulo Advogado (Lucas)
- **Overview (Dashboard):** Header com métricas (`DashboardHeader`), cards de KPI (`MetricCard`, `LawyerMetricCard`), gráfico de nicho (`NicheChart`), lista rápida de leads e documentos recentes
- **Leads:** Triagem com filtros de urgência (`LawyerLeadTriageScreen`), detalhe do lead (`LawyerLeadDetailScreen`), card customizado (`LeadCard`)
- **Chats:** Lista de conversas (`LawyerChatListScreen`), tela de handoff IA→Advogado (`LawyerChatHandoffScreen`)
- **IA Manager:** Gerenciamento e configuração da IA (`LawyerAIManagerScreen`)
- **Processos:** Lista e detalhe de processos
- **Clientes:** Lista e detalhe de clientes vinculados
- **Documentos:** Lista e revisão de documentos
- **Notificações:** Tela de notificações do advogado
- **Perfil + Configurações:** Perfil e sub-tela de configurações

### 2.2 Componentes Compartilhados (shared/)
Widgets agnósticos de role, utilizados por ambos os módulos:

| Widget | Descrição |
|---|---|
| `CustomAppBar` | AppBar padrão com título e ações |
| `AppBottomNavigationBar` | Bottom nav customizada com `NavItem` |
| `PrimaryButton` | Botão CTA padrão |
| `AppBadge` | Chip de status (Primary, Success, Error, Warning) |
| `AppCard` | Container card com sombra e border radius |
| `AppListTile` | List tile padronizado |
| `AppSearchInput` | Campo de busca |
| `ClientMainLayout` | Layout base do cliente (IndexedStack, 4 abas) |
| `LawyerMainLayout` | Layout base do advogado (IndexedStack, 5 abas) |

### 2.3 Design System
- `AppColors` — paleta de cores (primary, secondary, error, success, caption, divider)
- `AppTextStyles` — tipografia (h1, h2, body, caption)
- `DesignSystemScreen` — showcase interativo de todos os componentes (acesso via rota `/design-system`)

### 2.4 Roteamento
- Roteamento centralizado em `AppRouter` via `onGenerateRoute` com named routes
- Rota inicial: `/login`
- Separação clara entre rotas de cliente e advogado

---

## 3. Ajustes Arquiteturais Pós-PR (Maurício — em andamento)

### 3.1 Reorganização Feature-First ✅
**Problema identificado:** A pasta `features/dashboard` existia fora do módulo `lawyer`,
quebrando o encapsulamento do role.

**Ação:** Movidos `LawyerDashboardScreen` (e widgets associados) para dentro de
`features/lawyer/presentation/`. Classe renomeada para `LawyerOverviewScreen` para
melhor semântica (o nome "dashboard" é genérico; "overview" reflete o que a tela faz).

Arquivos movidos:
- `features/dashboard/presentation/screens/lawyer_dashboard_screen.dart` → `features/lawyer/presentation/screens/lawyer_overview_screen.dart`
- `features/dashboard/presentation/widgets/{dashboard_header, metric_card, niche_chart}.dart` → `features/lawyer/presentation/widgets/`

Pasta `features/dashboard/` removida.

### 3.2 Scaffolding Clean Architecture ✅
**Problema:** As features só tinham camada `presentation`. A ausência das camadas
`data/` e `domain/` impediria a integração com a API sem uma refatoração futura custosa.

**Ação:** Criadas as pastas obrigatórias com `.gitkeep` em `client/` e `lawyer/`:
```
client/
  data/  {data_sources, models, repositories}
  domain/ {entities, repositories, usecases}
  presentation/ {screens, widgets, providers}

lawyer/
  data/  {data_sources, models, repositories}
  domain/ {entities, repositories, usecases}
  presentation/ {screens, widgets, providers}
```

### 3.3 Refatoração Sub-Feature por Funcionalidade 🔄 (em progresso)
**Problema identificado:** `client` e `lawyer` acumulam *todas* as telas em uma única
pasta `presentation/screens/`. Com 8 telas no cliente e 14 no advogado, a navegação
pelo código fica custosa. Ao buscar um bug no chat, o desenvolvedor passa por telas
de processos, documentos e perfil antes de encontrar o arquivo certo.

**Decisão de arquitetura:** Transformar `client` e `lawyer` em **módulos de role**, com **sub-features funcionais auto-contidas (Vertical Slicing)**. Cada funcionalidade possui suas próprias camadas de `data/`, `domain/` e `presentation/`.

**Nova estrutura target:**
```
client/
  chat/
    data/
    domain/
    presentation/{screens, widgets, providers}
  home/
    data/
    domain/
    presentation/
  ...etc

lawyer/
  leads/
    data/
    domain/
    presentation/
  ...etc
```

**Rationale:** Isolamento total de responsabilidades. Um bug no chat é resolvido exclusivamente dentro da sub-pasta de chat, abrangendo desde a interface até o modelo de dados e repositório. Previne conflitos de merge e garante que a arquitetura evolua de forma previsível.

---

## 4. Próximos Passos Técnicos (Mobile)

- [ ] Executar refatoração sub-feature (Seção 3.3)
- [ ] Atualizar `app_router.dart` com novos import paths
- [ ] Sincronizar ADR de arquitetura mobile (`.agents/decisions/` e `documentation/decisions/`)
- [ ] Integrar com API REST (autenticação via `whatsappNumber + password`)
- [ ] Adicionar Riverpod providers reais por feature

---

## 5. Notas Técnicas Importantes

- **State management:** App usa `StatefulWidget` nativo. Riverpod está configurado (`flutter_riverpod`) mas sem providers de negócio ainda.
- **Navegação:** `Navigator 1.0` com named routes. Para integração futura considerar migração para `GoRouter`.
- **Dados:** Todos os dados são estáticos (mocked). Nenhuma chamada de API implementada ainda.
- **Build target:** Android físico (SM A546E) — testado e funcional em debug mode.
- **Flavor/Env:** Sem configuração de ambiente ainda. Uma única configuração de app.
