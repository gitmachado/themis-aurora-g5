# ADR-0008: Supabase Storage para documentos e fotos de perfil do app

## Status

Superada pela ADR 0009

## Nota de superacao

Em 2026-05-02, documentos e fotos de perfil voltaram a usar somente
`LocalFileStorageProvider`, com binarios persistidos em volume local e expostos
por `/uploads`. O deploy publico nao depende mais de bucket privado, service
role key ou SQL Editor do Supabase.

## Contexto

O fluxo de documentos do Themis mantem metadados no PostgreSQL local (`documents.file_url`, `file_name`, `mime_type`, `size_bytes`), mas o binario era gravado em `server/uploads` via `LocalFileStorageProvider`. Fotos de perfil tambem nao tinham armazenamento real. Esse desenho funcionava em VM unica, mas dificultava evoluir para hospedagem stateless e impedia centralizar imagens e arquivos no mesmo ecossistema Supabase ja adotado para Auth.

## Decisao

Usar Supabase Storage como provider primario de arquivos do app, por meio do backend Node.js.

- O bucket padrao e `Themis-documents`.
- O bucket deve ser privado.
- Upload, remocao e geracao de URL assinada acontecem no backend usando `SUPABASE_SERVICE_ROLE_KEY`.
- O app Flutter continua falando apenas com o backend e nao recebe a service role key.
- O PostgreSQL da aplicacao continua sendo a fonte dos metadados e das regras de ownership.
- Fotos de perfil ficam em `users.avatar_url` e os objetos sao salvos no prefixo `avatars/{userId}`.
- O `LocalFileStorageProvider` permanece como fallback para ambientes sem Supabase Storage configurado.

## Consequencias

- A visualizacao de arquivos passa a usar URL assinada temporaria via `GET /api/v1/documents/{id}/access-url`.
- A foto de perfil passa a ser atualizada por `POST /api/v1/account/avatar` e retornada em `GET /api/v1/account`.
- O app consegue abrir PDFs, imagens e documentos comuns sem tornar o bucket publico.
- Para provisionar o bucket, executar `server/database/supabase-storage.sql` no Supabase SQL Editor.
- Backups de binarios passam a ser responsabilidade do Supabase Storage, enquanto o banco local preserva apenas metadados.
