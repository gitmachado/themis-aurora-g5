# Tela: Diretório de Clientes

- **Localização**: [Tab Bar] Aba 4
- **Objetivo**: Gestão do cadastro geral de clientes do escritório.

## 🏗️ Blueprint Visual
- **Topo**: Busca por Nome ou CPF.
- **Corpo**: Lista alfabética de clientes.
- **Ação Rápida**: Botão de ligar ou WhatsApp ao lado do nome.

## 📊 Mapeamento de Dados (`feat/G5-8`)
| UI Component | Model Field | Display Rule |
| :--- | :--- | :--- |
| Nome | `User.name` | - |
| CPF | `User.cpf` | Se cadastrado. |
| Contato | `User.whatsappNumber` | - |

## 🕹️ Ações
- **Ver Ficha**: Detalhes do cliente e histórico de todos os seus processos.

## 💡 Sugestões do Gemini
- **A-Z Scrolling**: Barra alfabética na lateral direita para navegação em listas longas.
- **Card de Contato**: Botões diretos de "Ligar" e "Enviar WhatsApp" no card do cliente.
