# Tela: Revisão de Documentos

- **Localização**: [Stack] A partir de Clientes ou Dashboard.
- **Objetivo**: Conferir arquivos enviados pelos clientes para dar andamento processual.

## 🏗️ Blueprint Visual
- **Corpo**:
  - Preview do arquivo (PDF ou Imagem).
  - Metadados: Quem mandou, Quando mandou, Qual processo.
  - Botões de decisão: "Aprovar" / "Recusar (Pedir novo)".

## 📊 Mapeamento de Dados (`feat/G5-8`)
| UI Component | Model Field | Display Rule |
| :--- | :--- | :--- |
| Arquivo | `Document.fileUrl` | Link do S3/Firebase. |
| Cliente | `Document.sentById` | - |
| Status | `Document.status` | Atualizar após decisão (Aprovado/Recusado). |

## 🕹️ Ações
- **Status Update**: Altera `Document.documentStatus` para `APPROVED` ou `REJECTED`.

## 💡 Sugestões do Gemini
- **Image Viewer**: Visualizador centralizado com fundo escuro (Lightroom style).
- **Floating Decision Bar**: Botões de "Aprovar" e "Recusar" flutuando sobre a imagem.
- **Comentário de Recusa**: Campo obrigatório se a decisão for recusar.
