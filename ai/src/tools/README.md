# Tools (`/src/tools/`)

Este diretório armazena as **Ferramentas (Tools)** que o LangGraph (e os LLMs) utiliza para interagir com sistemas externos, especificamente a API do backend Node.js.

## O que deve estar aqui:
Todas as ferramentas devem seguir a padronização do LangChain (`snake_case` e validação com `Zod`):
- `create_lead`: Chama `POST /api/v1/leads` para cadastrar um lead novo.
- `sync_message`: Chama `POST /api/v1/messages/sync` para espelhar a conversa para o app Flutter.
- `get_client_processes`: Chama `GET /api/v1/processes/by-phone/:number` para buscar processos do cliente.
- `notify_lawyer`: Chama `POST /api/v1/notifications` quando ocorre um handoff.
- `get_bot_config`: Chama `GET /api/v1/configurations` para carregar o tom de voz e horários de atendimento.
