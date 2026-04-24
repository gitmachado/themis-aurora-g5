# Config (`/src/config/`)

Este diretório concentra todas as configurações, validação de ambiente e integrações com o banco de dados.

## O que deve estar aqui:
- **Validação de `.env` (`env.ts`)**: Validação estrita das variáveis de ambiente usando `Zod` (Garantindo que `OPENAI_API_KEY`, `DATABASE_URL`, tokens do WA estejam presentes na inicialização).
- **Checkpointer (`checkpointer.ts`)**: Setup do `@langchain/langgraph-checkpoint-postgres`, responsável por gerenciar e persistir o estado das conversas no PostgreSQL, assegurando a "memória" de curto prazo por thread.
- **Database Client**: Conexão base com o Postgres (via `pg`) que será repassada ao checkpointer e ao pgvector.
