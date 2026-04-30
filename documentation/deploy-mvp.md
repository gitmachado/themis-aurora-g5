# Deploy MVP

## Objetivo

Documentar o deploy publico minimo do OmniConnect no recorte aprovado para o ticket `G5-7`: uma unica VM/VPS Linux com Docker, proxy HTTPS na borda, backend em container, PostgreSQL na mesma VM sem exposicao publica e documentos persistidos em Supabase Storage privado.

## Topologia aprovada

- VM/VPS unica para o MVP.
- Proxy reverso com HTTPS recebendo trafego publico em `443`.
- `server` acessivel apenas pela rede interna da VM/stack.
- `postgres` na mesma VM, sem publicar `5432` para a internet.
- Bucket privado no Supabase Storage para imagens e arquivos do app.
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
- `SUPABASE_URL=<url do projeto Supabase>`
- `SUPABASE_SERVICE_ROLE_KEY=<service role key do Supabase>`
- `SUPABASE_STORAGE_BUCKET=omniconnect-documents`
- `SUPABASE_STORAGE_SIGNED_URL_EXPIRES_IN=300`

## Bootstrap inicial

1. Copiar o repositorio para a VM.
2. Criar o arquivo `server/.env` com os valores de producao.
3. Executar `server/database/supabase-storage.sql` no Supabase SQL Editor do projeto usado pelo backend.
4. Subir os containers com `docker compose up -d --build`.
5. Validar se o PostgreSQL inicializou corretamente e executou `schema.sql` e `seed.sql` apenas no primeiro volume.
6. Validar se o backend subiu com `NODE_ENV=production` e sem expor `/api-docs`.
7. Conectar o proxy reverso ao container `server` na porta interna `3000`.
8. Emitir o certificado HTTPS no proxy e publicar o dominio.

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
- Arquivos: validar a politica de backup/retencao do bucket `omniconnect-documents` no Supabase.
- Arquivos de ambiente: manter backup seguro dos segredos fora da VM.

## Rollback

1. Identificar a ultima imagem ou revisao funcional do backend.
2. Reimplantar essa versao mantendo o mesmo volume do banco.
3. Validar `GET /health` e autenticao basica.
4. Se a falha envolver dados, restaurar dump recente do banco e validar os objetos do bucket privado no Supabase Storage.

## Limites conhecidos do MVP

- O backend ainda mantem fallback local quando Supabase Storage nao esta configurado, mas o deploy publico deve usar o bucket privado.
- O banco e o backend compartilham a mesma VM, sem alta disponibilidade.
- O deploy documentado aqui nao inclui CI/CD, observabilidade completa ou automacao de infraestrutura.
