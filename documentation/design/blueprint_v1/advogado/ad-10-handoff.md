# Tela: AD-10 - Handoff / Suporte Humano (Advogado)

- **Tipo**: [Stack] Chat Ativo
- **Atalho**: `@advogado-handoff`

## 🧭 Navegação (Stack)
- **Origem**: Push Notification ou Dashboard.
- **Fluxo**: Quando o usuário solicita ajuda humana ou a IA falha.

## 🏗️ Anatomia Visual
- **Chat Window**: Histórico completo da conversa da IA antes da intervenção.
- **Switch**: Botão para silenciar o bot permanentemente.
- **Chat Input**: Habilitado para o advogado escrever.

## 📊 Mapeamento de Dados (G5-8)
- `Chat.handoffAtivo`: Flag de controle.
- `Mensagem`: Inserção de novas mensagens com origin `HUMANO`.
