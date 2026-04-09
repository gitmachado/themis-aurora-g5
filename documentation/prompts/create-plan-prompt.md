---
description: Quebrar uma spec em fases e tarefas executaveis antes da implementacao.
---

# Prompt: Criar Plano

## Objetivo

Transformar uma spec em um plano de execucao simples, rastreavel e aderente ao
fluxo do OmniConnect.

## Entrada

- Caminho da spec

## Leituras obrigatorias

- `documentation/prd.md`
- `documentation/requisitos.md`
- `documentation/architecture.md`
- a spec informada

## Como montar o plano

1. Entenda o objetivo da entrega.
   - Identifique problema, fluxo principal, regras de negocio e limites de escopo.

2. Mapeie os workspaces afetados.
   - `mobile/`
   - `server/`
   - `documentation/`
   - outros diretorios do monorepo, se realmente fizer sentido

3. Quebre a implementacao em fases pequenas.
   - Cada fase deve gerar um resultado verificavel.
   - Respeite dependencias reais: contratos e dados antes de interface, base
     tecnica antes de polimento.

4. Descreva tarefas executaveis.
   - Cada tarefa deve ser objetiva.
   - Evite itens vagos como "fazer backend" ou "ajustar app".
   - Se algo puder rodar em paralelo, sinalize.

## Formato esperado

```md
# Plano de Implementacao

## Objetivo

<resumo curto>

## Fases

### Fase 1 - <nome>
- [ ] Tarefa 1
- [ ] Tarefa 2

### Fase 2 - <nome>
- [ ] Tarefa 3

## Dependencias

| Fase | Depende de | Pode rodar em paralelo? |
| --- | --- | --- |
| Fase 1 | - | - |
| Fase 2 | Fase 1 | sim/nao |

## Validacao

- checks que devem ser executados ao final
- riscos ou bloqueios conhecidos
```

## Regras

- Nao invente tarefas que nao derivem da spec.
- Nao replique o texto da spec sem transformacao em trabalho executavel.
- Se houver duvida relevante, registre em `Bloqueios / Perguntas em aberto`.
