---
title: FE Cliente - setup inicial Flutter e estudo de arquitetura
ticket: G5-5
status: open
last_updated_at: 2026-04-09
---

# 1. Objetivo

Estabelecer a base tecnica do app Flutter em `mobile/`, criando um bootstrap executavel do projeto e registrando a arquitetura inicial que sera usada nas proximas entregas. O resultado esperado deste ticket nao e a implementacao dos fluxos juridicos do cliente, e sim uma fundacao valida para navegacao, tema, organizacao de codigo e evolucao futura.

# 2. Escopo

## 2.1 In scope

- Inicializar o projeto Flutter dentro de `mobile/`, substituindo o estado atual com apenas arquivos `.gitkeep`.
- Criar o entrypoint do app e a estrutura minima para inicializacao, navegacao e tema.
- Subir placeholders do fluxo base de entrada do app para validar bootstrap e navegacao:
  - splash/loading inicial
  - login/acesso inicial
- Definir uma organizacao minima de codigo em `mobile/lib/` que acomode crescimento por feature sem introduzir camadas desnecessarias neste momento.
- Registrar em `documentation/architecture.md` a decisao de arquitetura inicial do app Flutter, incluindo estrutura de pastas, estrategia de navegacao e limites do setup inicial.
- Adicionar pelo menos um teste inicial de smoke/widget para garantir que o app sobe corretamente.

## 2.2 Out of scope

- Integracao real com backend, banco, Firebase, WhatsApp ou qualquer servico externo.
- Implementacao funcional de timeline, chat espelhado, documentos, notificacoes ou consulta de processos.
- Perfil advogado no app Flutter.
- Persistencia offline, cache local ou estrategia de sincronizacao em tempo real.
- Definicao de design system completo ou biblioteca extensa de componentes.
- Decisao definitiva sobre autenticacao de producao; neste ticket entram apenas placeholders e pontos de extensao.

# 3. Contexto atual

- O PRD exige que a Semana 1 entregue a base do app Flutter com navegacao, auth e temas (`documentation/requisitos.md`, linhas 23-29).
- O PRD principal descreve dois perfis no app Flutter, mas os fluxos do cliente ainda nao existem na codebase (`documentation/prd.md`, linhas 56-85).
- `mobile/` ainda nao contem um projeto Flutter; existem apenas `mobile/.gitkeep` e `mobile/assets/images/.gitkeep`.
- `documentation/architecture.md` esta vazio, entao hoje nao existe arquitetura documentada para o app.
- `server/` tambem esta no inicio, sem contratos prontos para consumo pelo app.

# 4. O que ja existe

- Diretriz funcional no PRD para o app Flutter do cliente:
  - dashboard/timeline
  - espelhamento de chat
  - documentos
  - acessibilidade e estados de loading
- Diretriz de cronograma em `documentation/requisitos.md` para que o setup inicial contemple navegacao, auth e temas.
- Estrutura de repositorio com separacao de alto nivel entre `mobile/`, `server/` e `documentation/`.
- Setup raiz de qualidade apenas para o monorepo (`package.json`, Husky e commitlint), sem configuracao especifica de Flutter.

# 5. O que deve ser implementado

1. Bootstrap do projeto Flutter em `mobile/`

- Gerar a estrutura base do projeto Flutter para plataformas moveis suportadas pelo time neste momento.
- Manter o setup focado em Android/iOS, evitando gerar plataformas que nao serao usadas agora se isso adicionar ruido desnecessario ao repositorio.
- Preservar `mobile/assets/` como raiz de assets do app.

2. Estrutura inicial do app

- Criar uma organizacao minima em `mobile/lib/` com separacao clara entre:
  - inicializacao do app
  - configuracao compartilhada do app (tema, rotas, constantes basicas)
  - features de entrada e autenticacao inicial
- A estrutura deve ser pequena e direta. Uma base aceitavel para este ticket e:
  - `mobile/lib/main.dart`
  - `mobile/lib/app/`
  - `mobile/lib/features/`
  - `mobile/lib/shared/` ou `mobile/lib/core/` para utilitarios realmente compartilhados, se necessario
- Nao introduzir camadas extras (data/domain/usecases) sem uso real neste momento.

3. Navegacao inicial

- Implementar um roteamento centralizado suficiente para validar a montagem do app.
- O fluxo inicial deve cobrir no minimo:
  - splash -> login
- Preferir a abordagem mais simples que permita evolucao sem travar o projeto. Se a implementacao usar apenas APIs nativas do Flutter para esse bootstrap, isso e suficiente.
- Se houver adocao de pacote externo para roteamento, a escolha deve ser justificada em `documentation/architecture.md`.

4. Tema e base visual

- Criar um tema central do app com configuracao inicial de cores, tipografia e estados basicos.
- O tema deve considerar o requisito de contraste alto do PRD, mesmo que ainda sem design system completo.
- Os placeholders devem usar esse tema compartilhado, evitando estilos inline espalhados.

5. Placeholders iniciais do app

- Criar telas simples, navegaveis e sem dependencia de backend para representar:
  - carregamento inicial
  - autenticacao inicial
- A tela de login deve deixar claro que autenticacao real e integracao com backend ainda nao fazem parte deste ticket.

6. Estudo e registro da arquitetura

- Preencher `documentation/architecture.md` com a arquitetura inicial adotada para o app Flutter.
- O documento deve registrar, no minimo:
  - objetivo do app neste estagio
  - estrutura de pastas escolhida
  - estrategia de navegacao escolhida
  - como novas features do cliente devem ser adicionadas
  - quais decisoes foram explicitamente adiadas para tickets futuros
- O documento nao precisa descrever backend ou IA em profundidade; o foco aqui e o frontend Flutter.

7. Validacao automatizada minima

- Adicionar teste inicial para garantir que o app sobe e renderiza o shell principal.
- Garantir que o projeto consiga executar pelo menos:
  - `flutter pub get`
  - `flutter analyze`
  - `flutter test`

# 6. Arquivos impactados

## Mobile

- `mobile/pubspec.yaml` (novo arquivo)
- `mobile/analysis_options.yaml` (novo arquivo)
- `mobile/.metadata` (novo arquivo gerado pelo Flutter CLI)
- `mobile/android/` (novo diretorio gerado pelo Flutter CLI, se Android estiver no escopo)
- `mobile/ios/` (novo diretorio gerado pelo Flutter CLI, se iOS estiver no escopo)
- `mobile/lib/main.dart` (novo arquivo)
- `mobile/lib/app/` (novo diretorio)
- `mobile/lib/app/app.dart` (novo arquivo)
- `mobile/lib/app/router.dart` ou equivalente (novo arquivo)
- `mobile/lib/app/theme.dart` ou equivalente (novo arquivo)
- `mobile/lib/features/auth/` (novo diretorio)
- `mobile/lib/features/auth/presentation/login_page.dart` ou equivalente (novo arquivo)
- `mobile/lib/features/splash/` ou equivalente (novo diretorio)
- `mobile/test/` (novo diretorio)
- `mobile/test/app_smoke_test.dart` ou equivalente (novo arquivo)
- `mobile/assets/images/` (diretorio existente; manter)

## Documentacao

- `documentation/architecture.md` (arquivo existente a ser preenchido)
- `documentation/specs/g5-5-fe-cliente-setup-inicial-flutter-e-estudo-de-arquitetura.md` (novo arquivo)

## Backend

- Nenhum arquivo de `server/` deve ser alterado neste ticket.

# 7. Fluxo tecnico

1. Desenvolvedor inicializa o projeto Flutter dentro de `mobile/`.
2. O app passa a ter um entrypoint unico em `main.dart`.
3. `main.dart` sobe a configuracao central do app (tema + rotas + shell inicial).
4. O app abre em uma tela de splash/loading simples.
5. A splash encaminha para a tela de login placeholder.
6. A tela de login expoe o ponto de entrada visual do app, sem autenticacao real.
7. O teste inicial valida que o shell do app renderiza sem quebrar.
8. Em paralelo, `documentation/architecture.md` registra a estrutura criada e os limites dessa fundacao para orientar os proximos tickets.

# 8. Validacao

- O repositorio passa a conter um projeto Flutter funcional em `mobile/`.
- O app sobe localmente sem depender de backend.
- Existe navegacao basica entre splash e login.
- Tema centralizado aplicado nas telas placeholder.
- `documentation/architecture.md` deixa explicito como organizar novas features do cliente a partir desta base.
- Comandos esperados:
  - `flutter pub get`
  - `flutter analyze`
  - `flutter test`

# 9. Riscos / Pendencias

- O ticket do Linear fornecido so explicita `setup inicial Flutter` e `estudo de arquitetura`; nao ha descricao adicional do fluxo esperado no repositorio. Esta spec assume que o objetivo e criar a fundacao do app do cliente, nao implementar features finais de negocio.
- Ainda nao existe contrato de autenticacao nem API do backend. Por isso, login entra apenas como placeholder navegavel.
- `documentation/architecture.md` esta vazio hoje; se o time quiser definir uma arquitetura mais robusta (ex.: estado global, client HTTP, injecao de dependencia), isso deve ser registrado como extensao futura e nao inflar este ticket.
- O PRD fala em dois perfis no app Flutter. Esta spec assume foco no perfil cliente, conforme o titulo do ticket. Se o time decidir unificar desde ja cliente e advogado na mesma navegacao base, a spec deve ser refinada antes da implementacao.
