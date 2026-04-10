# Tela: AD-02 - Triagem de Leads (Advogado)

- **Tipo**: [Tab Bar] Aba 2
- **Atalho**: `@advogado-leads`

## 🧭 Navegação (Stack)
- **Origem**: Tab Bar ou Dashboard.
- **Destinos possíveis**:
    - [AD-03: Detalhe do Lead](ad-03-detalhe-lead.md) (Ao selecionar um lead para análise).

## 🏗️ Anatomia Visual
- **Lista de Fila**: Cards com nome do lead, tipo de caso e urgência (IA).
- **Filtros**: "Mais Recentes", "Alta Urgência".

## 📊 Mapeamento de Dados (G5-8)
- `Lead[]`: Lista onde `status == PENDENTE`.
- `Lead.urgencia`: Badge colorida.
