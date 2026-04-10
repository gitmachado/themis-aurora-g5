# Tela: Suporte Humano (Handoff)

- **Localização**: [Stack] A partir de Notificações ou Dashboard.
- **Objetivo**: Assumir a conversa do WhatsApp quando o cliente pede ajuda ou a IA falha.

## 🏗️ Blueprint Visual
- **Corpo**:
  - Chat Ativo (Input habilitado).
  - Banner: "Você assumiu esta conversa. O Bot está em pausa."
  - Histórico anterior (com cores diferentes para o que foi IA e o que é Humano).

## 📊 Mapeamento de Dados (`feat/G5-8`)
| Componente | Campo do Modelo | Regra de Exibição |
| :--- | :--- | :--- |
| Mensagens | `Mensagem[]` | Todas as mensagens vinculadas ao chatId. |
| Metadata | `Mensagem.metadata.isAI` | Diferenciar visualmente respostas automáticas. |

## 🕹️ Ações
- **Encerrar Suporte**: Devolve o controle para o Bot.
- **Converter para Lead/Processo**: Atalho rápido se a conversa gerar novo negócio.
