---
description: Gerar e executar commits reais seguindo o padrao do projeto com ticket do Linear.
---

# Prompt: Commitar Codigo

## Objetivo

Criar e executar commits reais no repositorio usando o padrao definido em
`documentation/commit-pattern.md`.

## Regras obrigatorias

- Nao apenas sugira a mensagem: execute `git add` e `git commit`.
- Agrupe mudancas por responsabilidade. Se houver alteracoes independentes,
  crie mais de um commit.
- A mensagem deve seguir exatamente este formato:

```text
<emoji><tipo>: <LINEAR-ID> <descricao>
```

Exemplo:

```text
🌟feat: TIC-45 create auth routes
```

## Ticket do Linear

Antes de commitar, valide se existe um ticket Linear.

1. Se o usuario informar o ticket, use-o.
2. Se o usuario nao informar, tente inferir do nome da branch com:

```bash
git branch --show-current
```

3. Considere valido qualquer ID no formato `<PREFIXO>-<numero>`, como
`TIC-45`, `ENG-12` ou `MOB-7`.
4. Se nao for possivel identificar um ticket, interrompa com:

```text
ERROR: Missing Linear ticket id (expected format: ABC-123).
```

## Fluxo de execucao

1. Rode `git status --porcelain`.
   - Se nao houver mudancas, responda `No changes to commit`.
2. Analise diff e caminhos alterados.
3. Agrupe por responsabilidade.
4. Para cada grupo, execute:

```bash
git add <arquivos>
git commit -m "<emoji><tipo>: <LINEAR-ID> <descricao>"
```

## Tipos e emojis

Use os tipos descritos em `documentation/commit-pattern.md`.

- `🌟feat`
- `🐛fix`
- `📝docs`
- `🎨style`
- `♻️refactor`
- `⚡perf`
- `✅test`
- `🔧chore`
- `🚀ci`
- `📦build`
- `⏪revert`

## Saida esperada

Mostre objetivamente:

- os comandos executados
- os commits criados
- se sobrou algo sem commit e por qual motivo
