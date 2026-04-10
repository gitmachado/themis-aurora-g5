# Tela: AD-01 - Dashboard Admin (Advogado)

- **Tipo**: [Tab Bar] Aba 1
- **Atalho**: `@advogado-dash`

## 🧭 Navegação (Stack)
- **Origem**: Login
- **Destinos possíveis**:
    - [AD-02: Triagem de Leads](ad-02-triagem-leads.md) (Ao clicar no contador de leads)
    - [AD-03: Detalhe do Lead](ad-03-detalhe-lead.md) (Ao clicar em um lead recente no feed)

## 🏗️ Anatomia Visual
- **Metric Cards**: Leads Pendentes, Casos Ativos, Handoffs Necessários.
- **Quick Feed**: Lista dos últimos 3 leads capturados.
- **Gráfico**: Casos por Especialidade.

## 📊 Mapeamento de Dados (G5-8)
- `Lead.count(PENDENTE)`: Métrica de leads.
- `Processo.groupBy(tipoCaso)`: Alimentação do gráfico.
