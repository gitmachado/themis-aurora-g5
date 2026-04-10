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
- O branch base padrao dos PRs deve ser `development`, nao `main`.
- So use `main` como base se o usuario pedir explicitamente ou se houver uma
  excecao documentada no fluxo do repositorio.
- Se o usuario pedir para abrir o PR, use `gh` apenas se o repositorio remoto
  estiver configurado e a branch ja tiver sido enviada.
- Ao abrir o PR com `gh`, especifique explicitamente `--base development`, salvo
  quando houver excecao justificada.
- Se faltarem dados para abrir o PR, gere o titulo e o body prontos para uso.

## Título

Formato:

```text
[TIC-45] Descreve a entrega em PT-BR
```

## Corpo sugerido

```md
## 📝 Resumo
[Breve descrição do objetivo deste PR]

## 🚀 Mudanças
- [ ] [Item alterado 1]
- [ ] [Item alterado 2]

## ✅ Verificação
- [x] [Validação realizada]
- [x] [Link para walkthrough ou screenshots]

## 🔗 Links e Contexto
- Relacionado à: [ID da Task ou Issue]
```

## Saida esperada

- Titulo final
- Body final
- Base branch utilizada no PR
- Comando `gh pr create` usado, se o PR for aberto de fato
- URL do PR, se a criacao for bem-sucedida
