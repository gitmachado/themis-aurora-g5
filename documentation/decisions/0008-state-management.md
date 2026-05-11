# Decisão 0008: Gerenciamento de Estado com Riverpod

### 1. Título
Decisão 0008: Adoção do Riverpod 2.x como Framework Único de Gerenciamento de Estado e Convenções de Uso por Sub-Feature

### 2. Status
- **Activated**

### 3. Contexto
O app mobile do Themis carrega dados assíncronos vindos do backend (leads, processos, mensagens, notificações), expõe estado real-time via WebSocket, mantém sessão autenticada cross-screens e precisa que múltiplas telas consumam o **mesmo dado** sem refazer chamadas de rede. Em paralelo, a [ADR 0005](0005-arquitetura-frontend-flutter.md) instituiu **Vertical Slicing**: cada sub-feature carrega seus próprios providers em `presentation/providers/`.

A combinação dessas necessidades exige um framework de estado que:

1. Trate naturalmente **operações assíncronas com loading/erro/data** (não força boilerplate de three-state).
2. Permita **parametrizar provedores** (ex: `leadDetailProvider(leadId)`) sem indireções.
3. Suporte **invalidação e refresh declarativos** quando uma mutação acontece.
4. **Não dependa de `BuildContext`**, permitindo composição de providers entre si e uso fora da árvore de widgets.
5. Seja **testável por DI**, com `ProviderContainer` substituindo dependências reais por fakes.
6. Tenha ergonomia compatível com **Clean Architecture** (DataSource → Repository → UseCase → Notifier).

Sem uma decisão consolidada, sub-features começariam a usar abordagens diferentes (`setState`, `ChangeNotifier`, BLoC, Provider 6.x), fragmentando convenções e dobrando custo de manutenção.

### 4. Decisão
Adotamos **Riverpod 2.x (`flutter_riverpod`)** como **único** framework de gerenciamento de estado da camada `presentation/`. Convenções abaixo são obrigatórias.

#### 4.1 Localização e nomenclatura
- Providers vivem em `lib/features/<role>/<sub>/presentation/providers/<sub>_providers.dart`.
- Um único arquivo `*_providers.dart` por sub-feature concentra a árvore de DI da feature (DataSource → Repository → UseCases → Notifier/Provider de UI).
- Nome do provider termina em `Provider`: `leadRepositoryProvider`, `pendingLeadsProvider`, `chatRoomProvider`.

#### 4.2 Tipos de provider e quando usar cada um

| Tipo | Caso de uso |
|---|---|
| `Provider<T>` | Dependência imutável (ApiClient, Repository, UseCase). Não muda em runtime. |
| `FutureProvider<T>` | Leitura assíncrona one-shot, sem mutação posterior. |
| `StreamProvider<T>` | Fluxo contínuo (WebSocket de mensagens, FCM, atualizações live). |
| `AsyncNotifierProvider<N, T>` | Estado assíncrono **mutável** com I/O — padrão para listas que sofrem CRUD. |
| `NotifierProvider<N, T>` | Estado síncrono mutável (filtros locais, abas selecionadas). |
| `StateProvider<T>` | **Banido fora de protótipo.** Sempre prefira `Notifier` por explicidade. |

#### 4.3 Camada de DI dentro do arquivo de providers
Toda sub-feature segue o mesmo encadeamento:

```dart
// 1. DataSource (HTTP/local)
final leadRemoteDataSourceProvider = Provider<LeadRemoteDataSource>(
  (ref) => LeadRemoteDataSource(ref.watch(apiClientProvider)),
);

// 2. Repository (implementa contrato de domain/)
final leadRepositoryProvider = Provider<LeadRepository>(
  (ref) => LeadRepositoryImpl(ref.watch(leadRemoteDataSourceProvider)),
);

// 3. UseCases (um por verbo)
final getPendingLeadsUseCaseProvider = Provider<GetPendingLeadsUseCase>(
  (ref) => GetPendingLeadsUseCase(ref.watch(leadRepositoryProvider)),
);

// 4. Notifier de UI (consome UseCases)
final pendingLeadsProvider =
    AsyncNotifierProvider<PendingLeadsNotifier, List<Lead>>(
  PendingLeadsNotifier.new,
);
```

Esse encadeamento mantém a inversão de dependência da Clean Architecture testável por override em qualquer nível.

#### 4.4 Convenções de uso

- **`autoDispose` por padrão** para providers de tela (`AsyncNotifierProvider.autoDispose<...>`). Mantenha sem `autoDispose` apenas estado de sessão (auth, perfil ativo).
- **`.family`** para parametrizar (`leadDetailProvider(leadId)`). Evita inflar o construtor do Notifier com parâmetros opcionais.
- **`AsyncValue.when`** na UI — nunca `if (provider.isLoading)`:
  ```dart
  ref.watch(pendingLeadsProvider).when(
    data: (leads) => LeadList(leads: leads),
    loading: () => const LoadingSkeleton(),
    error: (e, _) => ErrorView(message: e.toString()),
  );
  ```
- **`ref.invalidate(provider)`** após mutação — não recarregue manualmente. Riverpod refaz a chamada na próxima leitura.
- **`ref.listen`** para side effects (snackbars, navegação após login). Nunca dentro de `build`.
- **fpdart `Either<Failure, T>`** retornado pelos UseCases. O Notifier converte para `AsyncValue` na presentation.

#### 4.5 Comunicação entre sub-features
Permitida apenas via providers expostos em `shared/` ou via providers da **camada de auth / perfil ativo**. Uma sub-feature **não importa providers de outra sub-feature horizontalmente** — orquestração entre features acontece numa camada superior (ex: tela de detalhe que combina `leadDetailProvider` + `messagesProvider` declara a composição localmente).

#### 4.6 Testes
- `ProviderContainer` substitui `ProviderScope` em testes de unidade.
- Overrides de DataSource/Repository com fakes implementando o contrato.
- `Notifier`s testados isoladamente com `container.read(provider.notifier).method()` e asserts em `container.read(provider)`.

### 5. Consequências

- **Positivas:**
  - Boilerplate mínimo para casos assíncronos comparado a BLoC.
  - DI declarativa elimina injetores manuais e singletons globais.
  - `ref.invalidate` + `family` resolvem cache invalidation com elegância.
  - Compatível com hot-reload e DevTools nativos do Flutter.
  - Override granular em testes — não é preciso instanciar a árvore de widgets para validar lógica.

- **Negativas:**
  - Curva de aprendizado para devs vindos de Provider/BLoC: tipos genéricos podem assustar (`AsyncNotifierProvider<N, T>` vs `FutureProvider<T>`).
  - Riverpod 3.x já está disponível com geração de código (`riverpod_generator`); migrar exige rewrite — adiado para pós-MVP.
  - Erros de tipo em providers só aparecem em compile-time, não no editor — exige `flutter analyze` no CI.

- **Impacto na Equipe:**
  - PRs novos devem seguir o encadeamento DataSource → Repository → UseCase → Notifier ou justificar desvio na descrição.
  - Code review checa: `autoDispose` correto, `AsyncValue.when` na UI, mutações disparam `invalidate`.

### 6. Alternativas Consideradas

| Alternativa | Por que foi rejeitada |
|---|---|
| **BLoC / flutter_bloc** | Boilerplate alto para casos triviais (Event + State + Bloc por feature). Bom para máquinas de estado complexas, exagerado para CRUD. |
| **Provider 6.x** | Sem suporte nativo a estado assíncrono e exige `BuildContext`. Riverpod é evolução direta do mesmo autor. |
| **GetX** | Acopla navegação, DI, estado e i18n no mesmo pacote — inverso da nossa arquitetura desacoplada. |
| **MobX** | Macros de geração de código pesados, comunidade Flutter menor. |
| **Riverpod 3.x com codegen** | Excelente para projeto novo, mas exige migração e dependência adicional do `build_runner`. Reavaliar em ciclo II. |

---
> [!NOTE]
> Em caso de dúvida sobre qual variante de provider usar, consulte a tabela em **4.2** ou pergunte no canal `#mobile`. Quando duas opções servirem, prefira sempre **`AsyncNotifierProvider`** sobre `FutureProvider` em qualquer caso que possa eventualmente ganhar uma mutação.
