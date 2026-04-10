# Tela: Dashboard Admin (Advogado)

- **Localização**: [Tab Bar] Aba 1
- **Objetivo**: Gestão operacional e métricas de produtividade.

## 🏗️ Blueprint Visual
- **Topo**: Métricas em cards pequenos (Total Processos, Leads Hoje, Handoffs).
- **Centro**: Gráfico de distribuição de casos por nicho (Tipo de Caso).
- **Lista Rápida**: Últimos 3 leads que chegaram hoje.

## 📊 Mapeamento de Dados (`feat/G5-8`)
| UI Component | Model Field | Display Rule |
| :--- | :--- | :--- |
| Contador | `LegalProcess.count` | Total de processos ativos. |
| Contador Leads | `Lead.count` | Mostrar apenas status `PENDING`. |
| Gráfico | `LegalProcess.caseType` | Contar ocorrências de cada enum. |

## 🕹️ Ações
- **Clique na Métrica**: Filtra as listas correspondentes.
- **Handoff Urgente**: Botão "Assumir Conversa" direto do card.

## 💡 Sugestões do Gemini
- **Cards de Métricas**: Usar bordas coloridas ou sombreadas para destacar números (Total Processos, Leads).
- **Gráfico de Rosca**: Para visualização da distribuição de `caseType` (Cível, Trabalhista, etc).
- **Lista Compacta**: Card "Últimos Leads" com layout denso para visualização rápida.
