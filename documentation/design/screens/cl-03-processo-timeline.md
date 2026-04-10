# Tela: Detalhes do Processo (Timeline)

- **Localização**: [Stack] Navegação Interna a partir de Lista de Processos.
- **Objetivo**: Transparência sobre o histórico e movimentações de um caso específico.

## 🏗️ Blueprint Visual
- **Header**: Título do Processo e botão "Voltar".
- **Resumo**: Card fixo no topo com o Status Atual e data da última movimentação.
- **Corpo**: 
  - Timeline vertical com linha conectando os círculos (eventos).
  - Cada item da timeline é um "Evento".

## 📊 Mapeamento de Dados (`feat/G5-8`)
| Componente | Campo do Modelo | Regra de Exibição |
| :--- | :--- | :--- |
| Header Título | `Processo.titulo` | - |
| Data Evento | `TimelineEvento.createdAt` | Formato: DD/MM/AAAA às HH:mm. |
| Conteúdo da Nota | `TimelineEvento.conteudo` | Renderizar como **Markdown** (permite negrito, links e listas). |
| Tipo de Ícone | `TimelineEvento.tipo` | `AUDIENCIA` (calendário), `DESPACHO` (martelo), `PETICAO` (papel). |

## 🕹️ Ações
- **Compartilhar**: Gerar um PDF resumido da timeline (Opcional).
- **Dúvida sobre este evento**: Botão que leva ao WhatsApp pré-preenchido com o ID do processo.
