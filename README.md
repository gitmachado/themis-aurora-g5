## 🎯  OmniConnect

Uma plataforma de **gestão inteligente de atendimento jurídico**, onde clientes de escritórios de advocacia iniciam o contato via **WhatsApp com um chatbot de IA**, e tanto o cliente quanto o advogado usam um **app Flutter** para acompanhar o ciclo de vida do caso.

---

## ⚖️ Nicho Escolhido: Advocacia

O foco é resolver dois problemas comuns em escritórios:

- **Triagem inteligente de casos** — o bot coleta as informações iniciais do cliente automaticamente via WhatsApp, sem precisar de um atendente humano pra isso.
- **Consulta de status de processos** — o cliente consegue perguntar no WhatsApp (ou ver no app) em que pé está o seu caso.

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

## 👥 Equipe e Papéis

| Papel | Pessoa |
|---|---|
| Tech Lead / Backend | Mauricio |
| AI Specialist | Douglas |
| Flutter — lado do cliente | Lucas e Aline |
| Flutter — lado do fornecedor (advogado) | Alan |
| DevOps & QA | Thiago |

---

## 📅 Cronograma Recomendado (4 semanas)

1. **Semana 1** — Setup da API, banco, WhatsApp webhook e base do app Flutter
2. **Semana 2** — Implementação da IA com LangChain e RAG (base de conhecimento jurídico)
3. **Semana 3** — UX dos dois apps + notificações Firebase
4. **Semana 4** — Testes, documentação e demo de 10 minutos ponta a ponta

**Apresentação final:** 15/05/2026 às 14h