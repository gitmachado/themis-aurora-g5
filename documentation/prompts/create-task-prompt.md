---
description: Criar ou refinar issues no Linear seguindo o padrao de qualidade do Themis.
---

# Prompt: Criar ou Refinar Task no Linear

## Objetivo

Transformar um requisito de produto, spec ou necessidade tecnica em uma issue
acionavel no Linear, ou refinar uma issue existente para que siga os padroes de
qualidade do projeto.

## Quando usar

- Criar uma task nova a partir de um PRD ou spec
- Refinar uma task existente que esta vaga ou incompleta
- Padronizar o backlog inteiro para um formato consistente

## Entrada

- Requisito ou descricao do que precisa ser feito
- Ticket existente no Linear (quando for refinamento)
- Spec relacionada, se existir

## Leituras obrigatorias

- `documentation/prd.md`
- `documentation/architecture.md`
- `documentation/requisitos.md`
- spec relacionada, se existir

## Template da issue

```md
## 🎯 Objetivo

[1-3 frases: o que estamos construindo e por que isso importa]

## 📖 Contexto

[Breve explicacao do problema ou necessidade + decisoes anteriores relevantes]

**Referencias do repositorio:**
- PRD: `documentation/prd.md` §[secao]
- Arquitetura: `documentation/architecture.md`
- Spec: `documentation/specs/[arquivo]` (se existir)

## 📋 Escopo

### In Scope
- [ ] Entregavel 1
- [ ] Entregavel 2

### Out of Scope
- Item excluido — [motivo]

## ✅ Criterios de Aceite

1. [Criterio testavel e mensuravel]
2. [Maximo 5-6 criterios; se precisar de mais, divida a task]

## 🔧 Restricoes Tecnicas

- [Padroes obrigatorios]
- Branch: `feat/G5-XX-nome`
- Commit pattern: Conventional Commits em PT-BR

## 🔗 Dependencias (se aplicavel)

| Depende de | Status |
|---|---|
| G5-XX (Nome) | Status |

## ⚠️ Riscos (se aplicavel)

- [Risco tecnico ou de negocio]
```

## Titulo da issue

Formato: `[Area] Verbo + Objeto`

Areas validas: `[BE]`, `[FE-Core]`, `[FE-Feature]`, `[Infra]`, `[DevOps]`,
`[AI]`, `[Docs]`, `[QA]`

## Regras

- Nao crie tasks que nao derivem de um requisito real.
- Use caminhos reais do repositorio nas referencias.
- Criterios de aceite devem ser verificaveis por CI ou revisao humana objetiva.
- Maximo 5-6 criterios por task; se precisar de mais, divida a issue.
- Se houver risco tecnico, registre na secao de Riscos — nunca enterre no texto.
- Evite termos vagos nos criterios ("rapido", "simples", "user-friendly").
- Use metricas quando possivel (tempo de resposta, cobertura de testes, etc).
