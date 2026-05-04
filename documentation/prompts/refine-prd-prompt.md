---
description: Refinar um PRD existente sem mudar o escopo original de forma indevida.
---

# Prompt: Refinar PRD

## Objetivo

Melhorar clareza, estrutura e consistencia de um PRD ja existente, mantendo o
conteudo fiel ao que foi decidido para o Themis.

## Entrada

- Caminho do PRD em Markdown

## Como executar

1. Leia o documento completo e o contexto minimo relacionado.
   - `README.md`
   - `documentation/requisitos.md`
   - `documentation/prd.md`, se nao for o proprio arquivo de entrada

2. Refine sem aumentar o escopo.
   - Reorganize secoes.
   - Reescreva trechos confusos.
   - Transforme ambiguidade em `Perguntas em aberto` ou `Assuncoes`.

3. Valide referencias.
   - Se citar arquivos do repositorio, confira se existem.
   - Se citar `Jira`, substitua por `Linear` quando a referencia for de fluxo do
     projeto e nao de contexto historico.

## Saida esperada

- Documento refinado em Markdown
- Lista curta das principais melhorias feitas
- Referencias quebradas ou pontos ainda ambiguos
