# Tela: Suporte Humano (Handoff)

- **Localização**: [Stack] A partir de Notificações ou Dashboard.
- **Objetivo**: Assumir a conversa do WhatsApp quando o cliente pede ajuda ou a IA falha.

## 🏗️ Blueprint Visual
- **Corpo**:
  - Chat Ativo (Input habilitado para o advogado).
  - Banner: "Você assumiu esta conversa. O Bot está em pausa."
  - Histórico anterior (com cores diferentes para o que foi IA e o que é Humano/Cliente).

## 📊 Mapeamento de Dados (`feat/G5-8`)
| UI Component | Model Field | Display Rule |
| :--- | :--- | :--- |
| Mensagens | `Message[]` | Todas as mensagens vinculadas ao `leadId` ou `userId`. |
| Origem | `Message.sender` | Diferenciar visualmente: `BOT` (IA), `CLIENT` (Cliente), `LAWYER` (Você). |

## 🕹️ Ações
- **Intervir**: Desativa o Bot para este lead e assume o chat manual.
- **Encerrar Suporte**: Devolve o controle para o Bot.
- **Converter para Lead/Processo**: Atalho rápido se a conversa gerar novo negócio.

## 💡 Sugestões do Gemini
- **Chat Bubbles**: Balões arredondados com cores distintas para Cliente e Advogado.
- **Input Field**: Barra de texto com atalho para anexar documentos.
