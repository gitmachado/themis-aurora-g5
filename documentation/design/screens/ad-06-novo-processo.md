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
| Componente | Campo do Modelo | Regra de Exibição |
| :--- | :--- | :--- |
| Busca Cliente | `User.nome` | Filtrar onde `role == CLIENTE`. |
| Título | `Processo.titulo` | Obrigatório. |
| Nicho | `Processo.tipoCaso` | Seletor de Chip. |

## 🕹️ Ações
- **Salvar e Notificar**: Cria o registro e dispara Push para o cliente.
