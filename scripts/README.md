# Scripts

## `sync-agent-prompts.sh`

Sincroniza os arquivos de `documentation/prompts/` para os diretórios usados
pelos agentes configurados no projeto.

### Agentes cobertos

- Cursor: `.cursor/commands/*.md`
- OpenCode: `.opencode/commands/*.md`
- Claude Code: `.claude/commands/*.md`
- Codex: `.codex/prompts/*.md`
- Antigravity: `.agent/workflows/*.md`
- GitHub Copilot: `.github/prompts/*.prompt.md`

### Uso

```bash
bash scripts/sync-agent-prompts.sh
```

Opcionalmente, você pode informar outro diretório de origem:

```bash
bash scripts/sync-agent-prompts.sh documentation/prompts
```

### Comportamento

- ignora `README.md`
- remove o sufixo `-prompt` do nome final do comando
- copia o conteúdo de cada prompt para cada pasta de agente
- sobrescreve arquivos antigos gerados anteriormente
