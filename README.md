## 🎯 OmniConnect

Bem-vindo ao repositório do **OmniConnect**, plataforma desenvolvida pelo **Grupo 5** para o **Desafio Final da Turma Aurora (Selene) - Ciclo I**.

Uma plataforma de **gestão inteligente de atendimento jurídico**, onde clientes de escritórios de advocacia iniciam o contato via **WhatsApp com um chatbot de IA**, e os usuários (cliente e advogado) utilizam um **único app Flutter** com perfis distintos para acompanhar o ciclo de vida do caso.

---

## 📋 Sobre o Projeto
Muitas empresas de serviços, especialmente **escritórios de advocacia**, enfrentam fricção no atendimento inicial de clientes e falta de visibilidade sobre o andamento de processos consultados informalmente via chat.

O **OmniConnect** resolve isso eliminando a barreira inicial: o cliente inicia o atendimento via **WhatsApp**, onde um **chatbot alimentado por IA (RAG via LangChain)** interage e extrai os dados relevantes. Essas interações são sincronizadas em tempo real com uma aplicação central em **Flutter**, que oferece dashboards específicos para o cliente e para o advogado, permitindo gerir o ciclo de vida do serviço de forma ágil e organizada.

---

## ⚖️ Nicho Escolhido: Advocacia

O foco é resolver dois problemas comuns em escritórios:
- **Triagem inteligente de casos** — o bot coleta as informações iniciais do cliente automaticamente via WhatsApp, sem precisar de um atendente humano pra isso.
- **Consulta de status de processos** — o cliente consegue perguntar no WhatsApp (ou ver no app) em que pé está o seu caso.

### Backend & Integração
- **Linguagem/Framework:** Node.js com TypeScript (Conforme [ADR 0001](./.agents/decisions/0001-stack-tecnologica-backend.md))
- **WhatsApp:** Cloud API (Webhooks)
- **Tempo Real & Push:** WebSockets / Firebase Cloud Messaging (FCM)

### Inteligência Artificial
- **Orquestração:** LangChain
- **Conhecimento (RAG):** Pinecone/Chroma/PGVector (a ser definido em ADRs futuros)

---

## 🛠️ Stack Tecnológica

| Camada | Tecnologia |
|---|---|
| Backend | Node.js + TypeScript |
| Banco de Dados | PostgreSQL (via Docker) |
| IA / Orquestração | LangChain + RAG |
| Frontend Mobile | Flutter |
| Mensageria | WhatsApp Business Cloud API |
| Notificações | Firebase Cloud Messaging (FCM) |
| Gestão do Projeto | Linear (integrado via MCP) |

---

## 👥 Equipe e Papéis (Grupo 5)

| Papel | Pessoa |
|---|---|
| Tech Lead / Backend | Maurício |
| AI Specialist | Douglas |
| Flutter — Mobile (Cliente e Fornecedor) | Lucas, Aline e Alan |
| DevOps & QA | Thiago |

---

## 📅 Cronograma Recomendado (4 semanas)

1. **Semana 1** — Setup da API, banco, WhatsApp webhook e base do app Flutter
2. **Semana 2** — Implementação da IA com LangChain e RAG (base de conhecimento jurídico)
3. **Semana 3** — UX do app único (Perfís) + notificações Firebase
4. **Semana 4** — Testes, documentação e demo de 10 minutos ponta a ponta

**Apresentação final:** 15/05/2026 às 14h