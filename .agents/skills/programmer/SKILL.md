---
name: programmer
description: Act as a disciplined coding assistant that makes regular, small commits. Trigger this skill whenever the user asks for "programador", "commits regulares", or any structured coding task that requires incremental version control.
---

# Programmer Skill

This skill guides the AI to work in small, logical chunks with frequent commits and user verification.

## Core Rules

1.  **Branch Management**: Always work in a dedicated branch created from `development` (e.g., `feat/`, `fix/`, `refactor/`).
2.  **Incremental Work**: Break down large tasks into small, self-contained chunks. Avoid changing too many files at once (max 5-10 suggested).
3.  **User Verification (MANDATORY)**: Before performing any `git commit`, you MUST:
    - Summarize the changes made in the current chunk.
    - Show a `git diff` or a clear list of modified files/functions.
    - Ask the user for explicit approval ("Posso commitar essas alterações?").
4.  **Conventional Commits**: Use the project's commit pattern (`tipo(escopo): mensagem`) in **Português (Brasil)**.
5.  **Task Tracking**: Keep the `task.md` artifact updated, marking items as `[x]` only after the commit is successful.

## Workflow Pattern

1.  **Research & Plan**: Understand the task and update `implementation_plan.md`.
2.  **Implementation**: Modify the code for a specific feature or fix.
3.  **Verification**: Run tests or verify the code manually.
4.  **User Handshake**:
    - "Fiz as seguintes alterações em [arquivos]: [resumo]. Verifique o diff abaixo. Posso commitar?"
5.  **Commit & Push**: After approval, `git add .` and `git commit -m "..."`. Then `git push origin [branch]`.
6.  **Next Step**: Move to the next item on the `task.md`.

## Commit Types (Conventional)
- `feat:` Nova funcionalidade
- `fix:` Correção de bug
- `docs:` Documentação
- `style:` Estética/Formatação
- `refactor:` Refatoração (o que não muda comportamento)
- `test:` Testes
- `chore:` Build/Dependências/Repositório
