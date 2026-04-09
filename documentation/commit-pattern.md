# Commit pattern

O padrão de commit do projeto segue esta estrutura:

```text
<emoji><tipo>: <TICKET> <descrição>
```

Formato esperado:

```text
🌟feat: TIC-45 create auth routes
```

Regras:

- O commit deve começar com um emoji.
- Depois do emoji vem o tipo do commit, sem espaço.
- Depois do tipo vem `:`.
- Depois de `:` vem um espaço.
- A descrição deve começar pelo ticket da tarefa no Linear.
- Depois do ticket vem um espaço e a descrição em inglês, objetiva e no imperativo quando fizer sentido.

Tipos e emojis recomendados:

- `🌟feat`: nova funcionalidade
- `🐛fix`: correção de bug
- `📝docs`: documentação
- `🎨style`: ajustes visuais ou de formatação
- `♻️refactor`: refatoração sem mudança funcional
- `⚡perf`: melhoria de performance
- `✅test`: criação ou ajuste de testes
- `🔧chore`: tarefa de manutenção
- `🚀ci`: integração ou entrega contínua
- `📦build`: build, dependências ou empacotamento
- `⏪revert`: reversão de commit

Exemplos válidos:

```text
🌟feat: TIC-45 create auth routes
🐛fix: TIC-52 handle token refresh race condition
📝docs: TIC-61 document authentication flow
🔧chore: TIC-70 update commit hooks
```
