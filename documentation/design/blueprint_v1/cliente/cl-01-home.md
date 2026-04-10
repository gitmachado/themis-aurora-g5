# Tela: CL-01 - Home / Dashboard (Cliente)

- **Tipo**: [Tab Bar] Aba 1
- **Atalho**: `@cliente-home`

## 🧭 Navegação (Stack)
- **Origem**: Splash/Login
- **Destinos possíveis**:
    - [CL-05: Timeline Detalhada](cl-05-timeline.md) (Ao clicar no status card)
    - [CL-06: Notificações](cl-06-notificacoes.md) (Ao clicar no ícone de sino)
    - [WhatsApp Externo]: Botão "Falar com Advogado"

## 🏗️ Anatomia Visual
- **Header**: Saudação personalizada e seletor de perfil.
- **Hero Card**: Status do processo mais recente com barra de progresso.
- **Grid de Atalhos**: Contato Rápido, Meus Documentos, Consultar IA.

## 📊 Mapeamento de Dados (G5-8)
- `User.nome`: Saudação.
- `Processo.status`: Texto e estado da barra no Hero Card.
- `TimelineEvento.findLatest()`: Preview do último evento.
