# RAG Pipeline (`/src/rag/`)

Este diretório contém o pipeline completo para Geração Aumentada de Recuperação (RAG) do projeto, usado para responder dúvidas jurídicas gerais.

## O que deve estar aqui:
- **Indexação (Script isolado ou função)**:
  - Carregamento de PDFs (`pdf-parse` / `PDFLoader`).
  - Divisão de texto (`RecursiveCharacterTextSplitter`).
  - Geração de Embeddings (`text-embedding-3-small`).
  - Salvar os embeddings no PostgreSQL através da extensão `pgvector`.
- **Recuperação (Retriever)**:
  - Função para realizar busca vetorial por similaridade no banco.
  - Formatação de contexto para ser entregue ao nó de RAG (`/graph/nodes/rag.ts`).
