# Tela: Gestão de IA & RAG

- **Localização**: [Tab Bar] Aba 4 (Menu secundário ou Aba 5)
- **Objetivo**: Treinar e configurar a base de conhecimento do chatbot.

## 🏗️ Blueprint Visual
- **Corpo**:
  - Lista de documentos indexados (PDFs técnicos).
  - Status de indexação (Em processamento / Ativo).
  - Botão "Treinar IA com Novo Doc".

## 📊 Mapeamento de Dados (`feat/G5-8`)
| Componente | Campo do Modelo | Regra de Exibição |
| :--- | :--- | :--- |
| Doc Treino | `Configuracao.modelo` | Lista de arquivos de conhecimento. |
| Status | `Configuracao.statusRag` | Se a sincronização está ok. |

## 🕹️ Ações
- **Upload PDF**: Enviar nova jurisprudência/regras para o LangChain.
- **Limpar Base**: Resetar conhecimento (Cuidado!).
