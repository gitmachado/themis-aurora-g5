# Deploy MVP

## Objetivo

Documentar o deploy publico minimo do OmniConnect no recorte aprovado para o ticket `G5-7`: uma unica VM/VPS Linux com Docker, proxy HTTPS na borda, backend em container, PostgreSQL na mesma VM sem exposicao publica e documentos persistidos em volume local.

## Topologia aprovada

- VM/VPS unica para o MVP.
- Proxy reverso com HTTPS recebendo trafego publico em `443`.
- `server` acessivel apenas pela rede interna da VM/stack.
- `postgres` na mesma VM, sem publicar `5432` para a internet.
- Volume local persistente para uploads em `server/uploads`.
- Swagger desabilitado quando `NODE_ENV=production`.

## Pre-flight

- Provisionar uma VM Linux com Docker e Docker Compose disponiveis.
- Configurar dominio apontando para o IP publico da VM.
- Garantir que apenas `80/443` fiquem publicos na borda.
- Garantir que a porta do banco nao esteja publicada para a internet.
- Criar `server/.env` a partir de `server/.env.example`.

## Variaveis obrigatorias para deploy publico

- `NODE_ENV=production`
- `PORT=3000`
- `DB_HOST=<hostname interno do postgres>`
- `DB_PORT=5432`
- `DB_USER=<usuario do banco>`
- `DB_PASSWORD=<senha forte>`
- `DB_NAME=<nome do banco>`
- `JWT_SECRET=<segredo forte>`
- `JWT_EXPIRE_IN=7d`
- `BOT_API_KEY=<chave obrigatoria para integracoes sistema-a-sistema>`
- `CORS_ORIGIN=<origem ou lista de origens separadas por virgula>`

## Bootstrap inicial

1. Copiar o repositorio para a VM.
2. Criar o arquivo `server/.env` com os valores de producao.
3. Subir os containers com `docker compose up -d --build`.
4. Validar se o PostgreSQL inicializou corretamente e executou `schema.sql` e `seed.sql` apenas no primeiro volume.
5. Validar se o backend subiu com `NODE_ENV=production` e sem expor `/api-docs`.
6. Conectar o proxy reverso ao container `server` na porta interna `3000`.
7. Emitir o certificado HTTPS no proxy e publicar o dominio.

## Restart

- Reinicio simples da stack: `docker compose down && docker compose up -d`
- Reinicio apenas do backend: `docker compose restart server`
- Verificacao de status: `docker compose ps`
- Logs do backend: `docker compose logs -f server`
- Logs do banco: `docker compose logs -f postgres`

## Smoke test

Executar apos bootstrap ou restart:

1. `GET /health` deve responder `200` com `{"status":"ok"}`.
2. `GET /` deve responder `200` com a mensagem base da API.
3. `GET /api-docs` nao deve estar publico em `NODE_ENV=production`.
4. Rotas autenticadas em `/api/v1/*` devem continuar exigindo JWT valido.
5. Rotas de integracao protegidas por `x-api-key` devem rejeitar chamadas sem `BOT_API_KEY` valida.
6. O banco deve permanecer acessivel apenas pela rede interna da stack.

## Backup basico

- Banco: executar dump periodico do PostgreSQL e copiar para fora da VM.
- Uploads: copiar periodicamente o volume/diretorio persistente de `uploads` para armazenamento externo.
- Arquivos de ambiente: manter backup seguro dos segredos fora da VM.

## Rollback

1. Identificar a ultima imagem ou revisao funcional do backend.
2. Reimplantar essa versao mantendo o mesmo volume do banco.
3. Validar `GET /health` e autenticao basica.
4. Se a falha envolver dados, restaurar dump recente do banco e o backup de uploads.

## Limites conhecidos do MVP

- O backend ainda depende de storage local, entao esta topologia nao e adequada para ambiente stateless.
- O banco e o backend compartilham a mesma VM, sem alta disponibilidade.
- O deploy documentado aqui nao inclui CI/CD, observabilidade completa ou automacao de infraestrutura.
