# Tela: Central de Notificações

- **Localização**: [Stack] Acessada pelo header da Home.
- **Objetivo**: Listar alertas e notificações de sistema para o cliente.

## 🏗️ Blueprint Visual
- **Header**: Título "Notificações" e botão "Limpar Tudo".
- **Corpo**: Lista de itens com ícones de indicação de tipo. Itens não lidos devem ter um fundo levemente colorido.

## 📊 Mapeamento de Dados (`feat/G5-8`)
| UI Component | Model Field | Display Rule |
| :--- | :--- | :--- |
| Título | `Notification.title` | Título curto do alerta. |
| Descrição | `Notification.body` | Texto explicativo da notificação. |
| Tempo | `Notification.createdAt` | Exibir tempo relativo (ex: "há 5 min"). |
| Estado Lida | `Notification.isRead` | Se `false`, exibir indicador visual (ponto azul). |

## 🕹️ Ações
- **Abrir Notificação**: Leva ao Processo ou Chat.

## 💡 Sugestões do Gemini
- **Unread Indicator**: Ponto colorido em notificações novas.
- **Swipe-to-Dismiss**: Gesto visual para excluir ou arquivar notificações.
