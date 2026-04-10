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
| UI Component | Model Field | Display Rule |
| :--- | :--- | :--- |
| Header Título | `LegalProcess.title` | - |
| Data Evento | `TimelineEvent.createdAt` | Formato: DD/MM/AAAA às HH:mm. |
| Conteúdo da Nota | `TimelineEvent.content` | Renderizar como **Markdown** (permite negrito, links e listas). |
| Tipo de Ícone | `TimelineEvent.type` | Mapear conforme `TimelineEventType` (ex: STATUS_UPDATE, LAWYER_NOTE). |

## 🕹️ Ações
- **Compartilhar**: Gerar um PDF resumido da timeline (Opcional).
- **Dúvida sobre este evento**: Botão que leva ao WhatsApp pré-preenchido com o ID do processo.
- **Entender melhor**: IA explica o status atual do processo.

## 💡 Sugestões do Gemini
- **Iconography**: Ícones amigáveis para eventos (ex: 💰 para honorários, 🔨 para decisão).
- **Share Button**: Botão de exportação/compartilhamento no topo da tela.
