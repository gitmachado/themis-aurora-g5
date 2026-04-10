# Tela: Meus Processos (Lista)

- **Localização**: [Tab Bar] Aba 2
- **Objetivo**: Listar todos os processos vinculados ao cliente de forma organizada.

## 🏗️ Blueprint Visual
- **Topo**: Título "Meus Processos" e busca por texto.
- **Corpo**: 
  - Lista de cards verticais.
  - Cada card possui um ícone lateral que muda conforme o `caseType`.
  - Badge colorido no canto superior direito para o `currentStatus`.

## 📊 Mapeamento de Dados (`feat/G5-8`)
| UI Component | Model Field | Display Rule |
| :--- | :--- | :--- |
| Título do Processo | `LegalProcess.title` | Texto em Negrito (H2). |
| Número | `LegalProcess.processNumber` | Texto em cinza (Caption). Formato: 0000000-00... |
| Status | `LegalProcess.currentStatus` | Mapear cores do design guide conform o Enum. |
| Ícone | `LegalProcess.caseType` | Ícones sugeridos: ⚖️ (Civil), 🤝 (Family), 👷 (Labor). |

## 🕹️ Ações
- **Clique no Item**: Detalhe do processo [Minha Timeline](cl-03-process-timeline.md).

## 💡 Sugestões do Gemini
- **Progress ProgressBar**: Pequena barra de progresso no card mostrando o avanço do caso.
- **Large Icons**: Ícones grandes para facilitar a identificação visual do tipo de caso.
- **Pull-to-refresh**: Atualizar lista via API.
