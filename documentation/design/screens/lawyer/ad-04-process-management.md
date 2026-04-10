# Tela: Gestão de Processos (Escritório)

- **Localização**: [Tab Bar] Aba 3
- **Objetivo**: Centralizar todos os casos ativos do escritório.

## 🏗️ Blueprint Visual
- **Topo**: Busca global (Cliente, Nº Processo, Título).
- **Corpo**: Lista densa (formato tabela ou card compacto).
- **FAB**: Botão "+" para [Novo Processo](ad-06-new-process.md).

## 📊 Mapeamento de Dados (`feat/G5-8`)
| UI Component | Model Field | Display Rule |
| :--- | :--- | :--- |
| Cliente | `LegalProcess.clientId` -> `User.name` | Nome do cliente associado. |
| Nº Processo | `LegalProcess.processNumber` | - |
| Status | `LegalProcess.currentStatus` | - |

## 🕹️ Ações
- **Editar**: Abre [Painel do Processo](ad-05-process-detail.md).
- **Filtro**: Status, Responsável, Nicho.

## 💡 Sugestões do Gemini
- **Barra de Busca**: Campo de pesquisa com ícone de lupa fixo no topo.
- **Avatar/Ícone de Nicho**: Ícone representativo ao lado de cada processo na lista.
- **Status Pills**: Balões coloridos para identificar o status atual do processo.
