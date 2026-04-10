# Tela: Home (Dashboard Cliente)

- **Localização**: [Tab Bar] Aba 1
- **Objetivo**: Fornecer um resumo rápido da situação jurídica e atalhos para os serviços do bot.

## 🏗️ Blueprint Visual
- **Topo (AppBar)**: Avatar do usuário, saudação "Olá, [Nome]" e ícone de **Sininho** (Notificações) com badge numérico.
- **Corpo**:
  - **Card de Destaque**: "Seu processo teve uma atualização hoje!" (Visível se houver `TimelineEvent` recente).
  - **Acesso Rápido**: Botão flutuante ou Card proeminente para "Dúvida Rápida com IA (Chatbot)".
  - **Bottom Info**: Pequeno card com o status do último documento enviado.

## 📊 Mapeamento de Dados (`feat/G5-8`)
| UI Component | Model Field | Display Rule |
| :--- | :--- | :--- |
| Saudação | `User.name` | Pegar primeiro nome. |
| Badge Notificação | `Notification.isRead` | Contar registros onde `isRead == false`. |
| Card de Destaque | `LegalProcess.title` | Título do processo com movimentação mais recente. |
| Resumo Status | `LegalProcess.currentStatus` | Exibir em formato de texto amigável. |

## 🕹️ Ações
- **Clique no Sininho**: Navegar para [Notificações](cl-04-notifications.md).
- **Clique no Bot**: Navegar para [Chatbot IA](cl-06-chat-mirror.md).
- **Clique no Processo**: Navegar para [Timeline](cl-03-process-timeline.md).

## 💡 Sugestões do Gemini
- **Greeting Banner**: Saudação personalizada com avatar em destaque.
- **Hero Card**: "Status do seu Processo" como elemento principal acima da dobra.
- **Bot FAB**: Botão redondo flutuante com ícone de robô para iniciar chat.
