# Tela: Diretório de Clientes

- **Localização**: [Tab Bar] Aba 4
- **Objetivo**: Gestão do cadastro geral de clientes do escritório.

## 🏗️ Blueprint Visual
- **Topo**: Busca por Nome ou CPF.
- **Corpo**: Lista alfabética de clientes.
- **Ação Rápida**: Botão de ligar ou WhatsApp ao lado do nome.

## 📊 Mapeamento de Dados (`feat/G5-8`)
| Componente | Campo do Modelo | Regra de Exibição |
| :--- | :--- | :--- |
| Nome | `User.nome` | - |
| CPF | `User.cpf` | Se cadastrado. |
| Contato | `User.whatsappNumber` | - |

## 🕹️ Ações
- **Ver Ficha**: Detalhes do cliente e histórico de todos os seus processos.
