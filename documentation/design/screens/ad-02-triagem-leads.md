# Tela: Triagem de Leads

- **Localização**: [Tab Bar] Aba 2
- **Objetivo**: Visualizar potenciais clientes qualificados pela IA.

## 🏗️ Blueprint Visual
- **Topo**: Filtros de Urgência e Tipo de Caso.
- **Corpo**: Lista de cards de Leads.
- **Destaque**: Urgência Alta deve ter borda Crimson ou badge pulsante.

## 📊 Mapeamento de Dados (`feat/G5-8`)
| Componente | Campo do Modelo | Regra de Exibição |
| :--- | :--- | :--- |
| Nome Lead | `Lead.nome` | Se não houver, mostrar o número do WhatsApp. |
| Telefone | `Lead.whatsappNumber` | - |
| Urgência | `Lead.urgencia` | Badge Colorido. |
| Nicho | `Lead.tipoCaso` | Ícone do ramo do direito. |

## 🕹️ Ações
- **Ver Detalhes**: Abre o [Detalhe do Lead](ad-03-detalhe-lead.md).
- **Arquivar**: Descartar lead irrelevante.
