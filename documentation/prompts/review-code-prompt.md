---
description: Revisar codigo com foco em bugs, regressao e aderencia ao fluxo do projeto.
---

# Prompt: Revisar Codigo

## Objetivo

Realizar uma revisao tecnica objetiva do codigo alterado, priorizando bugs,
quebras de fluxo, inconsistencias com a spec e lacunas de validacao.

## Entrada

- Caminho, diff ou conjunto de arquivos para revisar
- Spec relacionada, se existir

## Como revisar

1. Entenda o que deveria acontecer.
   - Leia a spec e o contexto funcional antes de olhar os detalhes da implementacao.

2. Revise com foco em risco.
   - bugs de logica
   - contratos quebrados
   - fluxos nao tratados
   - validacoes ausentes
   - documentacao desatualizada

3. Verifique os checks disponiveis.
   - Rode os testes e analisadores existentes no escopo alterado.
   - Se o projeto ainda nao tiver automacao naquela parte do monorepo, registre isso.

## Formato da resposta

Liste primeiro os achados, em ordem de severidade, com:

- arquivo
- problema
- impacto
- recomendacao

Se nao houver achados, diga explicitamente que nenhum problema relevante foi
identificado e cite riscos residuais ou gaps de teste.
