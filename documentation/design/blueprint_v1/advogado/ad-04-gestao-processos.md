# Tela: AD-04 - Gestão de Processos (Advogado)

- **Tipo**: [Tab Bar] Aba 3
- **Atalho**: `@advogado-processos`

## 🧭 Navegação (Stack)
- **Destinos possíveis**:
    - [AD-05: Detalhe do Processo](ad-05-detalhe-processo.md) (Ao selecionar na lista)
    - [AD-06: Novo Processo](ad-06-novo-processo.md) (Através do botão FAB)

## 🏗️ Anatomia Visual
- **Search Header**: Filtro por nome, CPF ou número do processo.
- **Scroll Horizontal**: Filtros de nicho (Civil, Penal, etc).
- **Lista Global**: Processos ordenados por atualização recente.

## 📊 Mapeamento de Dados (G5-8)
- `Processo[]`: Todos os processos ativos no sistema.
- `Processo.tipoCaso`: Determina o ícone/categoria.
