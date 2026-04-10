# Tela: Home (Dashboard Cliente)

- **Localização**: [Tab Bar] Aba 1
- **Objetivo**: Fornecer um resumo rápido da situação jurídica e atalhos para os serviços do bot.

## 🏗️ Blueprint Visual
- **Topo (AppBar)**: Avatar do usuário, saudação "Olá, [Nome]" e ícone de **Sininho** (Notificações) com badge numérico.
- **Corpo**:
  - **Card de Destaque**: "Seu processo teve uma atualização hoje!" (Visível se houver `TimelineEvento` recente).
  - **Acesso Rápido**: Botão flutuante ou Card proeminente para "Dúvida Rápida com IA (Chatbot)".
  - **Bottom Info**: Pequeno card com o status do último documento enviado.

## 📊 Mapeamento de Dados (`feat/G5-8`)
| Componente | Campo do Modelo | Regra de Exibição |
| :--- | :--- | :--- |
| Saudação | `User.nome` | Pegar primeiro nome. |
| Badge Notificação | `Notificacao.lida` | Contar registros onde `lida == false`. |
| Card de Destaque | `Processo.titulo` | Título do processo com movimentação mais recente. |
| Resumo Status | `Processo.statusAtual` | Exibir em formato de texto amigável. |

## 🕹️ Ações
- **Clique no Sininho**: Navegar para [Central de Notificações](cl-04-notificacoes.md).
- **Clique no Bot**: Navegar para [Chat Espelhado](cl-06-chat-espelhado.md).
- **Clique no Processo**: Navegar para [Timeline](cl-03-processo-timeline.md).
