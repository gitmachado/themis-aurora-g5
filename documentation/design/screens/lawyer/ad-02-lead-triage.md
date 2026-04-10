# Tela: Triagem de Leads

- **Localização**: [Tab Bar] Aba 2
- **Objetivo**: Visualizar potenciais clientes qualificados pela IA.

## 🏗️ Blueprint Visual
- **Topo**: Filtros de Urgência e Tipo de Caso.
- **Corpo**: Lista de cards de Leads.
- **Destaque**: Urgência Alta deve ter borda Crimson ou badge pulsante.

## 📊 Mapeamento de Dados (`feat/G5-8`)
| UI Component | Model Field | Display Rule |
| :--- | :--- | :--- |
| Nome Lead | `Lead.name` | Se não houver, mostrar o número do WhatsApp. |
| Telefone | `Lead.whatsappNumber` | - |
| Urgência | `Lead.urgency` | Badge Colorido. |
| Nicho | `Lead.caseType` | Ícone do ramo do direito. |

## 🕹️ Ações
- **Ver Detalhes**: Abre o [Detalhe do Lead](ad-03-lead-detail.md).
- **Arquivar**: Descartar lead irrelevante.

## 💡 Sugestões do Gemini
- **Botões de Ação Rápida**: Ícones de "Check" (Verde) e "X" (Cinza/Vermelho) em cada card de lead.
- **Badges de Urgência**: Etiquetas coloridas (Vermelho para High, Amarelo para Medium).
- **Filtros por Chips**: Botões arredondados no topo para filtrar por nicho.
