---
name: docs-sync
description: Verificar e manter sincronizadas as duas bases de documentação do projeto — `.agents/` (consumida por agentes de IA) e `documentation/` (consumida pela equipe humana). Use essa skill sempre que o usuário alterar documentação em qualquer uma das duas bases, quando pedir para "sincronizar docs", "verificar consistência", ou quando houver uma mudança arquitetural significativa (como a unificação do app mobile) que impacte ambos os lados.
---

# Docs Sync — Sincronização `.agents/` ↔ `documentation/`

O projeto OmniConnect mantém duas bases de documentação paralelas:

- **`documentation/`** — Consumida pela equipe humana. Contém o PRD, specs
  técnicas, prompts, padrões de commit, e arquitetura.
- **`.agents/`** — Consumida por agentes de IA (Antigravity, Claude Code, Cursor,
  Copilot). Contém knowledge base, ADRs, workflows, rules e skills.

Ambas descrevem o **mesmo projeto** mas para **audiências diferentes**. Quando uma
muda, a outra precisa refletir a mudança ou o projeto fica inconsistente.

## Mapa de Sobreposição

Este mapa define quais arquivos/diretórios devem estar sincronizados. A coluna
"Fonte de Verdade" indica qual lado é o primário — o outro deve derivar dele.

| Conceito | `.agents/` | `documentation/` | Fonte de Verdade |
|---|---|---|---|
| Stack e arquitetura geral | `knowledge/presentation/03-arquitetura-tecnica.md` | `architecture.md` | `documentation/` |
| Visão do produto e escopo | `knowledge/presentation/01-visao-geral.md`, `02-funcionalidades.md` | `prd.md` | `documentation/` |
| Decisões arquiteturais (ADRs) | `decisions/*.md` | `architecture.md` (seção de decisões) | `.agents/` |
| Navegação e telas | `knowledge/presentation/05-navegacao-telas.md`, `knowledge/analise-ui-ux.md` | `prd.md` §2.2 | Ambos (complementares) |
| Modelagem de dados | `knowledge/analise-modelagem.md`, `presentation/04-modelagem-dados.md` | `specs/g5-8-*.md` | `.agents/` |
| Padrão de commits | `workflows/commit.md` | `commit-pattern.md` | `documentation/` |
| Prompts e fluxos de trabalho | `workflows/*.md`, `skills/*/SKILL.md` | `prompts/*.md` | Ambos (complementares) |
| Specs de implementação | — | `specs/*.md` | `documentation/` |

## Quando Executar

Execute esta verificação quando:
1. Uma **mudança arquitetural** for feita (ex: unificação de apps, troca de stack)
2. Uma **spec nova** for criada em `documentation/specs/`
3. Uma **ADR** for registrada em `.agents/decisions/`
4. O usuário pedir explicitamente para sincronizar
5. Antes de um **PR** que toca documentação em qualquer um dos lados

## Como Executar

### Passo 1 — Detectar divergências

Para cada linha do Mapa de Sobreposição, leia os dois lados e responda:

1. **Existe contradição factual?** (ex: um lado diz "2 apps", outro diz "1 app")
2. **Existe informação ausente?** (ex: uma ADR foi criada mas não refletida na arquitetura)
3. **Existe informação desatualizada?** (ex: um diagrama ainda referencia uma entidade removida)

### Passo 2 — Classificar cada divergência

| Tipo | Ação |
|---|---|
| Contradição factual | 🔴 Corrigir imediatamente no lado que NÃO é fonte de verdade |
| Informação ausente | 🟡 Propagar da fonte de verdade para o outro lado |
| Informação desatualizada | 🟡 Atualizar no lado desatualizado |
| Diferença intencional de público | 🟢 Ignorar (cada lado pode ter nível de detalhe diferente) |

### Passo 3 — Aplicar correções

1. Comece pelo lado que é **fonte de verdade** — confirme que está correto.
2. Propague as mudanças para o outro lado, adaptando o nível de detalhe:
   - `documentation/` deve ser mais formal e orientada a requisitos
   - `.agents/` deve ser mais direta e orientada a execução por IA
3. Não duplique conteúdo desnecessariamente. Se um lado já cobre o assunto
   de forma completa, o outro pode apenas referenciar.

### Passo 4 — Relatório de Sync

Ao final, produza um resumo curto com:

```
## Sync Report

**Data:** YYYY-MM-DD
**Trigger:** [motivo da sincronização]

### Correções aplicadas
- [arquivo] — [o que mudou]

### Divergências intencionais (mantidas)
- [arquivo] — [motivo]

### Pendências (requerem decisão humana)
- [item] — [por que não foi resolvido automaticamente]
```

## Regras

- Nunca altere a fonte de verdade sem confirmação do usuário.
- O PRD (`documentation/prd.md`) é SEMPRE fonte de verdade para requisitos de
  negócio; a knowledge base deve derivar dele, não o contrário.
- ADRs em `.agents/decisions/` são SEMPRE fonte de verdade para decisões técnicas;
  `architecture.md` deve refletir, não substituir.
- Specs em `documentation/specs/` são SEMPRE fonte de verdade para escopo de tasks.
- Quando em dúvida sobre a fonte de verdade, pergunte ao usuário antes de alterar.
- Mantenha os diagramas (Mermaid/ASCII) em **ambos os lados** quando existirem,
  pois cada audiência depende deles no seu contexto.
- Se uma skill ou workflow em `.agents/` tem um prompt equivalente em
  `documentation/prompts/`, ambos devem ter o mesmo template/estrutura base.

## Checklist Rápido de Sync

Use este checklist para auditorias rápidas:

- [ ] PRD e knowledge/presentation descrevem o mesmo escopo de produto?
- [ ] `architecture.md` e `presentation/03-arquitetura-tecnica.md` têm o mesmo diagrama?
- [ ] ADRs em `.agents/decisions/` estão refletidas em `architecture.md`?
- [ ] Specs em `documentation/specs/` mencionam entidades que existem na modelagem?
- [ ] `commit-pattern.md` e `workflows/commit.md` descrevem o mesmo padrão?
- [ ] Prompts e skills que fazem a mesma coisa usam o mesmo template?
- [ ] Não há referências a "dois apps" ou arquitetura obsoleta em nenhum lado?
