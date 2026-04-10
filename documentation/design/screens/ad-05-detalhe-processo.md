# Tela: Detalhe do Processo (Visão Advogado)

- **Localização**: [Stack] A partir de Gestão de Processos.
- **Objetivo**: Gerenciar a timeline e informações de um caso.

## 🏗️ Blueprint Visual
- **Topo**: Resumo do Processo.
- **Corpo**:
  - Aba "Timeline": Mesma visão do cliente + Botão "Adicionar Nota".
  - Aba "Documentos": Visualização de todos os anexos desse processo.

## 📊 Mapeamento de Dados (`feat/G5-8`)
| Componente | Campo do Modelo | Regra de Exibição |
| :--- | :--- | :--- |
| Detalhes | `Processo.descricao` | - |
| Ultima Nota | `Processo.ultimaNota` | - |
| Timeline | `TimelineEvento[]` | Relacionado ao processoId. |

## 🕹️ Ações
- **Atualizar Status**: Mudar `statusAtual`.
- **Nova Nota**: Abre modal/stack para criar `TimelineEvento`.
