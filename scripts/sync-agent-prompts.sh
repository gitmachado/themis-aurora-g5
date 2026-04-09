#!/usr/bin/env bash
set -euo pipefail

PROMPTS_DIR="${1:-documentation/prompts}"

# Diretórios-alvo por agente/ferramenta.
# Observações:
# - Cursor usa .cursor/commands/*.md
# - OpenCode usa .opencode/commands/*.md
# - Claude Code ainda aceita .claude/commands/*.md
# - GitHub Copilot usa .github/prompts/*.prompt.md
# - Antigravity foi mapeado para .agent/workflows/*.md para manter
#   compatibilidade com workflows em markdown
# - Codex recebe cópia em .codex/prompts/*.md por convenção local do projeto
TARGETS=(
  "cursor:.cursor/commands:md"
  "opencode:.opencode/commands:md"
  "claude:.claude/commands:md"
  "codex:.codex/prompts:md"
  "antigravity:.agent/workflows:md"
  "github-copilot:.github/prompts:prompt.md"
)

if [[ ! -d "$PROMPTS_DIR" ]]; then
  echo "Prompts directory not found: $PROMPTS_DIR"
  exit 1
fi

shopt -s nullglob
PROMPTS=( "$PROMPTS_DIR"/*.md )

if (( ${#PROMPTS[@]} == 0 )); then
  echo "No prompts found in '$PROMPTS_DIR/*.md'"
  exit 1
fi

slug_name() {
  local src_name="$1"
  local name="${src_name%.md}"

  if [[ "$name" == *-prompt ]]; then
    name="${name%-prompt}"
  fi

  echo "$name"
}

copy_prompt() {
  local src="$1"
  local dest="$2"

  rm -f "$dest"

  {
    echo "<!-- Auto-generated from $src -->"
    echo
    cat "$src"
  } > "$dest"

  echo "copied:  $dest <- $src"
}

for target in "${TARGETS[@]}"; do
  IFS=":" read -r _agent dir _ext <<< "$target"
  mkdir -p "$dir"
done

for src in "${PROMPTS[@]}"; do
  filename="$(basename "$src")"

  # README da pasta de prompts é documentação, não comando de agente.
  if [[ "$filename" == "README.md" ]]; then
    continue
  fi

  name="$(slug_name "$filename")"

  for target in "${TARGETS[@]}"; do
    IFS=":" read -r agent dir ext <<< "$target"
    dest="$dir/$name.$ext"
    copy_prompt "$src" "$dest"
  done
done

echo
echo "Done. Copied prompts from '$PROMPTS_DIR' to agent directories."
