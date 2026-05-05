-- Migração: Habilitar pgvector e criar tabela de embeddings (RAG)
-- Aplicar em volumes já existentes:
-- docker exec themis-postgres psql -U $POSTGRES_USER -d $POSTGRES_DB -f /tmp/migrate-pgvector.sql

CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS knowledge_embeddings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    content TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    embedding vector(768),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_knowledge_embedding_hnsw
ON knowledge_embeddings
USING hnsw (embedding vector_cosine_ops);
