# Tela: Gestão de Processos (Escritório)

- **Localização**: [Tab Bar] Aba 3
- **Objetivo**: Centralizar todos os casos ativos do escritório.

## 🏗️ Blueprint Visual
- **Topo**: Busca global (Cliente, Nº Processo, Título).
- **Corpo**: Lista densa (formato tabela ou card compacto).
- **FAB**: Botão "+" para [Novo Processo](ad-06-novo-processo.md).

## 📊 Mapeamento de Dados (`feat/G5-8`)
| Componente | Campo do Modelo | Regra de Exibição |
| :--- | :--- | :--- |
| Cliente | `Processo.clienteId` -> `User.nome` | Nome do cliente associado. |
| Nº Processo | `Processo.numeroProcesso` | - |
| Status | `Processo.statusAtual` | - |

## 🕹️ Ações
- **Editar**: Abre [Edição de Timeline](ad-05-detalhe-processo.md).
- **Filtro**: Status, Advogado Responsável, Nicho.
