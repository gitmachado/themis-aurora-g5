# Graph (`/src/graph/`)

Este diretório contém o núcleo conversacional do bot Themis, construído utilizando o **LangGraph**.

## O que deve estar aqui:
- **`state.ts`**: Definição do esquema de estado (`ThemisState`) usando `Annotation` (inclui histórico de mensagens, dados de triagem coletados, `whatsappNumber` e intent atual).
- **`nodes/`**: Funções puras e isoladas que representam cada passo do bot:
  - `router`: Classifica a intenção da mensagem (triage, status, rag, handoff).
  - `triage`: Coleta de forma sequencial os dados do lead (Nome, CPF, etc).
  - `status`: Consulta e formatação de processos existentes.
  - `rag`: Busca na base de conhecimento.
  - `handoff`: Transfere para humano com a função `interrupt`.
  - `sync`: Sincroniza a troca de mensagens com o backend.
- **`index.ts`** (ou `graph.ts`): Conexão de todos os nós através de arestas condicionais e exportação do grafo compilado.
