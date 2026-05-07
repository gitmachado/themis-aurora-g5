# Decisão 0007: Arquitetura de Runtime do App Mobile

### 1. Título
Decisão 0007: Composição em Camadas do Runtime Mobile (Bootstrap, App Shell, Theming, Camada Compartilhada)

### 2. Status
- **Activated**

### 3. Contexto
A [ADR 0005](0005-arquitetura-frontend-flutter.md) consolidou a estrutura de pastas do app mobile em **Full Vertical Slicing por sub-feature** sobre **Clean Architecture**, mas tratou apenas da organização **horizontal** (como features se distribuem em `lib/features/<role>/<sub>`). Conforme o app cresceu — autenticação, push notifications, navegação por rotas nomeadas, theming customizado, conexão WebSocket persistente, layouts compartilhados por perfil — surgiu uma camada **transversal** que não pertence a nenhuma sub-feature mas precisa ter contrato e lugar definidos:

- O `main.dart` ganhou responsabilidades não-triviais (bootstrap do Firebase, registro de handler de FCM em background, configuração de SystemChrome para edge-to-edge).
- O `MaterialApp` precisa de um **`navigatorKey` global** para que serviços fora da árvore de widgets (notificações, deep links, interceptors HTTP) consigam navegar.
- O **roteamento** ficou centralizado num único `AppRouter` com `onGenerateRoute`, e qualquer feature nova precisa registrar suas rotas ali.
- A pasta `lib/shared/` foi crescendo sem critério — corremos o risco de ela virar lixeira caso não seja governada.

Sem registro formal dessas decisões, novos colaboradores duplicam responsabilidades (ex: criar um `MaterialApp` próprio dentro de uma feature, instanciar um `Dio` paralelo ao `ApiClient` central) e a arquitetura horizontal da 0005 perde sustentação.

### 4. Decisão
O runtime do app mobile é dividido em **quatro camadas concêntricas**, cada uma com responsabilidade exclusiva:

#### Camada 1 — Bootstrap (`lib/main.dart`)
Único ponto autorizado a executar **side effects de inicialização global** antes de `runApp`. Inclui:

- `WidgetsFlutterBinding.ensureInitialized()`
- Inicialização do Firebase (`Firebase.initializeApp()`)
- Registro do handler de **FCM background** (`FirebaseMessaging.onBackgroundMessage`) — obrigatoriamente uma função top-level por restrição de isolate.
- Configuração de `SystemChrome` (overlay style, edge-to-edge).
- Montagem da árvore com `ProviderScope` envolvendo `ThemisApp`.

Nada além disso. Lógica de domínio, navegação ou rede **não** pode aparecer aqui.

#### Camada 2 — App Shell (`lib/app/`)
Container Material da aplicação:

- **`app/app.dart`** define `ThemisApp` e o `MaterialApp` com `theme`, `navigatorKey`, `initialRoute` e `onGenerateRoute`.
- **`app/navigation_service.dart`** expõe um `navigatorKey` global e helpers de navegação imperativa (`Navigator.of(navigatorKey.currentContext!)`), usados por serviços fora da árvore (push notifications, refresh de token).
- **`app/routes/app_router.dart`** centraliza **todas** as rotas nomeadas. Adicionar uma tela nova exige registro nesse arquivo.
- **`app/config/`** carrega configurações de ambiente (base URL da API, flags por flavor).
- **`app/theme/`** consolida `AppTheme` com cores, tipografia e tokens de design.

#### Camada 3 — Camada Compartilhada (`lib/shared/`)
Infraestrutura **transversal** consumida por múltiplas features. Subdividida com regras estritas:

| Subpasta | Conteúdo permitido |
|---|---|
| `constants/` | Constantes puras (sem lógica nem estado) |
| `errors/` | Tipos de `Failure` + extensões fpdart para Either/Option |
| `network/` | `ApiClient` (Dio), `ApiConfig`, `ApiException`, `TokenStorage`, `WebSocketClient` |
| `services/` | Serviços singleton sem UI (ex: `PushNotificationService`) |
| `utils/` | Helpers puros sem dependência de feature |
| `widgets/` | Componentes visuais reutilizados por **2+ features** (AppBars, NavBars, Buttons, Skeletons, Layouts por perfil) |

**Critério de admissão em `shared/widgets/`**: o widget é consumido por pelo menos duas sub-features e expressa identidade de marca (NavBar, AppBar, layout principal por perfil). Componentes visuais usados por uma única sub-feature pertencem ao `presentation/widgets/` daquela sub-feature.

#### Camada 4 — Features (`lib/features/`)
Documentada na [ADR 0005](0005-arquitetura-frontend-flutter.md). As features **só podem importar de**: outras camadas da própria sub-feature, `shared/`, ou pacotes externos. **Nunca** de outras sub-features (acoplamento horizontal proibido — orquestração entre sub-features fica nas camadas 1-3).

### 5. Consequências

- **Positivas:**
  - Bootstrap fica auditável e testável (uma função top-level com side effects bem listados).
  - `navigatorKey` global resolve a navegação a partir de notificações sem `BuildContext`.
  - O contrato da `shared/` impede que ela vire lixeira: cada subpasta tem definição do que aceita.
  - Features são plug-and-play: registrar a rota no `AppRouter` é o único toque externo necessário.

- **Negativas:**
  - Cada nova tela exige passo extra de registro no `AppRouter` (não há descoberta automática de rotas).
  - O `main.dart` virou ponto crítico — bugs nele afetam todo o ciclo de vida do app.
  - Push notification handlers em background precisam ser top-level functions, o que limita refatorações para classes.

- **Impacto no Backend:**
  - O `ApiClient` central impõe interceptors padronizados (Bearer token, refresh, error mapping). Backend pode contar com formato consistente de header e respostas tratadas conforme [ADR 0006](0006-deploy-mvp-e-hardening.md).

### 6. Alternativas Consideradas

- **`go_router` no lugar do `onGenerateRoute` manual:** mais ergonômico, mas adicionaria dependência e migração de todas as rotas existentes. Adiado para após o MVP.
- **Spread do bootstrap em providers Riverpod (ex: `firebaseInitProvider`):** Firebase exige init síncrono antes de `runApp`, então providers precisam de override de host — complexidade desnecessária para o ganho.
- **Múltiplos `MaterialApp` por perfil (cliente vs advogado):** rejeitado por duplicar theming, navegação e bootstrap. O runtime único com `lawyer_main_layout` e `client_main_layout` em `shared/widgets/layout/` já isola UI sem fragmentar o shell.

---
> [!IMPORTANT]
> Adicionar dependência transversal nova (ex: analytics, crash reporter) significa: (1) inicializar no `main.dart` se exigir setup pré-`runApp`, (2) expor via provider ou serviço em `shared/services/`, (3) **nunca** instanciar dentro de uma feature.
