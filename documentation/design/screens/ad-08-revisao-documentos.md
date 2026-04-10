# Tela: Revisão de Documentos

- **Localização**: [Stack] A partir de Clientes ou Dashboard.
- **Objetivo**: Conferir arquivos enviados pelos clientes para dar andamento processual.

## 🏗️ Blueprint Visual
- **Corpo**:
  - Preview do arquivo (PDF ou Imagem).
  - Metadados: Quem mandou, Quando mandou, Qual processo.
  - Botões de decisão: "Aprovar" / "Recusar (Pedir novo)".

## 📊 Mapeamento de Dados (`feat/G5-8`)
| Componente | Campo do Modelo | Regra de Exibição |
| :--- | :--- | :--- |
| Arquivo | `Documento.url` | Link do S3/Firebase. |
| Cliente | `Documento.enviadoPorId` | - |
| Status | `Documento.status` | Atualizar após decisão. |

## 🕹️ Ações
- **Download**: Baixar arquivo para o dispositivo.
- **Comentário de Recusa**: Campo obrigatório se a decisão for recusar.
