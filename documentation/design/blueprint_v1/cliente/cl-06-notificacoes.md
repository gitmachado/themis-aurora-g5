# Tela: CL-06 - Notificações (Cliente)

- **Tipo**: [Stack] Global
- **Atalho**: `@cliente-notificacoes`

## 🧭 Navegação (Stack)
- **Origem**: Ícone de sino em qualquer tela da Tab Bar.
- **Destinos possíveis**:
    - [CL-05: Timeline Detalhada](cl-05-timeline.md) (Deep Link ao clicar em atualização de processo).

## 🏗️ Anatomia Visual
- **Lista de Alertas**: Cards com ícones de categoria (Status, Documento, Mensagem).
- **Timestamp**: Tempo relativo (ex: "Há 12 minutos").

## 📊 Mapeamento de Dados (G5-8)
- `Notificacao[]`: Filtradas por `userId`.
- `Notificacao.lida`: Diferencia visual de background (bold/normal).
