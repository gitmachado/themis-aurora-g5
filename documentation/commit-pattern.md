# Padrão de Commit

O projeto Themis segue o padrão **Conventional Commits** e exige que todas as mensagens de commit estejam em **Português (Brasil)**.

### Formato Base:

```text
<tipo>(<escopo-opcional>): <descrição em português no imperativo>
```

O uso de emojis e identificadores do Linear (TICKET) são **opcionais**, resultando no seguinte formato estendido:

```text
<emoji><tipo>(<escopo-opcional>): <TICKET> <descrição em português>
```

### Regras Principais:
1. **Idioma:** Todas as mensagens devem ser em Português para dar visibilidade rápida à equipe inteira.
2. **Clareza:** A descrição deve ser imperativa e objetiva (ex: "adiciona rota", em vez de "adicionando rota" ou "adicionei rota").
3. **Escopo:** Quando uma alteração for contida em uma camada específica, use o escopo para clareza (ex: `feat(mobile):` ou `fix(api):`).

### Tipos Comuns (com seus Emojis Opcionais):

- `feat` ou `🌟feat`: nova funcionalidade
- `fix` ou `🐛fix`: correção de bug
- `docs` ou `📝docs` / `🌟docs`: documentação
- `style` ou `🎨style`: ajustes visuais ou de formatação
- `refactor` ou `🏗️refactor` / `♻️refactor`: refatoração sem mudança funcional
- `test` ou `✅test`: criação ou ajuste de testes
- `chore` ou `🔧chore`: tarefa de manutenção e build

### Exemplos Válidos (baseados no histórico do repositório):

```text
feat(backend): implementa modelagem de dados, DTOs e interfaces
docs: atualiza distinção de audiências na skill docs-sync
🏗️refactor: versionar .agents/ e adicionar skills
🌟docs: unificação da arquitetura mobile para app único
```

---

# Branch pattern

O padrão de branch do projeto segue esta estrutura:

```text
<tipo>/G5-<número>-<descrição-curta>
```

Formato esperado:

```text
feat/G5-8-modelagem-dados-backend
```

Regras:

- A branch deve começar com o tipo (mesmos tipos do commit, sem emoji).
- Depois do tipo vem `/`.
- Depois da barra vem o ticket do Linear (`G5-XX`).
- Depois do ticket vem `-` e uma descrição curta em kebab-case.
- A descrição deve ser objetiva (2 a 5 palavras).

Tipos de branch recomendados:

- `feat/` — nova funcionalidade
- `fix/` — correção de bug
- `docs/` — documentação
- `refactor/` — refatoração
- `infra/` — infraestrutura e DevOps
- `test/` — testes
- `chore/` — manutenção geral

Exemplos válidos:

```text
feat/G5-6-setup-flutter-provider
feat/G5-8-modelagem-dados-backend
infra/G5-7-estudo-hospedagem
docs/G5-10-commit-lint-docs
```
