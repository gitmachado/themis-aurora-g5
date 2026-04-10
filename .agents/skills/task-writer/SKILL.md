---
name: task-writer
description: Criar e refinar tasks/issues no Linear seguindo as melhores práticas do OmniConnect. Use sempre que o usuário pedir para criar uma nova task, refinar uma existente, padronizar tarefas do backlog, ou transformar um requisito do PRD em uma issue acionável no Linear. Também use quando o usuário mencionar "criar issue", "escrever task", "padronizar tasks", ou "melhorar descrição de ticket".
---

# Task Writer — Criação e Refinamento de Issues no Linear

Skill para criar e refinar issues no Linear do projeto OmniConnect, garantindo
que cada task seja clara, acionável, rastreável e alinhada com a documentação do
repositório.

## Filosofia

Issues boas seguem 4 princípios:

1. **Diretas**: Descrevem o que precisa ser feito sem burocracia desnecessária.
2. **Contextualizadas**: Linkam para os documentos do repositório que explicam o porquê.
3. **Testáveis**: Critérios de aceite são verificáveis por qualquer pessoa ou CI.
4. **Rastreáveis**: Conectam-se a specs, branches e dependências.

Evite o "cargo cult" de User Stories rígidas. Prefira linguagem direta e
objetiva. A User Story clássica ("Como X, quero Y, para Z") só deve ser usada
quando realmente adicionar clareza — não por obrigação.

## Template Obrigatório

Toda issue criada ou refinada deve seguir este formato Markdown como descrição
no Linear. Seções marcadas com `(se aplicável)` podem ser omitidas quando não
houver conteúdo relevante.

```markdown
## 🎯 Objetivo

[1-3 frases descrevendo o valor de negócio ou técnico da entrega. Responda:
"O que estamos construindo e por que isso importa?"]

## 📖 Contexto

[Breve explicação do problema ou da necessidade. Inclua decisões anteriores
relevantes.]

**Referências do repositório:**
- PRD: `documentation/prd.md` §[seção] ([descrição])
- Arquitetura: `documentation/architecture.md` ([diagrama/seção])
- Spec: `documentation/specs/[arquivo]` (se existir)
- ADR: [referência] (se aplicável)

## 📋 Escopo

### In Scope
- [ ] Entregável 1 — com caminho de arquivo quando aplicável
- [ ] Entregável 2

### Out of Scope
- Item A — [motivo breve de exclusão]
- Item B

## ✅ Critérios de Aceite

1. [Critério testável e mensurável — evite termos vagos]
2. [Critério com resultado verificável]
3. [Máximo 5-6 critérios; se precisar de mais, divida a task]

## 🔧 Restrições Técnicas

- [Padrões obrigatórios: tecnologias, patterns, convenções]
- Branch: `feat/G5-XX-nome-descritivo`
- Commit pattern: `🌟feat: G5-XX descrição` (Conventional Commits em PT-BR)

## 🔗 Dependências (se aplicável)

| Depende de | Status |
|---|---|
| G5-XX (Nome) | Status atual |

## ⚠️ Riscos (se aplicável)

- [Risco técnico ou de negócio identificado]
```

## Como Executar

### Criar uma task nova

1. Leia as referências obrigatórias do projeto:
   - `documentation/prd.md`
   - `documentation/architecture.md`
   - `documentation/requisitos.md`

2. Identifique o escopo da entrega a partir da conversa com o usuário ou do PRD.

3. Preencha o template acima garantindo:
   - **Objetivo** responde "o que" e "por que"
   - **Contexto** explica "de onde veio" a necessidade
   - **Referências** usam caminhos reais do repositório
   - **Critérios de Aceite** são verificáveis (não usam palavras vagas como
     "rápido", "simples", "user-friendly")
   - **Restrições** incluem branch e commit pattern do projeto

4. Defina o título seguindo o padrão: `[Área] Descrição concisa da entrega`
   - Áreas válidas: `[BE]`, `[FE-Core]`, `[FE-Feature]`, `[Infra]`, `[DevOps]`,
     `[AI]`, `[Docs]`, `[QA]`

5. Crie a issue no Linear via `save_issue` com team `OmniConnect-G5`.

### Refinar uma task existente

1. Leia a issue atual via `get_issue`.
2. Compare a descrição com o template acima.
3. Identifique gaps: falta de referências? critérios vagos? sem escopo definido?
4. Reescreva mantendo o conteúdo original relevante, mas ajustando para o padrão.
5. Atualize via `save_issue` com o `id` da issue.

## Regras

- Não crie tasks que não derivem de uma necessidade real (PRD, spec ou conversa).
- Use caminhos reais do repositório nas referências (ex: `documentation/specs/...`).
- Máximo de 5-6 critérios de aceite por task. Se precisar de mais, sugira dividir.
- Critérios de aceite devem ser testáveis por CI ou por revisão humana objetiva.
- Tasks de documentação também seguem este template.
- O título no Linear sempre usa o formato `[Área] Verbo + Objeto`.
- Se a task depender de outra, registre na seção de Dependências com o status atual.
- Se houver risco técnico, registre na seção de Riscos — nunca enterre riscos no meio
  do texto.

## Exemplos

### Título bom vs ruim

| ❌ Ruim | ✅ Bom |
|---|---|
| Setup do backend | [BE] Modelagem de dados e definição do banco (S/ ORM) |
| Fazer o app | [FE-Core] Setup inicial Flutter e Arquitetura Unificada |
| Docker | [Infra] Containerização do ambiente local com Docker Compose |
| Testes | [QA] Cobertura de testes unitários para services do backend |

### Critério de Aceite bom vs ruim

| ❌ Ruim | ✅ Bom |
|---|---|
| App deve ser rápido | Tempo de cold start do app < 3 segundos em device físico |
| Backend funciona | `npm test` passa com 0 falhas e coverage > 80% |
| Documentação ok | Arquivo `documentation/specs/g5-X.md` criado seguindo template |
