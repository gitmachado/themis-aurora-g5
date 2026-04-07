---
description: "Padrão de uso do Git e criação de commits no projeto OmniConnect."
---
# Workflow de Controle de Versão (Git e Commits)

Este documento define as regras fundamentais do Grupo 5 para gerenciamento do código-fonte e histórico do **OmniConnect**.

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

## 🌍 Idioma Padronizado
1. **Commits e PRs**: Todas as mensagens de commit, títulos de Pull Requests e descrições no GitHub devem ser escritas obrigatoriamente em **Português (Brasil)**.
2. **Contexto**: Como a equipe é brasileira, isso garante clareza e agilidade na revisão de código entre os membros.

---
1. Faça a tarefa na sua branch `tipo/nome`.
2. Adicione os arquivos: `git add .`
3. Faça o commit padronizado: `git commit -m "feat: sua mensagem"`.
4. Envie para o repositório remoto: `git push origin tipo/nome`.
5. Abra um Pull Request (PR) caso aplicável para mergear na `development`.

> [!WARNING]
> O uso do padrão de commits garante que a geração de changelogs e a leitura pelos agentes de IA sejam eficientes. Evite commits genéricos como "ajustes finais" ou "commit".
