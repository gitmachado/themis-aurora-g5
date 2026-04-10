# Modelagem de Dados

## Entidades do Domínio (7)

### User (Advogados e Clientes)

| Campo | Tipo | Descrição |
|---|---|---|
| id | UUID | Identificador único |
| nome | string | Nome completo |
| whatsappNumber | string | Número WhatsApp (único, usado como login) |
| cpf | string? | CPF (opcional para advogados) |
| email | string? | Email |
| role | ADVOGADO \| CLIENTE | Perfil de acesso |
| senhaHash | string? | Senha criptografada |
| fcmToken | string? | Token Firebase para push notifications |
| preferenciasNotificacao | JSON? | Preferências de tipos de push |

### Lead (Pré-cadastro via Bot)

| Campo | Tipo | Descrição |
|---|---|---|
| id | UUID | Identificador único |
| whatsappNumber | string | Número que iniciou o contato |
| nome | string? | Coletado progressivamente pelo bot |
| cpf | string? | Validação de formato em tempo real |
| tipoCaso | enum | Trabalhista, Cível, Família, Criminal, Previdenciário |
| descricaoCaso | string? | Descrição livre do problema |
| urgencia | enum | Alta, Média, Baixa |
| disponibilidadeContato | enum | Manhã, Tarde, Noite |
| status | enum | PENDENTE, CONVERTIDO, DESCARTADO |
| convertedUserId | UUID? | FK para User quando convertido |
| observacoesAdvogado | string? | Anotações internas do advogado |
| motivoDescarte | string? | Motivo quando status = DESCARTADO |

### Processo (Caso Jurídico)

| Campo | Tipo | Descrição |
|---|---|---|
| id | UUID | Identificador único |
| clienteId | UUID | FK para User (cliente) |
| advogadoId | UUID? | FK para User (advogado responsável) |
| titulo | string | Nome do caso |
| descricao | string? | Detalhes adicionais |
| statusAtual | string | Status vigente (Em análise, Audiência marcada, etc.) |
| numeroProcesso | string? | Número oficial do processo judicial |
| tipoCaso | enum | Nicho jurídico |

### Timeline Evento (Histórico)

| Campo | Tipo | Descrição |
|---|---|---|
| id | UUID | Identificador único |
| processoId | UUID | FK para Processo |
| tipo | enum | ATUALIZACAO_STATUS, NOTA_ADVOGADO, ENVIO_DOCUMENTO, CRIACAO_PROCESSO |
| conteudo | string | Texto do evento |
| statusAnterior | string? | Status antes da mudança (para transições) |
| metadata | JSON? | Dados extras estruturados |
| criadoPorId | UUID? | FK para User que gerou o evento |

### Documento (Arquivos do Processo)

| Campo | Tipo | Descrição |
|---|---|---|
| id | UUID | Identificador único |
| processoId | UUID | FK para Processo |
| nomeArquivo | string | Nome original |
| urlArquivo | string | URL de armazenamento |
| tamanhoBytes | number? | Máximo 10MB |
| tipoMime | string? | PDF, PNG, JPG |
| enviadoPorId | UUID | FK para User |

### Mensagem (Chat WhatsApp Persistido)

| Campo | Tipo | Descrição |
|---|---|---|
| id | UUID | Identificador único |
| leadId | UUID? | FK para Lead (pré-conversão) |
| userId | UUID? | FK para User (pós-conversão) |
| remetente | enum | BOT, CLIENTE, ADVOGADO |
| conteudo | string | Texto da mensagem |
| whatsappMessageId | string? | ID original do WhatsApp |

### Notificação (Push FCM)

| Campo | Tipo | Descrição |
|---|---|---|
| id | UUID | Identificador único |
| userId | UUID | FK para User destinatário |
| tipo | enum | NOVO_LEAD, STATUS_ALTERADO, DOCUMENTO_ENVIADO, SUPORTE_HUMANO |
| titulo | string | Título do push |
| corpo | string | Corpo da mensagem |
| lida | boolean | Controle de leitura |
| dadosExtras | JSON? | Dados para deep link ao abrir |

## Diagrama de Relacionamentos

```
User ──1:N──▶ Processo
User ──1:N──▶ Notificacao
User ──1:N──▶ Mensagem (pós-conversão)
User ──1:N──▶ TimelineEvento (como autor)
User ──1:N──▶ Documento (como remetente)

Lead ──1:N──▶ Mensagem (pré-conversão)
Lead ──0..1──▶ User (conversão)

Processo ──1:N──▶ TimelineEvento
Processo ──1:N──▶ Documento
```

## Enums do Domínio

| Enum | Valores |
|---|---|
| TipoCaso | Trabalhista, Cível, Família, Criminal, Previdenciário |
| NivelUrgencia | Alta, Média, Baixa |
| StatusLead | PENDENTE, CONVERTIDO, DESCARTADO |
| UserRole | ADVOGADO, CLIENTE |
| TipoEvento | ATUALIZACAO_STATUS, NOTA_ADVOGADO, ENVIO_DOCUMENTO, CRIACAO_PROCESSO |
| DisponibilidadeContato | Manhã, Tarde, Noite |
| TipoNotificacao | NOVO_LEAD, STATUS_ALTERADO, DOCUMENTO_ENVIADO, SUPORTE_HUMANO |
| RemetenteMensagem | BOT, CLIENTE, ADVOGADO |
