# Tela: Gestão de Documentos

- **Localização**: [Tab Bar] Aba 3
- **Objetivo**: Envio e consulta de documentos comprobatórios.

## 🏗️ Blueprint Visual
- **Topo**: Banner "Envie seus documentos com segurança".
- **Corpo**: 
  - Filtro por processo (Dropdown).
  - Galeria/Lista de arquivos enviados.
  - Botão de FAB (Floating Action Button) de "+" para upload.

## 📊 Mapeamento de Dados (`feat/G5-8`)
| UI Component | Model Field | Display Rule |
| :--- | :--- | :--- |
| Nome do Arquivo | `Document.fileName` | - |
| Data | `Document.createdAt` | - |
| Status do Doc | `Document.status` | "Enviado", "Aprovado", "Recusado" (Conforme lógica de backend). |
| Tamanho | `Document.sizeBytes` | Converter de bytes para KB/MB. |

## 🕹️ Ações
- **Upload (+)**: Abre camera ou galeria.

## 💡 Sugestões do Gemini
- **Thumbnail Grid**: Visualização das fotos dos documentos em grade de miniaturas.
- **Primary Upload FAB**: Botão central de "+" para carregar novos arquivos.
- **Preview**: Ao tocar na imagem para visualizar em tela cheia.
