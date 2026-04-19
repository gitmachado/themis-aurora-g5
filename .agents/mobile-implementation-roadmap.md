# Roadmap de Implementação — Frontend Flutter OmniConnect

> **Objetivo:** Guia definitivo para o time de frontend, cobrindo a ordem lógica de implementação desde a conclusão das telas até o app funcionando com integração real com o backend.

---

## Contexto atual

O time está implementando as **telas estáticas** (screens + widgets) das telas planejadas no Pencil. A estrutura de pastas já segue a **Feature-First Clean Architecture** com as camadas:

```
features/<feature>/
├── domain/
│   ├── entities/      ← modelos de negócio puros (sem JSON, sem Flutter)
│   ├── repositories/  ← contratos abstratos (interfaces)
│   └── usecases/      ← regras de negócio
├── data/
│   ├── models/        ← entidades + fromJson/toJson
│   ├── datasources/   ← chamadas HTTP reais
│   └── repositories/  ← implementação concreta dos contratos
└── presentation/
    ├── providers/     ← Riverpod: estado e injeção de dependência
    ├── screens/       ← telas completas (em andamento ✅)
    └── widgets/       ← componentes da feature (em andamento ✅)
```

---

## Por que essa ordem importa?

Cada camada **depende da anterior**:

```
UI (screens) → Providers → Use Cases → Repository Interface → Repository Impl → DataSource → API
```

Implementar providers sem domain e data é montar a cola antes de ter as peças. Você pode ter providers com dados mockados temporariamente, mas a versão real só faz sentido após as camadas inferiores estarem prontas.

---

## Divisão de Responsabilidades por Papel

Esta arquitetura permite uma **divisão clara entre o Tech Lead (backend) e o time de Frontend**, eliminando bloqueios e decisões equivocadas nas camadas erradas.

### Tech Lead entrega (a "SDK interna")

| O que | Onde | Por quê é dele |
|-------|------|----------------|
| Entities | `domain/entities/` | Exige conhecimento do domínio de negócio |
| Repository interfaces | `domain/repositories/` | Define o contrato entre as camadas |
| Use Cases | `domain/usecases/` | Regras de negócio que o backend conhece |
| Models com `fromJson/toJson` | `data/models/` | Exige conhecimento do JSON da API |
| DataSources com endpoints | `data/datasources/` | Exige conhecimento dos endpoints do backend |
| Shared infra | `shared/` | HTTP client, erros, constantes |

### Frontend implementa ("liga os pontos")

| O que | Onde | O que precisa saber |
|-------|------|---------------------|
| Repository implementations | `data/repositories/` | Chama o datasource, devolve `Either` |
| Providers de injeção | `presentation/providers/` | Instancia e conecta as dependências |
| StateNotifiers / AsyncNotifiers | `presentation/providers/` | Expõe estado para a UI |
| Conectar screens aos providers | `presentation/screens/` | `ref.watch`, `ref.read`, `ConsumerWidget` |

### Por que funciona

O frontend **nunca toma decisão de API**. Eles recebem:
- A interface que devem implementar (do domain)
- As chamadas HTTP prontas (do datasource)
- Os objetos mapeados (dos models)

Sua única responsabilidade é a **cola entre as camadas** e a **ligação com a UI** — 100% Dart/Flutter, zero conhecimento de backend.

```
Tech Lead entrega → AuthDataSource.login(whatsappNumber, password)
Frontend usa     → AuthRepositoryImpl chama isso e devolve Either<Failure, User>
Frontend usa     → Provider injeta o repositório e expõe estado
Frontend usa     → Screen consome o provider via ref.watch
```

### Fluxo de trabalho por fase

```
[AGORA — em paralelo com as telas]
Tech Lead: shared/network + shared/errors + shared/constants     ← independente das telas

[Após frontend entregar a branch com todas as telas]
Tech Lead: merge da branch + atualiza docs dos agentes de IA
Tech Lead: fecha theme.dart + app_router.dart                    ← depende das telas prontas
Tech Lead: domain/ feature por feature                           ← contratos (entities + interfaces + use cases)
Tech Lead: data/models/ + data/datasources/ por feature          ← SDK interna (mapeamento da API)

[Após Tech Lead entregar models + datasources de uma feature]
Frontend:  data/repositories/ dessa feature                      ← cola as camadas
Frontend:  providers + conecta a UI dessa feature                ← liga os pontos

[Após todas as features integradas]
Tech Lead: revisão de integração E2E
Thiago:    QA — testes funcionais, fluxos críticos, regressão
```

---

## FASE 0 — Fundação Compartilhada

> A Fase 0 é dividida em dois momentos:
> - **Pode fazer agora** (independe das telas): `shared/network`, `shared/errors`, `shared/constants`
> - **Aguarda a branch das telas**: `theme.dart` e `app_router.dart` (dependem do design e das rotas finais)

### 0.1 — `shared/network/` — Cliente HTTP

Criar o cliente HTTP centralizado que todos os datasources vão usar.

```dart
// shared/network/api_client.dart
class ApiClient {
  final Dio _dio;
  // baseUrl, interceptors de auth, timeout, error mapping
}
```

**O que configurar:**
- `baseUrl` via variável de ambiente (`--dart-define` ou `.env`)
- Interceptor de autenticação (anexa JWT no header)
- Interceptor de erro (mapeia status HTTP → exceções do domínio)
- Timeout padrão

### 0.2 — `shared/errors/` — Hierarquia de Falhas

```dart
// shared/errors/failures.dart
sealed class Failure {
  final String message;
}

class ServerFailure extends Failure { ... }
class NetworkFailure extends Failure { ... }
class CacheFailure extends Failure { ... }
class AuthFailure extends Failure { ... }
```

**Por que:** Todos os repositórios retornam `Either<Failure, T>` (usando `fpdart` ou similar). Sem isso, tratamento de erro vira `try/catch` espalhado por todo lado.

### 0.3 — `shared/constants/` — Constantes globais

```dart
// shared/constants/app_constants.dart
class AppConstants {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL');
  static const Duration requestTimeout = Duration(seconds: 30);
}
```

### 0.4 — `app/theme/theme.dart` — Design System completo

> ⚠️ **Aguarda a branch das telas.** O tema deve refletir as decisões finais de design do Pencil.

O arquivo atual retorna apenas `ThemeData(useMaterial3: true)`. Precisa ser expandido com:
- Paleta de cores do OmniConnect (primária, secundária, erro, superfície)
- `TextTheme` com as fontes definidas no Pencil
- `AppBarTheme`, `CardTheme`, `InputDecorationTheme`
- Tokens de espaçamento (via extensão ou constantes)

### 0.5 — `app/routes/app_router.dart` — Roteamento real

> ⚠️ **Aguarda a branch das telas.** As rotas só podem ser mapeadas após todas as screens existirem.

O arquivo atual retorna um `Scaffold` placeholder. Precisa mapear todas as telas:

```dart
static Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':          return _route(const SplashScreen());
    case '/login':     return _route(const LoginScreen());
    case '/home':      return _route(const HomeScreen());
    // ... demais rotas
    default:           return _route(const NotFoundScreen());
  }
}
```

**Critério de conclusão da Fase 0:**
- [ ] `ApiClient` configurado e testado contra o backend
- [ ] `Failures` cobrindo todos os casos de erro esperados
- [ ] `theme.dart` refletindo o design system do Pencil
- [ ] `app_router.dart` com todas as rotas das 29 telas mapeadas

---

## FASE 1 — Domain Layer (por feature)

> **Responsabilidade:** Tech Lead
>
> **Ordem de prioridade de features:**
> 1. **auth** — login, sessão, token (todo o app depende disso)
> 2. **conversations** — core do produto
> 3. **contacts** — dependente de conversations
> 4. **profile** — configurações do usuário
> 5. Demais features em paralelo

### 1.1 — Entities

Classes Dart **puras**, sem `fromJson`, sem Flutter, sem dependência externa.

```dart
// features/auth/domain/entities/user.dart
class User {
  final String id;
  final String whatsappNumber;
  final String name;

  const User({
    required this.id,
    required this.whatsappNumber,
    required this.name,
  });
}
```

### 1.2 — Repository Interfaces

Contratos abstratos. A UI e os Use Cases dependem **somente desta interface**, nunca da implementação.

```dart
// features/auth/domain/repositories/auth_repository.dart
abstract interface class AuthRepository {
  Future<Either<Failure, User>> login({
    required String whatsappNumber,
    required String password,
  });

  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getCurrentUser();
}
```

### 1.3 — Use Cases

Uma classe, uma responsabilidade. Recebe repositório via construtor.

```dart
// features/auth/domain/usecases/login_usecase.dart
class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<Either<Failure, User>> call({
    required String whatsappNumber,
    required String password,
  }) => _repository.login(
    whatsappNumber: whatsappNumber,
    password: password,
  );
}
```

**Critério de conclusão da Fase 1 (por feature):**
- [ ] Todas as entities necessárias criadas
- [ ] Repository interface cobre todas as operações da feature
- [ ] Um Use Case por operação de negócio
- [ ] Zero imports de Flutter ou de pacotes de dados nas pastas `domain/`

---

## FASE 2 — Data Layer (por feature)

> **Responsabilidade:** Tech Lead implementa `models/` e `datasources/`. Frontend implementa `repositories/`.

### 2.1 — Models

Estende a entidade com capacidade de serialização.

```dart
// features/auth/data/models/user_model.dart
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.whatsappNumber,
    required super.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    whatsappNumber: json['whatsappNumber'] as String,
    name: json['name'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'whatsappNumber': whatsappNumber,
    'name': name,
  };
}
```

### 2.2 — DataSources

Faz as chamadas reais via `ApiClient`. Lança exceções (não retorna `Either`).

```dart
// features/auth/data/datasources/auth_remote_datasource.dart
abstract interface class AuthRemoteDataSource {
  Future<UserModel> login({required String whatsappNumber, required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _client;
  const AuthRemoteDataSourceImpl(this._client);

  @override
  Future<UserModel> login({required String whatsappNumber, required String password}) async {
    final response = await _client.post('/auth/login', data: {
      'whatsappNumber': whatsappNumber,
      'password': password,
    });
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
```

### 2.3 — Repository Implementation

Implementa a interface do domain. **Aqui** é onde exceções viram `Failure`.

```dart
// features/auth/data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  const AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, User>> login({
    required String whatsappNumber,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.login(
        whatsappNumber: whatsappNumber,
        password: password,
      );
      return Right(user);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Erro de servidor'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
```

**O que o Tech Lead entrega:**
- [ ] Models com `fromJson`/`toJson` mapeando o JSON da API
- [ ] DataSource interface + implementação com todos os endpoints

**O que o Frontend implementa:**
- [ ] Repository impl: chama o datasource, captura exceções, retorna `Either`

**Critério de conclusão da Fase 2 (por feature):**
- [ ] Cada entity tem seu Model correspondente com `fromJson`/`toJson`
- [ ] DataSource cobre todos os endpoints da feature
- [ ] Repository impl captura todas as exceções e retorna `Either<Failure, T>`
- [ ] Testado manualmente contra o backend

---

## FASE 3 — Providers Riverpod (por feature)

> **Responsabilidade:** 100% Frontend.
> Só implementar após Fases 1 e 2 estarem completas para a feature.

### 3.1 — Providers de Injeção de Dependência

```dart
// features/auth/presentation/providers/auth_providers.dart

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authDataSourceProvider = Provider<AuthRemoteDataSource>((ref) =>
  AuthRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>((ref) =>
  AuthRepositoryImpl(ref.watch(authDataSourceProvider)),
);

final loginUseCaseProvider = Provider<LoginUseCase>((ref) =>
  LoginUseCase(ref.watch(authRepositoryProvider)),
);
```

### 3.2 — StateNotifier / AsyncNotifier

```dart
// features/auth/presentation/providers/auth_notifier.dart

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<User?> build() => const AsyncData(null);

  Future<void> login({required String whatsappNumber, required String password}) async {
    state = const AsyncLoading();
    final result = await ref.read(loginUseCaseProvider).call(
      whatsappNumber: whatsappNumber,
      password: password,
    );
    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (user) => AsyncData(user),
    );
  }
}
```

**Critério de conclusão da Fase 3 (por feature):**
- [ ] Toda injeção de dependência via providers (zero `new` direto nas telas)
- [ ] Estado da feature representa loading, sucesso e erro
- [ ] Nenhuma lógica de negócio dentro do Notifier (ela fica no Use Case)

---

## FASE 4 — Conectar UI aos Providers

> **Responsabilidade:** 100% Frontend.
> Revisão das screens estáticas para consumir estado real.

```dart
// ANTES (estática)
class LoginScreen extends StatelessWidget { ... }

// DEPOIS (consumindo provider)
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      loading: () => const LoadingOverlay(),
      error: (err, _) => ErrorSnackBar(message: err.toString()),
      data: (user) => _buildForm(context, ref),
    );
  }
}
```

**O que NÃO muda:** layout, componentes visuais, estilos.

**Critério de conclusão da Fase 4:**
- [ ] Todas as screens são `ConsumerWidget` ou `ConsumerStatefulWidget`
- [ ] Zero dados hardcoded nas screens (tudo vem de providers)
- [ ] Navegação entre telas funcionando via router

---

## FASE 5 — Integração End-to-End e Estabilização

### 5.1 — Revisão E2E (Tech Lead)
- [ ] Login → token armazenado (`flutter_secure_storage`)
- [ ] Token enviado automaticamente em todas as requests (via interceptor)
- [ ] Logout limpa token e redireciona para login
- [ ] App abre direto no Home se já logado (splash → verificação de sessão)
- [ ] Erros de rede exibem snackbar/dialog adequado
- [ ] Loading real em todas as operações assíncronas
- [ ] Sem telas brancas ou crashes sem feedback

### 5.2 — QA (Thiago)

> Entra após a revisão E2E, com o app integrado e funcional.

- [ ] Testes funcionais dos fluxos críticos (login, home, conversations)
- [ ] Testes de regressão após ajustes
- [ ] Validação em dispositivo físico (Android e iOS se aplicável)
- [ ] Registro de bugs no Linear com reprodução documentada
- [ ] Validação dos estados de erro e loading na UI

### 5.3 — Testes unitários (Tech Lead)
- [ ] Unit tests nos Use Cases (sem dependência de Flutter)
- [ ] Widget tests nas telas críticas

---

## Critério de "App Funcionando" (pronto para planejar o bot)

| Critério | Verificação |
|----------|------------|
| Login e sessão com API real | token salvo, requisições autenticadas |
| Fluxo principal navegável | splash → login → home → conversations |
| Dados reais nas telas principais | sem mocks em produção |
| Nenhum crash em fluxo normal | testado em device físico |
| Tema e design aplicados | telas refletem o design do Pencil |

---

## Resumo Visual

```
AGORA         →   FASE 0        →   FASE 1       →   FASE 2      →   FASE 3       →   FASE 4       →   FASE 5
Screens            Shared Infra      Domain           Data             Providers        Conectar UI      Integração
& Widgets          (HTTP, Erros,     (Entities,       (Models,         (Riverpod,       ConsumerWidget   E2E +
(~29 telas)        Tema, Router)     Repos, Cases)    DataSources,     Notifiers,       + Routing        Estabilização
                                     [Tech Lead]      Repo Impls)      Injeção)
                                                      [TL + Frontend]  [Frontend]       [Frontend]
                                                                                                         ↓
                                                                                               PRONTO PARA
                                                                                               PLANEJAMENTO DO BOT IA
```

> **Regra de ouro:** Fases 1 a 4 são executadas **feature por feature**, não em blocos horizontais. Finalize auth completamente antes de começar conversations. Isso permite testar e integrar cada feature de forma isolada.
