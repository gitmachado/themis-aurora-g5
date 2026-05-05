## Themis

Bem-vindo ao repositorio do **Themis**, plataforma desenvolvida pelo **Grupo 5** para o **Desafio Final da Turma Aurora (Selene) - Ciclo I**.

Uma plataforma de **gestao inteligente de atendimento juridico**, onde clientes de escritorios de advocacia iniciam o contato via **WhatsApp com um chatbot de IA**, e os usuarios utilizam um **unico app Flutter** com perfis distintos para acompanhar o ciclo de vida do caso.

## Sobre o Projeto

Muitas empresas de servicos, especialmente **escritorios de advocacia**, enfrentam friccao no atendimento inicial de clientes e falta de visibilidade sobre o andamento de processos consultados informalmente via chat.

O **Themis** resolve isso eliminando a barreira inicial: o cliente inicia o atendimento via **WhatsApp**, onde um **chatbot alimentado por IA (RAG via LangChain)** interage e extrai os dados relevantes. Essas interacoes sao sincronizadas em tempo real com uma aplicacao central em **Flutter**, que oferece dashboards especificos para o cliente e para o advogado.

## Fluxo Local Recomendado

O ambiente local recomendado usa **Docker Compose** para subir apenas os servicos atualmente versionados no monorepo para backend: `server` e `postgres`.

O diretorio `mobile/` continua fora do Compose e deve ser executado com os comandos locais do Flutter.

### Scripts disponiveis

```bash
npm run docker:build
npm run docker:up
npm run docker:down
npm run docker:reset
npm run docker:ps
npm run docker:logs
npm run docker:logs:server
npm run docker:logs:db
```

### Fluxo sugerido

1. Na primeira execucao, rode `npm run docker:build`.
2. No dia a dia, rode `npm run docker:up`.
3. Para acompanhar o backend, rode `npm run docker:logs:server`.
4. Para acompanhar o banco, rode `npm run docker:logs:db`.
5. Para resetar completamente o ambiente local, rode `npm run docker:reset`.

### Endpoints locais

- API: [http://localhost:3000/](http://localhost:3000/)
- Swagger: [http://localhost:3000/api-docs](http://localhost:3000/api-docs)
- PostgreSQL: `localhost:5432`

### O que o reset faz

`npm run docker:reset` executa `docker compose down -v` seguido de `docker compose up --build`.

Isso remove os volumes do ambiente local, recria o banco e reaplica o bootstrap com `server/database/schema.sql` e `server/database/seed.sql` apenas no volume novo.

### Troubleshooting rapido

- Se alterou `Dockerfile`, dependencias ou `package-lock.json`, rode `npm run docker:build`.
- Se quiser verificar o estado da stack, rode `npm run docker:ps`.
- Se o banco estiver em estado inconsistente para desenvolvimento, rode `npm run docker:reset`.
- Se precisar parar tudo sem apagar dados, rode `npm run docker:down`.

## Fluxo Manual Alternativo

Se preferir rodar sem Docker, o fluxo manual continua disponivel.

1. Configure um PostgreSQL local com os mesmos valores esperados em `server/.env`.
2. No diretorio `server/`, instale dependencias e execute `npm run db:setup` uma vez para bootstrap do banco.
3. Ainda em `server/`, rode `npm run dev` para subir a API.
4. Acesse o Swagger em [http://localhost:3000/api-docs](http://localhost:3000/api-docs).

## Backend e Integracao

- **Linguagem/Framework:** Node.js com TypeScript
- **Documentacao API:** Swagger/OpenAPI 3.0 disponivel em `/api-docs`
- **WhatsApp:** Cloud API (Webhooks)
- **Tempo Real e Push:** WebSockets / Firebase Cloud Messaging (FCM)

## Inteligencia Artificial

- **Orquestracao:** LangChain
- **Conhecimento (RAG):** Pinecone, Chroma ou PGVector

## Stack Tecnologica

| Camada | Tecnologia |
| --- | --- |
| Backend | Node.js + TypeScript |
| Banco de Dados | PostgreSQL |
| IA / Orquestracao | LangChain + RAG |
| Frontend Mobile | Flutter |
| Mensageria | WhatsApp Business Cloud API |
| Notificacoes | Firebase Cloud Messaging (FCM) |
| Gestao do Projeto | Linear (integrado via MCP) |

## Equipe e Papeis (Grupo 5)

| Papel | Pessoa |
| --- | --- |
| Tech Lead / Backend | Mauricio |
| AI Specialist | Douglas e Aline |
| Flutter - Mobile (Cliente e Fornecedor) | Lucas e Alan |
| DevOps & QA | Thiago |

## Cronograma Recomendado (4 semanas)

1. **Semana 1** - Setup da API, banco, WhatsApp webhook e base do app Flutter.
2. **Semana 2** - Implementacao da IA com LangChain e RAG.
3. **Semana 3** - UX do app unico e notificacoes Firebase.
4. **Semana 4** - Testes, documentacao e demo ponta a ponta.

**Apresentacao final:** 15/05/2026 as 14h
