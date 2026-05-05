# Knowledge (`/knowledge/`)

Este diretório armazena os arquivos de base (geralmente PDFs) utilizados pelo sistema RAG (Recuperação).

## O que deve estar aqui:
- Arquivos de FAQ (Perguntas frequentes).
- Documentos explicativos por tipo de caso (ex: Regras Trabalhistas, Documentos necessários para Inventário).
- Regras e tom de voz extenso do escritório.

> **Nota:** Estes arquivos são processados pelos scripts em `/src/rag/` e transformados em embeddings no banco de dados. Este diretório funciona como o repositório de dados brutos ("source of truth" textual).
