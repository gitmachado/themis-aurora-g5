# Tela: CL-02 - Lista de Processos (Cliente)

- **Tipo**: [Tab Bar] Aba 2
- **Atalho**: `@cliente-processos`

## 🧭 Navegação (Stack)
- **Origem**: Tab Bar
- **Destinos possíveis**:
    - [CL-05: Timeline Detalhada](cl-05-timeline.md) (Ao selecionar um processo na lista)

## 🏗️ Anatomia Visual
- **Filtros**: Chips para "Ativos", "Arquivados" e "Todos".
- **Lista Vertical**: Cards de processo com Número CNJ, Status e data de atualização.

## 📊 Mapeamento de Dados (G5-8)
- `Processo[]`: Coleção filtrada por `userId`.
- `ProcessoStatus` (Enum): Define estilo visual dos cards.
