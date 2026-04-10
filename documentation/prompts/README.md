# Prompts do Projeto

Esta pasta foi simplificada para refletir o fluxo real do OmniConnect.

## Fluxo recomendado

1. `create-prd-prompt.md`
2. `refine-prd-prompt.md` - para ajustes no PRD, se necessario
3. `create-task-prompt.md` - para criar ou refinar issues no Linear
4. `create-spec-prompt.md`
5. `create-plan-prompt.md`
6. `implement-spec-prompt.md`
7. `create-tests-prompt.md` - quando for preciso criar ou reforcar cobertura de testes
8. `review-code-prompt.md`
9. `commit-code-prompt.md`
10. `create-pr-prompt.md`

## O que foi consolidado

- `create-spec-prompt.md` agora cobre criacao e refinamento de spec
- `implement-spec-prompt.md` agora cobre implementacao, ajuste de rota,
  mudancas em implementacao existente e atualizacao da spec quando necessario
- `update-spec-prompt.md` e `change-implementation-prompt.md` foram removidos
  para reduzir ambiguidade no fluxo

## Criterios usados na limpeza

- remover prompts presos a outro projeto
- remover referencias a `Jira`, Flutter-only e docs que nao existem aqui
- manter apenas o necessario para PRD, spec, implementacao, testes, revisao e entrega

## Convencoes

- rastreamento por `Linear`, nao `Jira`
- uso de paths reais do repositorio
- foco em `mobile/`, `server/` e `documentation/`
- prompts enxutos, orientados a execucao

## Sincronizacao com agentes

Para espelhar esses prompts para os diretórios dos agentes, use:

```bash
bash scripts/sync-agent-prompts.sh
```

O script gera comandos compatíveis com Cursor, OpenCode, Claude Code, Codex,
Antigravity e GitHub Copilot.
