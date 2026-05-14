# Themis Mobile

Aplicativo Flutter do Themis. Single-app com perfis distintos (advogado e cliente) que conversa com o backend Node em tempo real e recebe notificações via FCM.

## Stack

| Camada | Tecnologia |
|---|---|
| Linguagem | Dart `^3.11` |
| Framework | Flutter `3.41` (channel `stable`) |
| Estado | [Riverpod](https://riverpod.dev) `^2.6` (`flutter_riverpod`) — ver [ADR 0008](../documentation/decisions/0008-state-management.md) |
| HTTP | `dio` `^5.9` (centralizado em `shared/network/api_client.dart`) |
| Real-time | `socket_io_client` `^3.1` |
| Persistência segura | `flutter_secure_storage` `^10.0` |
| Push | Firebase Core + Messaging + `flutter_local_notifications` |
| Functional helpers | `fpdart` (Either/Option em camadas de erro) |
| Mídia | `file_picker`, `image_picker`, `image_cropper`, `flutter_pdfview` |

## Arquitetura

A organização de pastas segue **Full Vertical Slicing por sub-feature** ([ADR 0005](../documentation/decisions/0005-arquitetura-frontend-flutter.md)) sobre **Clean Architecture**. A camada de runtime (bootstrap, theming, navegação, shared) está documentada na [ADR 0007](../documentation/decisions/0007-mobile-architecture.md).

```
lib/
├── main.dart            # bootstrap (Firebase, FCM background, SystemChrome, ProviderScope)
├── app/                 # shell da aplicação
│   ├── app.dart         # MaterialApp, theme, navigatorKey, rotas
│   ├── config/          # configuração de ambiente
│   ├── navigation_service.dart
│   ├── routes/          # AppRouter centralizado (onGenerateRoute)
│   └── theme/           # AppTheme, cores, tipografia
├── features/            # vertical slices por perfil/sub-feature
│   ├── auth/
│   ├── client/<sub>/    # ex: chat, files, notifications, procedures, profile
│   ├── lawyer/<sub>/    # ex: ai_manager, chat, clients, files, leads, procedures, team
│   ├── design_system/   # showcase do DS interno
│   ├── legal/           # termos / privacidade
│   ├── notifications/   # camada cross-perfil
│   ├── procedures/
│   └── splash/
└── shared/              # infraestrutura transversal
    ├── constants/
    ├── errors/          # tipos de Failure + extensões fpdart
    ├── network/         # ApiClient, ApiConfig, ApiException, TokenStorage, WebSocketClient
    ├── services/        # PushNotificationService, etc
    ├── utils/
    └── widgets/         # AppBars, NavBars, Buttons, Skeletons reutilizáveis
```

Cada sub-feature mantém seu próprio `data/`, `domain/` e `presentation/` (com `providers/`, `screens/`, `widgets/`). Apagar uma pasta de sub-feature remove 100% de seu domínio sem deixar dependências órfãs.

## Pré-requisitos

- Flutter SDK `3.41+` (`flutter --version`)
- Dart SDK `3.11+`
- Android Studio com Android SDK 33+ (para builds Android)
- Xcode 15+ (para iOS, apenas em macOS)
- Backend Themis rodando (ver raiz do monorepo). Por padrão o app aponta pra `http://10.0.2.2:3000` (emulador Android) — ajustar em `shared/network/api_config.dart` para outros ambientes.

## Setup inicial

```bash
flutter pub get
```

Configurações nativas necessárias (já versionadas no repo):

- **Android:** `android/app/google-services.json` precisa estar presente. Permissões de câmera, mídia e notificações já declaradas no `AndroidManifest.xml`.
- **iOS:** `ios/Runner/GoogleService-Info.plist` precisa estar presente. Descrições `NSCameraUsageDescription` e `NSPhotoLibraryUsageDescription` já declaradas no `Info.plist`.

## Rodando

```bash
# Lista devices conectados
flutter devices

# Roda em modo debug no device padrão
flutter run

# Especifica um device
flutter run -d emulator-5554
flutter run -d chrome
```

O app sobe na rota `splash` (em `app/routes/app_router.dart`) e decide entre `login` e o layout principal (cliente ou advogado) com base no estado de autenticação.

## Testes

```bash
flutter test                                   # todos os testes
flutter test test/app_smoke_test.dart          # smoke
flutter test test/e2e/app_flows_e2e_test.dart  # fluxos E2E
flutter test --coverage                        # gera coverage/lcov.info
```

Testes vivem em `test/` espelhando a estrutura de `lib/`.

## Análise estática

```bash
flutter analyze
dart format --output=none --set-exit-if-changed lib test
```

Configuração em `analysis_options.yaml` (`flutter_lints` + regras adicionais). O CI bloqueia PRs com warnings ou formatação inconsistente.

## Builds

```bash
flutter build apk --release                # Android APK
flutter build appbundle --release          # Android AAB (Play Store)
flutter build ios --release --no-codesign  # iOS (requer Xcode/macOS)
flutter build web --release
```

## Push notifications

Backend de FCM é registrado no `main.dart` *antes* de `runApp` (restrição de isolate do Firebase Messaging). O serviço de domínio fica em `shared/services/push_notification_service.dart` e expõe handlers de foreground, background e `onMessageOpenedApp`.

## Troubleshooting

| Sintoma | Causa provável | Como corrigir |
|---|---|---|
| `flutter pub get` falha em `firebase_core` | Plugins Firebase desatualizados na máquina | Rodar `flutter clean` + `flutter pub get` |
| App não conecta na API no emulador Android | `localhost` aponta pro próprio emulador | Usar `10.0.2.2` em `shared/network/api_config.dart` |
| App não conecta no device físico | Backend escutando só em `localhost` | Subir backend em `0.0.0.0` e usar IP da rede local |
| Build iOS falha em `pod install` | CocoaPods desatualizado | `cd ios && pod repo update && pod install` |
| Push não chega em iOS | Falta de `GoogleService-Info.plist` ou APNs key | Verificar arquivo + capabilities do projeto Xcode |
| `MissingPluginException` após adicionar dep | Hot reload não recarrega plugin nativo | Parar app + `flutter run` de novo |

## Convenções de commit

O monorepo usa [Conventional Commits](https://www.conventionalcommits.org) com Husky + commitlint. Para mudanças no app mobile prefira escopos como:

```
feat(mobile/leads): adiciona filtro por status na lista
fix(mobile/chat): corrige scroll automático ao receber mensagem
refactor(mobile/files): extrai widget de upload em componente próprio
test(mobile/auth): cobre LoginNotifier com casos de erro
docs(mobile): atualiza guia de troubleshooting
```

## Documentos relacionados

- [ADR 0005 — Arquitetura Frontend Flutter (Vertical Slicing)](../documentation/decisions/0005-arquitetura-frontend-flutter.md)
- [ADR 0007 — Mobile Architecture (Runtime)](../documentation/decisions/0007-mobile-architecture.md)
- [ADR 0008 — Gerenciamento de Estado com Riverpod](../documentation/decisions/0008-state-management.md)
- [Documentação geral do projeto](../documentation/)
