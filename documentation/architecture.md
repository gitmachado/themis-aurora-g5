# Architecture

## Visao atual

O repositorio ainda esta no inicio. Para o ticket `G5-5`, a arquitetura implementada cobre apenas a fundacao do app Flutter em `mobile/`, suficiente para subir o app, aplicar tema compartilhado e validar o fluxo inicial `splash -> login` sem dependencia de backend.

## Mobile

### Estrutura inicial

- `mobile/lib/main.dart`
  - entrypoint unico do app
- `mobile/lib/app/`
  - configuracao central do aplicativo
  - tema compartilhado
  - roteamento minimo
- `mobile/lib/features/splash/`
  - tela inicial de carregamento
  - transicao automatica para login
- `mobile/lib/features/auth/`
  - tela de login placeholder
  - ponto de extensao para autenticacao real em tickets futuros
- `mobile/test/`
  - smoke test do shell inicial

### Navegacao

- O app usa navegacao nativa do Flutter com `MaterialApp` e `onGenerateRoute`.
- Rotas implementadas neste estagio:
  - `/`
  - `/login`
- A escolha por navegacao nativa foi intencional para manter o bootstrap pequeno e sem dependencias extras antes de existir um fluxo mais complexo.

### Tema

- O tema fica centralizado em `mobile/lib/app/theme.dart`.
- A base visual prioriza contraste alto, coerente com o PRD.
- As telas iniciais reutilizam o mesmo tema para evitar estilos espalhados logo no setup.

### Como expandir a partir daqui

- Novas features devem entrar em `mobile/lib/features/`, agrupadas por capacidade real do produto.
- Quando surgirem fluxos de timeline, documentos, chat ou notificacoes, eles devem ser adicionados como novas features, sem criar camadas genericas antes de existir uso concreto.
- Se autenticacao real, estado compartilhado, cliente HTTP ou injecao de dependencia passarem a ser necessarios, essas decisoes devem ser introduzidas junto do primeiro caso de uso que realmente exija essa complexidade.

## Fora do recorte atual

- Integracao com backend
- autenticacao real
- home do cliente
- notificacoes push
- sincronizacao em tempo real
- suporte offline
- perfil advogado

## Validacao esperada

- `flutter pub get`
- `flutter analyze`
- `flutter test`
