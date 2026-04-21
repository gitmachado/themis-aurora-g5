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

### 3.3 Refatoração Sub-Feature por Funcionalidade ✅ (Concluído em 21/04/2026)
**Problema identificado:** `client` e `lawyer` acumulavam *todas* as telas e widgets em pastas planas de `presentation/`. Com o crescimento do app (~23 arquivos de UI), a busca por arquivos específicos tornou-se ineficiente e o acoplamento cresceu.

**Solução: Vertical Slicing + Full Clean Architecture.**
Cada funcionalidade foi isolada em uma sub-feature auto-contida. Se uma feature for removida, 100% do seu código (UI, lógica e dados) é removido sem deixar órfãos.

#### Estrutura Detalhada Implementada
Cada uma das **15 sub-features** abaixo recebeu a estrutura completa de 9 sub-pastas:

- **Client (6 features):** `home`, `chat`, `documents`, `processes`, `notifications`, `profile`
- **Lawyer (9 features):** `overview`, `leads`, `chat`, `ai_manager`, `processes`, `clients`, `documents`, `notifications`, `profile`

**Template de Pastas (Aplicado a cada sub-feature):**
```
feature_name/
├── data/
│   ├── data_sources/    ← Chamadas Remote (API) / Local (Cache)
│   ├── models/          ← DTOs (Data Transfer Objects)
│   └── repositories/    ← Implementações dos repositórios
├── domain/
│   ├── entities/        ← Modelos de negócio puros
│   ├── repositories/    ← Interfaces/Contratos (abstract classes)
│   └── usecases/        ← Regras de execução (ex: GetProcessTimeline)
└── presentation/
    ├── providers/       ← Riverpod providers/notifiers
    ├── screens/         ← Páginas inteiras (Scaffolds)
    └── widgets/         ← Componentes exclusivos da feature
```

#### Mudanças Significativas
- **Promoção de Componentes:** O widget `LawyerAppBarActions` foi movido para `shared/widgets/` por ser compartilhado entre 4 sub-features distintas do advogado.
- **Roteamento:** O `AppRouter` foi totalmente atualizado para refletir os novos caminhos físicos dos arquivos.
- **Limpeza:** Pastas temporárias de `data/` e `domain/` que estavam no nível do módulo (role) foram eliminadas em favor da estrutura distribuída por funcionalidade.


---

## 4. Próximos Passos Técnicos (Mobile)

- [x] Executar refatoração sub-feature (Vertical Slicing)
- [x] Atualizar `app_router.dart` com novos import paths
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
