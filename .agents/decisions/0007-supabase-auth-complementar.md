# ADR 0007: Supabase Auth complementar para ativacao de contas

## Status
Aceito

## Contexto

O fluxo principal de aquisicao de clientes nasce no WhatsApp: o bot coleta dados,
cria ou atualiza um lead por API Key, e o advogado decide se esse lead vira
cliente. Esse lead ainda nao e uma conta autenticada e pode nao ter email
validado no momento da conversa.

Ao mesmo tempo, o produto precisa suportar login por email, confirmacao de email
e convites de ativacao sem implementar manualmente confirmacao, reset de senha e
templates de autenticacao.

## Decisao

Supabase Auth sera usado como provedor complementar de identidade, nao como banco
de dominio nem como substituto da API Node.js.

1. Leads continuam sendo gravados no PostgreSQL da aplicacao.
2. O bot continua usando endpoints backend-to-backend protegidos por API Key.
3. A conta Supabase so e criada quando existe uma intencao real de acesso ao app:
   cadastro por email/senha ou conversao de lead com email.
4. A tabela `users` da aplicacao guarda `supabase_user_id` como vinculo opcional.
5. O backend continua sendo a fronteira de autorizacao do produto e emite o JWT
   usado pelas rotas atuais apos validar a identidade quando necessario.
6. Convites de leads convertidos exigem chave server-side do Supabase
   (`SUPABASE_SERVICE_ROLE_KEY`) e nunca devem usar chave publica no servidor
   para operacoes administrativas.

## Consequencias

### Positivas

- Email/password, confirmacao de email e convites passam a usar um provedor
  especializado.
- O fluxo de leads via WhatsApp nao fica bloqueado por ausencia de email.
- O modelo de dominio atual permanece sob controle do backend e do PostgreSQL.

### Negativas

- Passa a existir um identificador externo (`supabase_user_id`) que precisa ser
  mantido sincronizado com `users`.
- Ambientes locais e seeds podem existir sem usuarios Supabase correspondentes.
- Conversao de lead com convite por email depende de configuracao correta da
  chave server-side e dos redirects/templates no Supabase.

## Alternativas rejeitadas

### Criar usuario Supabase para todo lead

Rejeitada porque lead de WhatsApp nao e necessariamente uma conta autenticada e
pode nao ter email confiavel.

### Substituir a API Node.js por acesso direto ao Supabase

Rejeitada porque as regras de negocio, ownership, RBAC, bot integrations e
contratos do mobile ja estao centralizados no backend.
