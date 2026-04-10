---
description: Criar ou refinar uma spec tecnica objetiva a partir do PRD e da estrutura atual do repositorio.
---

# Prompt: Criar ou Refinar Spec

## Objetivo

Traduzir um requisito de produto em uma especificacao tecnica executavel dentro
do fluxo do OmniConnect, ou refinar uma spec existente para que ela volte a
ficar coerente com o PRD, com a codebase e com o caminho real de implementacao.

## Quando usar

- Criar uma spec nova a partir de um PRD
- Refinar uma spec ja existente antes de implementar
- Reorganizar uma spec confusa sem mudar indevidamente o escopo

## Entrada

- PRD ou trecho do PRD relacionado
- Descricao da entrega
- Spec atual, quando ja existir
- Ticket do Linear, se existir

## Leituras obrigatorias

- `documentation/prd.md`
- `documentation/requisitos.md`
- `documentation/architecture.md`
- arquivos ja existentes na codebase que se relacionam com a entrega

## Como executar

1. Entenda o problema e o fluxo.
   - Identifique quem usa a funcionalidade, qual evento inicia o fluxo e quais
     sistemas ou apps sao impactados.

2. Mapeie o impacto tecnico real.
   - Quais diretorios serao tocados
   - Quais contratos, dados ou integracoes precisam mudar
   - O que ja existe e deve ser reutilizado

3. Crie ou refine a spec.
   - Se a spec for nova, escreva do zero com base no PRD e na codebase.
   - Se a spec ja existir, ajuste estrutura, clareza e precisao sem reescrever
     tudo sem necessidade.
   - Elimine ambiguidades e registre suposicoes ou pendencias quando faltarem
     evidencias.

4. Garanta que a spec fique implementavel.
   - Descreva arquivos a criar ou alterar usando caminhos reais do repositorio.
   - Separe claramente backend, mobile e documentacao quando aplicavel.
   - Inclua validacoes e limites de escopo.

## Estrutura obrigatoria

```md
---
title: <titulo da spec>
ticket: <LINEAR-ID ou N/A>
branch: <nome-sugerido-da-branch>
status: open
last_updated_at: <YYYY-MM-DD>
---

# 1. Objetivo

# 2. Escopo
## 2.1 In scope
## 2.2 Out of scope

# 3. Contexto atual

# 4. O que ja existe

# 5. O que deve ser implementado

# 6. Arquivos impactados

# 7. Fluxo tecnico

# 8. Validacao

# 9. Riscos / Pendencias
```

## Regras

- Nao invente arquitetura que nao exista no repositorio.
- Nao replique o PRD; detalhe apenas o necessario para implementar.
- Defina o nome da branch usando os padroes de Conventional Commits (ex: `feat/g5-x-nome`).
- Use caminhos reais, por exemplo `mobile/`, `server/` e `documentation/`.
- Quando algum arquivo ainda nao existir, marque como `novo arquivo`.
- Se a entrega depender de algo fora do escopo atual, registre em `Riscos / Pendencias`.
