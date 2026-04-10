# Navegação e Telas do App

## Perfil CLIENTE — 3 tabs na tab bar inferior

### Tab Bar

| Tab | Ícone | Tela | O que mostra |
|---|---|---|---|
| **Processos** | 📋 | Meus Processos (Home) | Cards com título, status, tipo e data de cada processo |
| **Chat** | 💬 | Histórico do Chat | Espelhamento do chat completo com o bot WhatsApp (somente leitura) |
| **Notificações** | 🔔 | Central de Notificações | Alertas push com indicação de lidas/não lidas |

### Telas Fora da Tab Bar

| Tela | Como acessar | Função |
|---|---|---|
| Login | Pré-autenticação | WhatsApp + senha temporária |
| Detalhe do Processo | Tap no card de processo | 3 sub-tabs: Linha do Tempo, Documentos, Detalhes |
| Upload de Documento | Dentro do Detalhe → tab Docs | Envio de PDF/PNG/JPG (até 10MB) |

---

## Perfil ADVOGADO — 4 tabs na tab bar inferior

### Tab Bar

| Tab | Ícone | Tela | O que mostra |
|---|---|---|---|
| **Dashboard** | 🏠 | Painel de Controle | Métricas, fila suporte, gráfico por nicho, docs recentes |
| **Leads** | 👤 | Lista de Leads | Funil de conversão com filtros e ações rápidas |
| **Processos** | ⚖️ | Lista de Processos | Todos os processos com busca por CPF/nome/status |
| **Notificações** | 🔔 | Central de Notificações | Novo lead, suporte humano, documento enviado |

### Telas Fora da Tab Bar

| Tela | Como acessar | Função |
|---|---|---|
| Login | Pré-autenticação | Login padrão |
| Detalhe do Lead | Tap no card de lead | Dados completos, chat do bot, observações, converter/descartar |
| Modal Converter Lead | Botão no detalhe | Confirmação de dados + geração de senha |
| Modal Descartar Lead | Botão no detalhe | Seleção do motivo de descarte |
| Gerenciar Processo | Tap no card de processo | Alterar status, adicionar nota, timeline, docs |
| Configurações | Ícone ⚙️ no Dashboard | Perfil, preferências de notificação, sair |

---

## Wireframes Textuais (Rascunho)

### Home do Cliente

```
┌─────────────────────────────┐
│  Olá, Maria!           🔔3  │
│─────────────────────────────│
│  📋 Meus Processos          │
│                             │
│  ┌───────────────────────┐  │
│  │ Divórcio Consensual   │  │
│  │ 📊 Audiência marcada  │  │
│  │ 📅 Atualizado: 07/04  │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │ Revisão Trabalhista   │  │
│  │ 📊 Em análise         │  │
│  │ 📅 Atualizado: 03/04  │  │
│  └───────────────────────┘  │
│                             │
│  💬 Dúvida Rápida           │
├─────┬─────────┬─────────────┤
│ 📋  │   💬    │     🔔      │
│Proc.│  Chat   │   Notif.    │
└─────┴─────────┴─────────────┘
```

### Dashboard do Advogado

```
┌─────────────────────────────┐
│  OmniConnect       🔔5  ⚙️  │
│─────────────────────────────│
│  ┌──────┐ ┌──────┐ ┌──────┐│
│  │  12  │ │   8  │ │   4  ││
│  │Aberto│ │Encerr│ │Leads ││
│  └──────┘ └──────┘ └──────┘│
│                             │
│  🔴 Fila Suporte (2)       │
│  ┌───────────────────────┐  │
│  │ Maria Silva - 15min   │  │
│  │ "falar com advogado"  │  │
│  └───────────────────────┘  │
│                             │
│  📊 Casos por Nicho         │
│  🟦 Trabalhista 45%        │
│  🟩 Cível 30%  🟨 Fam 25% │
│                             │
│  📄 Docs Recentes           │
│  • Certidão - Maria - 2h   │
├─────┬────┬──────┬───────────┤
│ 🏠  │ 👤 │  ⚖️  │    🔔     │
│Dash │Lead│Proc. │  Notif.   │
└─────┴────┴──────┴───────────┘
```
