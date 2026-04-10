# Tela: AD-05 - Detalhe do Processo (Admin/Advogado)

- **Tipo**: [Stack] Gestão
- **Atalho**: `@advogado-processo-gestao`

## 🧭 Navegação (Stack)
- **Origem**: [AD-04: Gestão de Processos](ad-04-gestao-processos.md)
- **Ações Detalhadas**:
    - [AD-08: Revisão de Documentos](ad-08-revisao-documentos.md) (Se houver docs pendentes)
    - Editor de Timeline (Modal/Stack interna).

## 🏗️ Anatomia Visual
- **Dashboard do Caso**: Cards com status atual, data da próxima audiência e cliente.
- **Timeline Interativa**: Linha do tempo editável (Add/Edit/Delete eventos).
- **Grid de Documentos**: Visualização de arquivos vinculados.

## 📊 Mapeamento de Dados (G5-8)
- `TimelineEvento[]`: Coleção para edição.
- `Processo.status`: Campo para atualização de estado do caso.
