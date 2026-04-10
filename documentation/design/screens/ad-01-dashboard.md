# Tela: Dashboard Admin (Advogado)

- **Localização**: [Tab Bar] Aba 1
- **Objetivo**: Gestão operacional e métricas de produtividade.

## 🏗️ Blueprint Visual
- **Topo**: Métricas em cards pequenos (Total Processos, Leads Hoje, Handoffs).
- **Centro**: Gráfico de distribuição de casos por nicho (Tipo de Caso).
- **Lista Rápida**: Últimos 3 leads que chegaram hoje.

## 📊 Mapeamento de Dados (`feat/G5-8`)
| Componente | Campo do Modelo | Regra de Exibição |
| :--- | :--- | :--- |
| Contador | `Processo.count` | Total de processos ativos. |
| Contador Leads | `Lead.count` | Mostrar apenas status `PENDENTE`. |
| Gráfico | `Processo.tipoCaso` | Contar ocorrências de cada enum. |

## 🕹️ Ações
- **Clique na Métrica**: Filtra as listas correspondentes.
- **Handoff Urgente**: Botão "Assumir Conversa" direto do card.
