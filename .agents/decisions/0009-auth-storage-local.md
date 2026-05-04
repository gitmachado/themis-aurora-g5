# ADR 0009: Auth e storage locais para o MVP

## Status

Aceito

## Contexto

As ADRs 0007 e 0008 introduziram Supabase Auth e Supabase Storage como
complementos ao backend Node.js. A direcao atual do produto mudou: o MVP deve
rodar sem dependencia de Supabase, sem confirmacao de email e com dados
persistidos no banco e no filesystem local da stack.

## Decisao

Remover Supabase dos fluxos ativos do backend.

1. Autenticacao usa somente o backend local: email, `password_hash` com bcrypt
   e JWT emitido pela API.
2. Cadastro retorna token imediatamente, sem confirmacao de email.
3. Conversao de lead cria usuario local com senha temporaria.
4. Fotos de perfil e documentos usam `LocalFileStorageProvider`.
5. Arquivos binarios ficam em volume persistente local, expostos pelo backend em
   `/uploads`.
6. Metadados continuam no PostgreSQL local.
7. A coluna `users.supabase_user_id` deixa de fazer parte do modelo de dominio.

## Consequencias

- O deploy deixa de exigir `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, bucket,
  redirects ou SQL Editor externo.
- Backup operacional precisa cobrir PostgreSQL e o volume local de uploads.
- Escalabilidade horizontal continua fora do escopo do MVP enquanto houver
  dependencia de filesystem local.
- O app Flutter continua falando apenas com o backend e recebe URLs resolvidas a
  partir de `/uploads`.

## ADRs superadas

- ADR 0007: Supabase Auth complementar para ativacao de contas.
- ADR 0008: Supabase Storage para documentos e fotos de perfil do app.
