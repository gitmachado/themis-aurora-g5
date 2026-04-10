---
title: "BE - Modelagem de dados e definição do banco de dados (S/ ORM)"
ticket: G5-8
status: in-progress
last_updated_at: 2026-04-09
---

# 1. Objetivo

Definir a modelagem de dados do backend OmniConnect via TypeScript (interfaces, DTOs e contratos de serviço/repositório) como fundação para a criação posterior do schema PostgreSQL e das APIs REST. Nenhum ORM será utilizado (ADR-0003).

# 2. Escopo

## 2.1 In scope

- Estruturar `server/src/` com arquitetura em camadas (models, dtos, repositories/interfaces, services/interfaces).
- Definir interfaces TypeScript para todas as entidades do domínio do MVP.
- Definir DTOs para operações de criação/atualização.
- Definir contratos (interfaces) para repositories e services.
- Registrar diagrama ER em `documentation/architecture.md`.
- Configurar TypeScript no `server/` (tsconfig.json, devDependencies).

## 2.2 Out of scope

- Criação do schema SQL (`schema.sql`) — próximo passo após validação.
- Implementação concreta dos repositories e services.
- Configuração de servidor HTTP (Express/Fastify).
- Tabela `embeddings_rag` / PGVector — ticket de IA separado.
- Entidade `Tarefa` — removida do MVP por decisão do usuário.

# 3. Contexto atual

- O PRD define 3 blocos funcionais: Chatbot WhatsApp, App Flutter (2 perfis), Backend + Sincronização.
- ADR-0003 determina PostgreSQL sem ORM (driver `pg` nativo).
- `server/` continha apenas um `package.json` mínimo.
- Análise de referência realizada em CRMs jurídicos (Astrea, Projuris) e gerais (Pipedrive, HubSpot).

# 4. O que deve ser implementado

1. **Enums** — tipos discriminados do domínio (TipoCaso, StatusLead, UserRole, etc.)
2. **Models** — 7 interfaces de entidade (User, Lead, Processo, TimelineEvento, Documento, Mensagem, Notificacao)
3. **DTOs** — 9 objetos de transferência (auth, criação de lead, conversão, processo, status, timeline, documento, mensagem, notificação)
4. **Repository Interfaces** — 7 contratos CRUD + operações específicas
5. **Service Interfaces** — 7 contratos de regra de negócio
6. **Placeholders** — diretórios controllers, config, middlewares, utils

# 5. Entidades

| Entidade | Responsabilidade | Campos-chave |
|---|---|---|
| User | Advogados e Clientes | role, whatsappNumber, fcmToken |
| Lead | Pré-cadastro via bot | 6 campos PRD §2.1, status, convertedUserId |
| Processo | Caso jurídico do cliente | clienteId, statusAtual, tipoCaso |
| TimelineEvento | Histórico cronológico | processoId, tipo, conteudo, metadata |
| Documento | Arquivos do processo | processoId, urlArquivo, tipoMime |
| Mensagem | Chat WhatsApp persistido | leadId/userId, remetente, whatsappMessageId |
| Notificacao | Push FCM | userId, tipo, lida |

# 6. Arquivos impactados

## Novos
- `server/tsconfig.json`
- `server/src/models/enums.ts`
- `server/src/models/*.model.ts` (7 arquivos)
- `server/src/models/dtos/*.dto.ts` (9 arquivos)
- `server/src/repositories/interfaces/*.repository.ts` (7 arquivos)
- `server/src/services/interfaces/*.service.ts` (7 arquivos)
- `server/src/controllers/.gitkeep`
- `server/src/config/.gitkeep`
- `server/src/middlewares/.gitkeep`
- `server/src/utils/.gitkeep`

## Modificados
- `server/package.json` — adição de typescript e @types/node
- `documentation/architecture.md` — diagrama ER e arquitetura backend
- `documentation/commit-pattern.md` — padrão de branch

# 7. Validação

- `npx tsc --noEmit` compila sem erros.
- Nenhum ORM presente em `package.json`.
- Todos os 6 campos de coleta obrigatória do Lead (PRD §2.1) estão representados.
- Fluxo Lead → User → Processo → Timeline → Notificação refletido nos relacionamentos.

# 8. Riscos / Pendências

- O `statusAtual` do Processo é `string` livre — pode ser necessário restringir para um enum quando as regras de negócio de transição de status forem definidas.
- A relação Mensagem com Lead vs User (pré e pós-conversão) pode exigir migração de referência quando um lead é convertido.
- A tabela `embeddings_rag` (PGVector) ficou fora do escopo e deve ser criada no ticket de IA.
