---
title: Infra: estudo de hospedagem e arquitetura de rede para deploy publico do MVP
ticket: G5-7
status: open
last_updated_at: 2026-04-19
---

> Atualizacao 2026-04-28: a decisao de storage local descrita nesta spec foi superada pela ADR 0008. O deploy publico agora deve usar Supabase Storage privado para binarios de documentos, mantendo metadados e ownership no backend/PostgreSQL.

# 1. Objetivo

Definir a estrategia de hospedagem e a arquitetura de rede minima para publicar o backend do OmniConnect em ambiente acessivel pela internet, sem contradizer a stack atual do monorepo e sem assumir componentes que ainda nao existem no repositorio. A entrega deste ticket e uma decisao tecnica documentada para o primeiro deploy publico do MVP, com topologia recomendada, limites claros e follow-ups obrigatorios.

# 2. Escopo

## 2.1 In scope

- Estudar a hospedagem do backend `server/` com base no que ja existe hoje no repositorio: Docker, PostgreSQL, storage local e consumo por app Flutter e integracao externa.
- Definir uma topologia de rede minima para o MVP com HTTPS publico, backend em container e banco fora da internet publica.
- Registrar uma recomendacao objetiva de deploy para o primeiro ambiente publico.
- Mapear variaveis de ambiente, segredos e pontos de endurecimento minimos para expor a API externamente.
- Identificar os gaps atuais da codebase que viram follow-ups obrigatorios antes do deploy real.
- Atualizar a documentacao tecnica com a topologia aprovada e as restricoes operacionais do MVP.

## 2.2 Out of scope

- Provisionar cloud, contratar fornecedor, criar DNS, emitir certificados ou executar deploy real.
- Publicar `mobile/` em Play Store, App Store ou Web.
- Implementar o bot de WhatsApp, LangChain/RAG, Firebase/FCM ou observabilidade completa.
- Migrar storage local para S3 neste ticket.
- Criar pipeline CI/CD completo, Terraform ou outra IaC detalhada.
- Resolver todos os gaps de producao do backend neste mesmo ticket; eles devem sair mapeados e priorizados.

# 3. Contexto atual

O monorepo ja possui um backend Node.js + TypeScript em `server/`, um app Flutter inicial em `mobile/` e documentacao central em `documentation/`. O PRD exige uma plataforma com atendimento via WhatsApp, consulta de status, upload de documentos e sincronizacao com app Flutter, mas o estado atual do repositorio ainda esta concentrado em ambiente local e base tecnica.

No estado atual:

- O backend sobe em container por `server/Dockerfile` e escuta em `0.0.0.0:3000` via `server/src/server.ts`.
- O ambiente local usa `docker-compose.yml`, com `server` e `postgres` na mesma stack.
- O acesso ao banco depende de `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD` e `DB_NAME` em `server/src/config/database.ts`.
- A API publica exposta hoje inclui `/`, `/api-docs` e rotas versionadas em `/api/v1/*`.
- As integracoes backend-to-backend previstas no PRD ja aparecem nas rotas protegidas por API key em `server/src/routes/v1/lead.routes.ts` e `server/src/routes/v1/message.routes.ts`.
- O upload de documentos depende de filesystem local em `server/uploads` por meio de `server/src/utils/storage/implementations/local-storage.provider.ts` e leitura direta em `server/src/controllers/implementations/document.controller.ts`.
- Existe um guia de migracao para S3 em `documentation/specs/storage_aws_transition.md`, mas essa migracao ainda nao foi implementada.
- Antes deste ticket, o Compose acoplava bootstrap de banco e runtime do backend. A implementacao passa a usar os scripts de init do proprio container PostgreSQL em `docker-compose.yml`, preservando bootstrap apenas em volume novo.
- A implementacao tambem passa a endurecer runtime publico com `BOT_API_KEY` obrigatoria em producao, `JWT_SECRET` sem fallback inseguro em producao, CORS configurado por ambiente e Swagger desabilitado quando `NODE_ENV=production`.
- `mobile/` ainda esta em base inicial, sem configuracao de FCM, release mobile ou consumo real da API em producao.

Esse contexto indica que o primeiro deploy publico precisa privilegiar simplicidade operacional e aderencia ao que o repositorio ja suporta, evitando depender imediatamente de componentes ainda nao implementados, como storage remoto ou esteira completa de CI/CD.

# 4. O que ja existe

- `server/Dockerfile` para empacotar o backend em container.
- `docker-compose.yml` com servicos locais de `server` e `postgres`.
- `server/.env.example` com variaveis basicas de banco, porta, JWT e API key do bot.
- `server/src/routes/v1/` com contratos HTTP ja definidos para auth, leads, processos, documentos, mensagens, notificacoes e timeline.
- `server/src/utils/storage/storage.provider.ts` e `implementations/local-storage.provider.ts`, que preservam uma abstracao de storage mesmo com implementacao local.
- `README.md` e `documentation/specs/g5-20-docker-compose-ambiente-local.md` com fluxo local oficial via Docker Compose.
- `documentation/architecture.md` e `documentation/decisions/0001-stack-tecnologica-backend.md`, que consolidam PostgreSQL, TypeScript e Docker como base do projeto.

# 5. O que deve ser implementado

## 5.1 Recomendacao tecnica do estudo

- O estudo converge para uma topologia de MVP com uma unica VM/VPS Linux publica executando containers Docker.
- O acesso externo deve ocorrer apenas por HTTPS em um proxy reverso na borda da VM.
- O container `server` deve permanecer acessivel apenas na rede interna da maquina/stack.
- O PostgreSQL do MVP deve ficar na mesma VM do backend e fora da internet publica, acessivel apenas pela rede interna.
- O storage de documentos deve permanecer em volume persistente local da VM apenas para o primeiro deploy do MVP, porque a codebase ainda nao implementa provider remoto.
- O app Flutter e a futura integracao WhatsApp passam a consumir um dominio HTTPS unico do backend, sem acesso direto ao banco nem ao filesystem.

## 5.2 Entregas documentais obrigatorias

- Refinar esta spec com a topologia aprovada, premissas e limites do deploy publico.
- Atualizar `documentation/architecture.md` com um diagrama simples de rede do MVP apos a decisao ser confirmada.
- Registrar a decisao arquitetural correspondente em `.agents/decisions/0006-hospedagem-mvp-publico.md` como novo arquivo, mantendo `documentation/architecture.md` apenas como reflexo dessa decisao.
- Produzir um runbook operacional em `documentation/deploy-mvp.md` como novo arquivo, cobrindo bootstrap, restart, backup basico, rollback e smoke test.

## 5.3 Implementacao tecnica minima do ticket

- Separar bootstrap de banco de runtime do backend, para que restart do servico nao execute seed novamente.
- Adicionar um endpoint publico de healthcheck de liveness simples em `/health`.
- Endurecer configuracao de seguranca para deploy publico, removendo fallbacks inseguros de segredo e exigindo `BOT_API_KEY` em ambiente nao local.
- Desabilitar Swagger quando `NODE_ENV=production`.
- Parametrizar CORS por ambiente, em vez de manter liberacao ampla no `server/src/app.ts`.
- Documentar o deploy aprovado do MVP sem introduzir um compose separado de producao neste ticket.
- Manter como follow-up futuro a migracao de storage para provedor remoto antes de qualquer evolucao para hospedagem stateless ou horizontal.

# 6. Arquivos impactados

- `documentation/specs/g5-7-deploy-caso-de-estudo.md` - refinar a spec deste ticket.
- `documentation/architecture.md` - adicionar topologia de deploy/rede do MVP apos decisao validada.
- `.agents/decisions/0006-hospedagem-mvp-publico.md` - novo arquivo.
- `documentation/deploy-mvp.md` - novo arquivo.
- `docker-compose.yml` - ajustar bootstrap do banco para init do PostgreSQL e remover seed do startup normal do backend.
- `server/.env.example` - incluir variaveis de ambiente de deploy publico e CORS.
- `server/src/config/runtime.ts` - novo arquivo para regras de runtime por ambiente.
- `server/src/app.ts` - adicionar `/health`, CORS por ambiente e politica de exposicao do Swagger.
- `server/src/middlewares/implementations/apiKeyMiddleware.ts` - tornar obrigatoria a API key fora de ambiente local.
- `server/src/middlewares/implementations/authMiddleware.ts` - remover fallback inseguro de JWT em producao.
- `server/src/services/implementations/auth.service.ts` - remover fallback inseguro de JWT em producao.

# 7. Fluxo tecnico

1. Cliente mobile ou integracao externa acessa `https://<dominio-do-mvp>`.
2. O proxy reverso na borda da VM recebe trafego em `443`, encerra TLS e encaminha apenas o trafego HTTP necessario para o container `server` na rede interna.
3. O backend responde rotas do app em `/api/v1/*`, mantendo autenticacao JWT para usuarios e `x-api-key` para integracoes sistema-a-sistema.
4. O PostgreSQL nao fica exposto publicamente; apenas o container `server` se conecta a ele pela rede interna.
5. Uploads continuam gravados em volume persistente da VM para suportar o fluxo atual de `documents` sem exigir migracao imediata para storage remoto.
6. O bootstrap de banco roda apenas na inicializacao de um volume novo do PostgreSQL; reinicios normais do backend nao devem reexecutar seed nem recriar schema automaticamente.
7. Swagger permanece desabilitado em producao e banco/arquivos internos nao devem ser tratados como superficie publica padrao do ambiente.

# 8. Validacao

- A spec precisa deixar explicito que a topologia aprovada para o MVP e VM unica com Docker, proxy HTTPS, backend interno e banco nao publico.
- O estudo precisa justificar por que essa opcao e a menor distancia entre o estado atual do repo e um deploy publico funcional.
- A implementacao precisa garantir `GET /health` com liveness simples e `GET /api-docs` desabilitado em `NODE_ENV=production`.
- O estudo precisa listar claramente os bloqueios remanescentes para um deploy real: storage local, backup, monitoracao e restore.
- `documentation/architecture.md` precisa refletir a topologia escolhida sem contradizer o PRD nem a stack atual.
- O runbook derivado precisa permitir que outra pessoa do time entenda como subir, reiniciar, validar e recuperar o ambiente MVP.

# 9. Riscos / Pendencias

- O uso de volume local para documentos e suficiente para um MVP em VM unica, mas nao serve como estrategia final para hospedagem stateless ou escalavel.
- O deploy do MVP continua dependendo de disciplina operacional para backup do banco e da pasta de uploads.
- O repositorio ainda nao possui backup formal, logs estruturados, monitoracao ou politica de restore.
- O fornecedor especifico da VM/VPS, o dominio final e a estrategia de certificado ainda dependem de decisao humana fora desta spec.
- Se o time decidir migrar o MVP para PaaS/stateless no lugar de VM unica, a implementacao de storage remoto deixa de ser opcional e passa a ser dependencia obrigatoria.
