# Tela: Meus Processos (Lista)

- **Localização**: [Tab Bar] Aba 2
- **Objetivo**: Listar todos os processos vinculados ao cliente de forma organizada.

## 🏗️ Blueprint Visual
- **Topo**: Título "Meus Processos" e busca por texto.
- **Corpo**: 
  - Lista de cards verticais.
  - Cada card possui um ícone lateral que muda conforme o `TipoCaso`.
  - Badge colorido no canto superior direito para o `statusAtual`.

## 📊 Mapeamento de Dados (`feat/G5-8`)
| Componente | Campo do Modelo | Regra de Exibição |
| :--- | :--- | :--- |
| Título do Processo | `Processo.titulo` | Texto em Negrito (H2). |
| Número | `Processo.numeroProcesso` | Texto em cinza (Caption). Formato: 0000000-00... |
| Status | `Processo.statusAtual` | Cores: Verde (Concluído), Amarelo (Audiência), Azul (Em análise). |
| Ícone | `Processo.tipoCaso` | Ícones: ⚖️ (Cível), 🤝 (Família), 👷 (Trabalhista). |

## 🕹️ Ações
- **Clique no Card**: Navegar para [Detalhes do Processo (Timeline)](cl-03-processo-timeline.md).
- **Pull-to-refresh**: Atualizar lista via API.
