# Números e Métricas do Projeto

## Cobertura da Modelagem

| Categoria | Total Requisitos | Cobertos | Parciais | Adiados |
|---|---|---|---|---|
| Chatbot WhatsApp | 10 | 8 | 1 | 1 (RAG) |
| App Flutter | 12 | 10 | 1 | 0 |
| Backend/Sync | 5 | 3 | 0 | 0 |
| Fluxos de Usuário | 3 | 2 | 0 | 1 (RAG) |
| **Total** | **30** | **23** | **2** | **2** |

## Estrutura de Código (Backend)

| Camada | Arquivos | Função |
|---|---|---|
| Models (entidades) | 7 | Interfaces TypeScript das entidades |
| Enums | 1 | 8 tipos enumerados do domínio |
| DTOs | 9 | Objetos de transferência por operação |
| Repository Interfaces | 7 | Contratos de acesso a dados |
| Service Interfaces | 7 | Contratos de regras de negócio |
| **Total** | **31** | Base completa para API e banco |

## Telas Mapeadas

| Perfil | Telas na Tab Bar | Telas de Navegação | Modais | Total |
|---|---|---|---|---|
| Cliente | 3 | 3 | 0 | 6 |
| Advogado | 4 | 4 | 2 | 10 |
| **Total** | **7** | **7** | **2** | **16** |

## Sprint / Cronograma

- **Semana 1-2:** Modelagem de dados, setup do backend, setup Flutter.
- **Semana 3:** API REST, integração frontend ↔ backend.
- **Semana 4:** Bot WhatsApp, RAG, polimento, testes.

## Progresso Atual

- ✅ Stack definida (Node.js + TS + PostgreSQL sem ORM)
- ✅ Frontend Flutter configurado (arquitetura por features)
- ✅ Modelagem de dados completa (7 entidades, 31 arquivos)
- ✅ Documentação de arquitetura com diagrama ER
- ✅ Padrões de commit e branch documentados
- ✅ Linear configurado com tasks de engenharia
- ⏳ Schema SQL (próximo passo)
- ⏳ Implementação da API REST
- ⏳ Integração WhatsApp
- ⏳ IA / RAG / PGVector
