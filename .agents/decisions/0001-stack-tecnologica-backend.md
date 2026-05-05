### 1. Título
Decisão 0001: Definição da Stack Tecnológica do Backend

### 2. Status
- **Activated**: Aprovado e ativo em 07/04/2026.

### 3. Contexto
- O projeto Themis requer uma API robusta para gerenciar comunicações via WhatsApp, integração com IA (LangChain) e sincronização em tempo real com o frontend Flutter.
- Precisamos de um ambiente de desenvolvimento padronizado e fácil de escalar.
- Alternativas consideradas: FastAPI (Python) vs Node.js.

### 4. Decisão
- **Linguagem/Runtime**: Node.js com TypeScript.
- **Banco de Dados**: PostgreSQL (com suporte a PGVector para RAG futuramente).
- **Infraestrutura**: Docker e Docker Compose para orquestração de containers.

**Justificativa**: 
- Node.js possui um ecossistema amadurecido para I/O intensivo e integrações de Webhooks (WhatsApp API).
- TypeScript garante segurança de tipos e melhor manutenção do código em equipe.
- PostgreSQL é relacional, confiável e possui extensões excelentes para vetores (PGVector), essenciais para a parte de IA do projeto.
- Docker garante que todos os desenvolvedores do Grupo 5 trabalhem no mesmo ambiente.

### 5. Consequências
- **Positivas**: Tipagem forte, ambiente isolado, facilidade de integração com bibliotecas de orquestração de IA que suportam JS/TS.
- **Negativas**: Curva de aprendizado inicial para configuração do ambiente Docker com TS e migrações de banco de dados.
