# Tela: Central de Notificações

- **Localização**: [Stack] Acessada pelo header da Home.
- **Objetivo**: Listar alertas e notificações de sistema para o cliente.

## 🏗️ Blueprint Visual
- **Header**: Título "Notificações" e botão "Limpar Tudo".
- **Corpo**: Lista de itens com ícones de indicação de tipo. Itens não lidos devem ter um fundo levemente colorido.

## 📊 Mapeamento de Dados (`feat/G5-8`)
| Componente | Campo do Modelo | Regra de Exibição |
| :--- | :--- | :--- |
| Título | `Notificacao.titulo` | Título curto do alerta. |
| Descrição | `Notificacao.corpo` | Texto explicativo da notificação. |
| Tempo | `Notificacao.createdAt` | Exibir tempo relativo (ex: "há 5 min"). |
| Estado Lida | `Notificacao.lida` | Se `false`, exibir indicador visual (ponto azul). |

## 🕹️ Ações
- **Marcar como lida**: Ao clicar ou deslizar a notificação.
- **Ação Direta**: Se for sobre um processo, o clique leva direto para a timeline deste.
