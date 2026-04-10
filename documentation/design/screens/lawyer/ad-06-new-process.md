# Tela: Novo Processo (Cadastro)

- **Localização**: [Stack] A partir de Gestão de Processos (+).
- **Objetivo**: Vincular um cliente a um novo serviço jurídico.

## 🏗️ Blueprint Visual
- **Interface**: Formulário em etapas ou scroll único.
- **Campos**: 
  - Cliente (Dropdown com busca em `User`).
  - Título do Caso (Livre).
  - Número do Processo (Opcional - se já estiver no tribunal).
  - Tipo de Caso (Enum).

## 📊 Mapeamento de Dados (`feat/G5-8`)
| UI Component | Model Field | Display Rule |
| :--- | :--- | :--- |
| Busca Cliente | `User.name` | Filtrar onde `role == CLIENT`. |
| Título | `LegalProcess.title` | Obrigatório. |
| Nicho | `LegalProcess.caseType` | Seletor de Chip. |

## 🕹️ Ações
- **Salvar e Notificar**: Cria o registro e dispara Push para o cliente.

## 💡 Sugestões do Gemini
- **Stepper Component**: Indicador visual de progresso (Etapa 1 de 3) no topo.
- **Inputs Agrupados**: Agrupar campos de data e seleção para reduzir o scroll.
- **Botão Avançar**: Botão de largura total na base da etapa.
