# Tela: Gestão de IA & RAG

- **Localização**: [Tab Bar] Aba 4 (Menu secundário ou Aba 5)
- **Objetivo**: Treinar e configurar a base de conhecimento e comportamento do chatbot.

## 🏗️ Blueprint Visual
- **Corpo**:
  - Configurações de Comportamento (Tom de Voz).
  - Horários de Atendimento (Início/Fim).
  - Lista de documentos indexados (Base de Conhecimento).
  - Status de indexação (Em processamento / Ativo).

## 📊 Mapeamento de Dados (`feat/G5-8`)
| UI Component | Model Field | Display Rule |
| :--- | :--- | :--- |
| Tom de Voz | `Configuration.aiToneOfVoice` | Texto livre para orientar a IA. |
| Horário | `Configuration.serviceHoursStart`/`End`| Picker de hora. |
| Knowledge Base | `Document[]` (Filtro por Categoria) | Lista de arquivos de conhecimento. |

## 🕹️ Ações
- **Treinar/Indexar**: Dispara processo no backend para processar os PDFs.

## 💡 Sugestões do Gemini
- **Config Switches**: Chaves liga/desliga para habilitar/desabilitar o Bot.
- **List with Trash Icons**: Lista de documentos da base de conhecimento com ícones de exclusão.
- **Treinar IA**: Enviar nova jurisprudência/regras (Cria registro em `Document`).
