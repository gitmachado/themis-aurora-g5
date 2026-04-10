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
| Componente | Campo do Modelo | Regra de Exibição |
| :--- | :--- | :--- |
| Nome do Arquivo | `Documento.titulo` | - |
| Data | `Documento.createdAt` | - |
| Status do Doc | `Documento.status` (se existir) | "Enviado", "Aprovado", "Recusado". |
| Tamanho | `Documento.tamanho` | Formato KB/MB. |

## 🕹️ Ações
- **Upload**: Abre galeria/câmera do celular.
- **Preview**: Ao tocar na imagem para visualizar em tela cheia.
