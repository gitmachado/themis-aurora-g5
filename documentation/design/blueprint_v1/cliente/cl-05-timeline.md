# Tela: CL-05 - Timeline / Detalhe do Processo (Cliente)

- **Tipo**: [Stack] Detalhado
- **Atalho**: `@cliente-timeline`

## 🧭 Navegação (Stack)
- **Origem**: [CL-01: Home](cl-01-home.md) ou [CL-02: Lista de Processos](cl-02-lista-processos.md)
- **Fluxo**: Ao clicar em um processo específico.
- **Botão Voltar**: Retorna à tela de origem na Tab Bar.

## 🏗️ Anatomia Visual
- **Process Header**: Nome do caso e Status em destaque.
- **Vertical Timeline**: Lista de eventos com ícones temáticos.
- **Event Detail**: Card expansível com a nota do advogado (Markdown).

## 📊 Mapeamento de Dados (G5-8)
- `TimelineEvento[]`: Ordenados por data decrescente.
- `TimelineEvento.tipo`: Determina ícone (ex: `AUDIENCIA` -> 🔨).
- `TimelineEvento.nota`: Conteúdo textual explicativo.
