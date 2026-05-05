---
description: Criar ou reescrever um PRD alinhado ao contexto real do Themis.
---

# Prompt: Criar PRD

## Objetivo

Produzir um PRD claro, enxuto e utilizavel pelo time do Themis, alinhado ao
contexto do produto descrito em `README.md`, `documentation/requisitos.md` e
demais documentos do repositorio.

## Entrada

- Descricao da ideia, funcionalidade ou problema
- Contexto adicional, se existir

## Como executar

1. Leia o contexto existente antes de escrever.
   - `README.md`
   - `documentation/requisitos.md`
   - `documentation/prd.md`, se o novo PRD for uma evolucao do atual

2. Identifique lacunas importantes.
   - Se faltar informacao critica para entender objetivo, fluxo, usuarios ou
     regra de negocio, liste as perguntas em aberto.
   - Se der para assumir algo com baixo risco, registre como `Assuncao`.

3. Escreva o PRD em linguagem de produto.
   - Fale de problema, valor entregue, requisitos e fluxo.
   - Nao desca para detalhes de classe, pasta ou implementacao.

## Estrutura recomendada

```md
# <Nome da iniciativa>

## 1. Visao Geral

## 2. Objetivo

## 3. Publico / Perfis envolvidos

## 4. Requisitos Funcionais

## 5. Regras de Negocio

## 6. Fluxos Principais

## 7. Fora do Escopo

## 8. Perguntas em Aberto / Assuncoes
```

## Regras

- Priorize clareza sobre volume.
- Nao invente integracoes ou telas sem base no pedido.
- Mantenha o texto em PT-BR.
- Se houver dependencia operacional do time, cite `Linear` como ferramenta de
  acompanhamento.
