# Tela: Chat Espelhado (WhatsApp History)

- **Localização**: [Tab Bar] Aba 4 (ou via Home)
- **Objetivo**: Fornecer ao cliente o histórico da conversa que ele teve com o Bot no WhatsApp.

## 🏗️ Blueprint Visual
- **Interface**: Estilo chat tradicional (WhatsApp Clone).
- **Restrição**: Somente leitura no app (o chat principal é no WhatsApp).
- **Topo**: Nome da IA/Escritório e status (Online/Via Bot).

## 📊 Mapeamento de Dados (`feat/G5-8`)
| Componente | Campo do Modelo | Regra de Exibição |
| :--- | :--- | :--- |
| Texto | `Mensagem.conteudo` | Balões de chat. |
| Hora | `Mensagem.createdAt` | Exibir dentro do balão. |
| Lado do balão | `Mensagem.remetente` | Se for Cliente -> Direita. Se for Bot/Advogado -> Esquerda. |

## 🕹️ Ações
- **Ir para WhatsApp**: Botão proeminente no footer "Precisa falar agora? Abra o WhatsApp".
