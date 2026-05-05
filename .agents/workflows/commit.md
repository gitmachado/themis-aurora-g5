---
description: "Padrão de uso do Git e criação de commits no projeto Themis."
---
# Workflow de Controle de Versão (Git e Commits)

Este documento define as regras fundamentais do Grupo 5 para gerenciamento do código-fonte e histórico do **Themis**.

## 📌 Regras de Branches (Ramificações)
1. **`main`**: É a branch de **Produção**. **NUNCA FAÇA COMMIT DIRETO NA MAIN.**
2. **`development`**: É a branch base de desenvolvimento. Todo código novo é integrado aqui antes de subir para produção.
3. **Branches Detalhadas (Feature/Bugfix)**: Sempre inicie novas tarefas criando uma branch a partir da `development`. 

### Como criar uma nova branch de tarefa:
Certifique-se de estar na `development` e atualizado antes de criar sua branch:
```bash
git checkout development
git pull origin development
git checkout -b tipo/nome-curto-da-tarefa
```
Exemplos válidos: `feat/login-flutter`, `fix/erro-webhook`, `docs/atualiza-adrs`.

---

## 📝 Conventional Commits
Ao realizar commits na sua branch detalhada, utilize o padrão "Conventional Commits" para manter o histórico claro:

### Estrutura:
`tipo(escopo-opcional): mensagem imperativa e direta`

### Tipos permitidos:
- **`feat:`** Adição de uma nova funcionalidade (ex: `feat(api): adiciona rota de webhook`).
- **`fix:`** Correção de um bug (ex: `fix(auth): resolve problema de login`).
- **`docs:`** Mudanças apenas na documentação (ex: `docs: adiciona readme`).
- **`style:`** Mudanças de formatação ou estilo de código, que não afetam a lógica.
- **`refactor:`** Refatoração de código que não adiciona feature nem corrige bug.
- **`test:`** Adição ou ajuste de testes.
- **`chore:`** Atualização de tarefas de build, pacotes, repositório (ex: `chore: atualiza pacotes npm`).

---

## 🌍 Idioma e Estrutura de PR
1. **Idioma**: Todas as mensagens de commit, títulos de Pull Requests e descrições no GitHub devem ser escritas obrigatoriamente em **Português (Brasil)**.
2. **Estrutura Obrigatória com Emojis**: Todo Pull Request deve seguir a estrutura abaixo para garantir clareza e padronização visual:

```markdown
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

3. **Contexto**: Como a equipe é brasileira e utiliza agentes de IA, o uso de emojis em cada seção facilita a separação visual de contextos e a navegação rápida.

---
1. Faça a tarefa na sua branch `tipo/nome`.
2. Adicione os arquivos: `git add .`
3. Faça o commit padronizado: `git commit -m "feat: sua mensagem"`.
4. Envie para o repositório remoto: `git push origin tipo/nome`.
5. Abra um Pull Request (PR) caso aplicável para mergear na `development`.
---

## 🛡️ Segurança e Permissões (Regra para IA)
> [!IMPORTANT]
> O Agente/IA **NUNCA** deve realizar comandos de `git push`, `git push --force` ou criar Pull Requests sem a autorização **explícita e única** do usuário para aquela operação específica. Mesmo que uma permissão tenha sido dada anteriormente, novas alterações que exijam envio para o GitHub devem ser validadas novamente.

---

## 🚦 Status da Task no Linear
Para manter a sincronia entre código e gestão de tarefas, siga estas regras:
1. **`In Progress`**: Enquanto estiver escrevendo o código.
2. **`In Review`**: Assim que o Pull Request for criado. **A task NÃO deve ir para `Done` aqui.**
3. **`Done`**: Somente **APÓS** o merge do PR ser aprovado e concluído na branch base.

---

## 🤖 Automação de Pull Request (gh cli)
Sempre que possível, utilize o GitHub CLI para criar PRs padronizados diretamente do terminal.

### Exemplo de Comando:
```bash
gh pr create --title "tipo(escopo): mensagem" --body "seu template aqui" --base development
```
Use o template definido na seção "Idioma e Estrutura de PR" deste documento para preencher o body.

> [!WARNING]
> O uso do padrão de commits e o status correto no Linear garante que a geração de changelogs e a leitura pelos agentes de IA sejam eficientes. Evite commits genéricos como "ajustes finais" ou "commit".
