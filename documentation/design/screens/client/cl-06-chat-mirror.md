# Tela: Chat Espelhado (WhatsApp History)

- **Localização**: [Tab Bar] Aba 4 (ou via Home)
- **Objetivo**: Fornecer ao cliente o histórico da conversa que ele teve com o Bot no WhatsApp.

## 🏗️ Blueprint Visual
- **Interface**: Estilo chat tradicional (WhatsApp Clone).
- **Restrição**: Somente leitura no app (o chat principal é no WhatsApp).
- **Topo**: Nome da IA/Escritório e status (Online/Via Bot).

## 📊 Mapeamento de Dados (`feat/G5-8`)
| UI Component | Model Field | Display Rule |
| :--- | :--- | :--- |
| Texto | `Message.content` | Balões de chat. |
| Hora | `Message.createdAt` | Exibir dentro do balão. |
| Lado do balão | `Message.sender` | Se for `CLIENT` -> Direita. Se for `BOT`/`LAWYER` -> Esquerda. |

## 🕹️ Ações
- **Solicitar Humano**: Alerta o advogado para intervir.

## 💡 Sugestões do Gemini
- **Reading Mode Banner**: Faixa no topo indicando que o chat é apenas para leitura.
- **Classic Layout**: Layout estilo WhatsApp para familiaridade imediata.
