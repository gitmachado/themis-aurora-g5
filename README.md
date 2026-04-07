# OmniConnect – Gestão Inteligente de Serviços 🚀

Bem-vindo ao repositório do **OmniConnect**, plataforma desenvolvida pelo **Grupo 5** para o **Desafio Final da Turma Aurora (Selene) - Ciclo I**.

## 📋 Sobre o Projeto
Muitas empresas de serviços, especialmente **escritórios de advocacia**, enfrentam fricção no atendimento inicial de clientes e falta de visibilidade sobre o andamento de processos consultados informalmente via chat.

O **OmniConnect** resolve isso eliminando a barreira inicial: o cliente inicia o atendimento via **WhatsApp**, onde um **chatbot alimentado por IA (RAG via LangChain)** interage e extrai os dados relevantes. Essas interações são sincronizadas em tempo real com uma aplicação em **Flutter**, usada tanto pelo cliente quanto pelo fornecedor, para gerir o ciclo de vida do serviço de forma ágil, organizada e profissional.

---

## 🛠️ Tecnologias Principais

### Frontend (Mobile/Web)
- **Framework:** Flutter
- **Perfis:** Cliente (Histórico, acompanhamento, notificações) & Fornecedor (Dashboard, agenda, relatórios)

### Backend & Integração
- **Linguagem/Framework:** Node.js com TypeScript (Conforme [ADR 0001](./.agents/decisions/0001-stack-tecnologica-backend.md))
- **WhatsApp:** Cloud API (Webhooks)
- **Tempo Real & Push:** WebSockets / Firebase Cloud Messaging (FCM)

### Inteligência Artificial
- **Orquestração:** LangChain
- **Conhecimento (RAG):** Pinecone/Chroma/PGVector (a ser definido em ADRs futuros)

---

## 📚 Documentação
Toda documentação do projeto está localizada essencialmente nestas frentes:
- **[Requisitos Técnicos Oficiais](./docs/requisitos.md)** 
- **[Anotações sobre a Equipe](./docs/about_g5.md)**
- **[Registros de Decisões Importantes e ADRs](./.agents/decisions/):** Para a memória técnica e uso futuro pela nossa IA.

---

## 👥 Equipe (Grupo 5)
- **Maurício**: Tech Lead / Backend
- **Douglas**: AI Specialist
- **Lucas / Aline**: Flutter Developer (Client-side)
- **Alan**: Flutter Developer (Provider-side)
- **Thiago**: DevOps & QA / Coringa

📅 **Apresentação Oficial:** 15/05/2026 às 14:00