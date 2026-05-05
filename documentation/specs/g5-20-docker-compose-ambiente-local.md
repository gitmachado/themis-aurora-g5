---
title: Infra: containerizacao do ambiente local com Docker Compose
ticket: G5-20
status: open
last_updated_at: 2026-04-13
---

# 1. Objetivo

Padronizar o ambiente local de desenvolvimento do Themis com Docker Compose, removendo a dependencia de instalacao manual de PostgreSQL e permitindo subir o backend Node.js com a mesma configuracao basica para todo o time.

# 2. Escopo

## 2.1 In scope

- Subir `server/` e PostgreSQL via `docker compose` a partir da raiz do repositorio.
- Reutilizar `server/database/schema.sql` e `server/database/seed.sql` no bootstrap do banco local.
- Garantir que o backend use o servico `postgres` da rede interna do Compose, sem exigir ajuste manual em `server/src/config/database.ts`.
- Persistir dados do banco entre reinicios do ambiente local.
- Preservar o comportamento atual de storage local de arquivos do backend durante o uso em containers.
- Documentar os comandos minimos de inicializacao, reset e troubleshooting do ambiente local.

## 2.2 Out of scope

- Containerizar `mobile/` ou o fluxo de `flutter run`.
- Adicionar servicos que ainda nao existem no monorepo, como bot de WhatsApp, LangChain, RAG, FCM emulator ou reverse proxy.
- Definir imagem de producao, pipeline CI/CD, deploy cloud ou secrets de producao.
- Substituir o bootstrap atual por um sistema formal de migracoes.

# 3. Contexto atual

O repositorio ja assume PostgreSQL como banco principal em `documentation/architecture.md`, no PRD e na ADR `documentation/decisions/0001-stack-tecnologica-backend.md`, mas hoje nao existem `docker-compose.yml`, `Dockerfile` ou qualquer orquestracao versionada no monorepo.

No estado atual:

- O backend le variaveis `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD` e `DB_NAME` em `server/src/config/database.ts`.
- O servidor HTTP sobe em `PORT=3000` via `server/src/server.ts` e expoe Swagger em `/api-docs` via `server/src/app.ts`.
- O bootstrap do banco depende de execucao manual de `npm run db:setup`, definido em `server/package.json` e implementado em `server/src/scripts/setup-db.ts`.
- O schema e a carga inicial estao em `server/database/schema.sql` e `server/database/seed.sql`.
- O upload de documentos usa filesystem local em `server/uploads` por meio de `server/src/utils/storage/implementations/local-storage.provider.ts`.
- O upload temporario do Multer aponta para `server/temp` em `server/src/routes/v1/document.routes.ts`.

Ha um detalhe importante para a estrategia de containerizacao: `server/database/seed.sql` nao e totalmente idempotente, porque insere registros em `timeline_events` e `notifications` sem `ON CONFLICT`. Portanto, a stack local nao deve executar `npm run db:setup` a cada reinicio do container do backend.

# 4. O que ja existe

- `server/package.json`: scripts `dev`, `build` e `db:setup`.
- `server/.env.example`: valores padrao locais para conexao com banco e segredos basicos.
- `server/database/schema.sql`: cria extensao `uuid-ossp`, tabelas e triggers.
- `server/database/seed.sql`: popula configuracao inicial, usuarios, leads e processo de exemplo.
- `server/uploads/.gitkeep`: evidencia de que o backend ja trabalha com storage local persistido em disco.
- `mobile/README.md`: confirma que o app Flutter ainda roda fora de container, com comandos locais.

# 5. O que deve ser implementado

## 5.1 Backend

- Criar um `server/Dockerfile` voltado ao ambiente local de desenvolvimento.
- A imagem deve instalar dependencias a partir de `server/package-lock.json`, expor a porta `3000` e iniciar o backend com `npm run dev`.
- O servico `server` no Compose deve publicar `3000:3000` para manter compatibilidade com o Swagger atual e com os links documentados no README.
- O container do backend deve receber `DB_HOST=postgres` e manter os mesmos nomes de variaveis de ambiente ja usados pelo codigo.
- O codigo do backend nao deve ganhar branchs especificos para Docker; a configuracao deve acontecer no Compose e na imagem.

## 5.2 Banco de dados

- Criar um servico `postgres` em `docker-compose.yml` usando imagem oficial do PostgreSQL.
- O servico deve persistir dados em volume nomeado.
- O bootstrap inicial do banco deve reutilizar `server/database/schema.sql` e `server/database/seed.sql` via mecanismo de init do proprio container PostgreSQL, executado apenas quando o volume estiver vazio.
- O servico deve expor `5432:5432` para permitir acesso local por ferramentas de banco e manter compatibilidade com a configuracao atual de desenvolvimento.
- O Compose deve incluir `healthcheck` em `postgres` e usar essa saude como pre-condicao para subir o backend.

## 5.3 Volumes e filesystem local

- O backend deve manter volume dedicado para `node_modules`, evitando conflito entre dependencias do container e bind mount do codigo-fonte.
- O backend deve manter volume dedicado para `/app/uploads`, preservando o comportamento atual do `LocalFileStorageProvider` entre reinicios do container.
- O backend deve manter volume dedicado para `/app/temp`, garantindo que o destino configurado pelo Multer exista dentro do container sem depender de criacao manual na maquina do desenvolvedor.

## 5.4 Documentacao

- Atualizar `README.md` com o fluxo oficial de ambiente local: `docker compose up --build`, endpoints publicados, reset com `docker compose down -v` e observacao de que `mobile/` continua fora do Compose.
- Explicitar no README que o Compose cobre apenas os servicos realmente versionados no monorepo neste momento: backend e PostgreSQL.

## 5.5 Scripts de conveniencia na raiz

- Adicionar scripts `docker:*` no `package.json` da raiz para padronizar a operacao do ambiente local sem exigir que o time memorize comandos longos do Compose.
- Expor pelo menos os comandos de `up`, `build`, `down`, `reset`, `ps` e logs por servico, mantendo o Docker como fluxo recomendado, mas nao exclusivo.

# 6. Arquivos impactados

- `docker-compose.yml` - novo arquivo.
- `server/Dockerfile` - novo arquivo.
- `server/.dockerignore` - novo arquivo.
- `package.json` - scripts `docker:*` na raiz.
- `README.md` - ajustar instrucoes de ambiente local.
- `documentation/specs/g5-20-docker-compose-ambiente-local.md` - novo arquivo.

# 7. Fluxo tecnico

1. O desenvolvedor executa `docker compose up --build` na raiz do repositorio.
2. O Compose cria a rede local e sobe o servico `postgres` com volume persistente.
3. Se o volume do banco estiver vazio, o container PostgreSQL executa `server/database/schema.sql` e depois `server/database/seed.sql` via diretoria de init do proprio Postgres.
4. O `healthcheck` de `postgres` marca o banco como pronto quando a conexao aceitar comandos.
5. O servico `server` sobe com `DB_HOST=postgres`, `DB_PORT=5432` e demais variaveis alinhadas ao contrato atual de `server/src/config/database.ts`.
6. O backend inicia com `npm run dev` e fica acessivel externamente em `http://localhost:3000`.
7. Arquivos temporarios de upload ficam em volume proprio de `/app/temp` e arquivos persistidos ficam em volume proprio de `/app/uploads`.
8. Em reinicios normais com `docker compose down` seguido de `docker compose up`, o banco e os arquivos persistem.
9. Em reset completo com `docker compose down -v`, o volume do banco e recriado e o bootstrap SQL roda novamente desde o inicio.

# 8. Validacao

- Subir o ambiente com `docker compose up --build` sem depender de PostgreSQL instalado na maquina.
- Confirmar que `http://localhost:3000/` retorna a resposta base da API.
- Confirmar que `http://localhost:3000/api-docs` abre o Swagger local.
- Confirmar que o backend conecta no banco usando o hostname `postgres`, sem alteracoes no codigo TypeScript.
- Confirmar que as tabelas do schema existem e que os dados de seed foram criados uma unica vez em um volume novo.
- Reiniciar apenas o servico `server` e validar que o banco continua com os mesmos dados.
- Reiniciar todo o Compose sem `-v` e validar que nao houve duplicacao de seed.
- Fazer `docker compose down -v` e subir novamente para validar bootstrap limpo do banco.
- Validar upload de documento para garantir que os diretorios de `temp` e `uploads` funcionam dentro do ambiente containerizado.

# 9. Riscos / Pendencias

- `server/src/server.ts` hoje usa `app.listen(PORT)` sem bind explicito em `0.0.0.0`. Em muitas imagens Node isso funciona, mas a implementacao deve confirmar o comportamento no container e ajustar se necessario.
- O script `server/src/scripts/setup-db.ts` continua util para execucao manual fora do Compose, mas nao deve ser acoplado ao startup do container porque o seed atual nao e totalmente idempotente.
- O ticket nao cobre hot reload automatico do backend dentro do container. Se isso virar requisito do time, sera necessario avaliar watcher dedicado para TypeScript em ambiente Docker.
- O ticket nao resolve integracoes externas ausentes no monorepo, como WhatsApp, FCM e RAG. A stack local continuara parcial em relacao ao fluxo fim a fim descrito no PRD.
