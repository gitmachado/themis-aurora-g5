---
description: Criar um PR claro e rastreavel a partir de um ticket do Linear e das alteracoes realizadas.
---

# Prompt: Criar PR

## Objetivo

Abrir ou redigir um Pull Request com contexto suficiente para revisao rapida,
sempre rastreavel ao ticket do Linear.

## Entrada

- Ticket do Linear
- Resumo das alteracoes implementadas
- Validacoes executadas
- Branch atual

## Regras

- O titulo deve iniciar com o ticket do Linear.
- O texto deve ser conciso, tecnico e verificavel.
- Se o usuario pedir para abrir o PR, use `gh` apenas se o repositorio remoto
  estiver configurado e a branch ja tiver sido enviada.
- Se faltarem dados para abrir o PR, gere o titulo e o body prontos para uso.

## Titulo

Formato:

```text
[TIC-45] descreve a entrega em PT-BR
```

## Corpo sugerido

```md
## Objetivo
- o que este PR entrega

## O que mudou
- mudanca 1
- mudanca 2

## Como validar
1. passo 1
2. passo 2

## Checks executados
- comando e resultado

## Riscos ou observacoes
- pontos que merecem atencao na revisao
```

## Saida esperada

- Titulo final
- Body final
- Comando `gh pr create` usado, se o PR for aberto de fato
- URL do PR, se a criacao for bem-sucedida
