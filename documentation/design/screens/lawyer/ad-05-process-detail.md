# Tela: Detalhe do Processo (Visão Advogado)

- **Localização**: [Stack] A partir de Gestão de Processos.
- **Objetivo**: Gerenciar a timeline e informações de um caso.

## 🏗️ Blueprint Visual
- **Topo**: Resumo do Processo.
- **Corpo**:
  - Aba "Timeline": Mesma visão do cliente + Botão "Adicionar Nota".
  - Aba "Documentos": Visualização de todos os anexos desse processo.

## 📊 Mapeamento de Dados (`feat/G5-8`)
| UI Component | Model Field | Display Rule |
| :--- | :--- | :--- |
| Detalhes | `LegalProcess.description` | - |
| Ultima Nota | `LegalProcess.lastNote` | - |
| Timeline | `TimelineEvent[]` | Relacionado ao `processId`. |

## 🕹️ Ações
- **Atualizar Status**: Mudar `currentStatus`.
- **Nova Nota**: Abre modal/stack para criar `TimelineEvent`.

## 💡 Sugestões do Gemini
- **Top Tabs**: Abas para alternar entre "Resumo", "Timeline" e "Documentos".
- **Visual Timeline**: Linha vertical pontilhada conectando os eventos com ícones específicos.
- **Menu de Ações**: Botão de "Acesso Rápido" para adicionar nova nota ou movimentação.
