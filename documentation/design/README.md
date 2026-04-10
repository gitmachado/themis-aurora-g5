# Design System & Identidade Visual - OmniConnect

Este documento define as regras globais de design para garantir consistência em todas as telas do aplicativo único.

## 🎨 Paleta de Cores
Foco em profissionalismo jurídico e conformidade **WCAG AA**.

| Cor | Hex | Uso Sugerido |
| :--- | :--- | :--- |
| **Primary (Imperial Blue)** | `#1A237E` | App Bars, Botões Primários, Ícones de Tab Bar Ativos. |
| **Secondary (Antique Gold)** | `#C5A059` | Destaques, Badges de Urgência Alta, Ícones de Processo. |
| **Surface (Ghost White)** | `#F8F9FA` | Cor de fundo predominante. |
| **Error (Crimson)** | `#C62828` | Alertas críticos, Status de Prazo Vencido. |
| **Success (Forest Green)** | `#2E7D32` | Concluídos, Uploads de Sucesso. |

## Typography
- **Fonte:** `Inter` (ou Roboto como fallback).
- `H1`: Bold, 24px - Títulos de Tela.
- `H2`: Semi-Bold, 18px - Títulos de Cards.
- `Body`: Regular, 16px - Texto corrido e inputs.
- `Caption`: Light, 12px - Metadados e datas.

## 🛠️ Componentes Globais
1.  **Cards**: Bordas arredondadas `8px`, sombra `elevation 1`.
2.  **Buttons**: Altura mínima `48px`, border-radius `4px`.
3.  **Badges**: Usados para `StatusProcesso` e `TipoCaso`.
4.  **Skeletons**: Layouts de placeholders cinza pulsante para carregamento.

## 📁 Documentações Relacionadas
- [Navegação & Fluxos](../navigation.md)
- [Inventário de Telas](screens/README.md)
