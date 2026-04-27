# Mapa da Integracao Mobile x Server

**Status:** documento vivo  
**Ultima atualizacao:** 2026-04-24  
**Escopo:** `mobile/` Flutter e `server/` Node.js/TypeScript  

Este documento registra como o app mobile e o servidor devem conversar durante a integracao. Ele deve ser atualizado sempre que uma tela deixar de usar dados locais/mockados e passar a consumir uma rota real, ou quando uma rota do backend for criada, alterada ou removida para atender o app.

## Como manter este documento atualizado

- Atualize a coluna **Status** quando uma funcionalidade for integrada no mobile.
- Adicione a evidencia principal na coluna **Evidencia**, citando arquivo de tela, datasource, repository, service ou rota.
- Quando uma rota nova for criada no backend para atender uma tela, mova o item de **Gaps** para o fluxo correspondente.
- Quando uma tela for removida ou mudar de escopo, remova ou ajuste o fluxo para nao deixar divida falsa.

Legenda de status:

- `Pendente`: existe UI ou rota, mas ainda nao ha integracao mobile-server.
- `Parcial`: parte do fluxo existe, mas falta alguma chamada, contrato ou acao.
- `Integrado`: mobile chama rota real e trata resposta/erro em fluxo de negocio.
- `Nao se aplica ao mobile`: rota existe para outro consumidor, como Bot/IA.

---

## 1. Fluxos de Funcionalidades

### 1.1 Entrada no app

Hoje a historia visual comeca na tela de login: o usuario escolhe se e cliente ou advogado, preenche CPF/OAB e senha, e o app navega para o dashboard correspondente. No servidor, a porta real de entrada e `POST /api/v1/auth/login`.

O contrato inicial foi fechado para `identifier + password`, onde `identifier` pode ser CPF ou numero de WhatsApp. O backend continua aceitando `whatsappNumber`/`cpf` para compatibilidade, mas o mobile envia `identifier`.

Depois do login, o mobile precisa identificar a conta logada para preencher perfil, permissao e shell correto do app. A recomendacao de contrato e ter uma rota unica e sem ambiguidade: `GET /api/v1/account`. Evitar nomes paralelos como `/me`, `/profile` e `/user/profile` ajuda o app a ter uma fonte clara para "quem sou eu nesta sessao".

| Fluxo | Rotas | Status | Evidencia |
|---|---|---|---|
| Login cliente/advogado | `POST /api/v1/auth/login` | Integrado | Mobile chama rota real em `mobile/lib/features/auth/data/datasources/auth_remote_data_source.dart` e navega pelo `role`; backend aceita CPF/WhatsApp em `server/src/services/implementations/auth.service.ts` |
| Identificar conta logada | `GET /api/v1/account` | Integrado | Backend em `server/src/routes/v1/account.routes.ts`; mobile carrega conta apos login em `auth_repository_impl.dart` |
| Cadastro de cliente | `POST /api/v1/auth/register` | Pendente | Backend existe; mobile tem texto "Cadastre-se", mas sem jornada funcional |
| Logout | Sem rota dedicada | Parcial | Mobile tem `AuthRepository.logout()` para limpar token, mas os botoes de perfil ainda nao chamam o provider |

### 1.2 Cliente acompanhando tramites

Quando o cliente abre o app, a home mostra uma movimentacao importante e a lista de tramites mostra processos como "Acao Indenizatoria" e "Acao de Divorcio". A conversa esperada e: o mobile busca os processos do usuario com `GET /api/v1/processes/my`, abre detalhes com `GET /api/v1/processes/{id}` e carrega a linha do tempo com `GET /api/v1/timeline/process/{processId}`.

Hoje as telas contam essa historia com dados locais.

| Fluxo | Rotas | Status | Evidencia |
|---|---|---|---|
| Listar tramites do cliente | `GET /api/v1/processes/my` | Integrado | Provider `myProceduresProvider` consumido em `client_procedure_list_screen.dart` |
| Abrir detalhe do tramite | `GET /api/v1/processes/{id}` | Integrado | Lista envia `processId` real e timeline carrega detalhes por `procedureDetailsProvider` |
| Carregar timeline do tramite | `GET /api/v1/timeline/process/{processId}` | Integrado | `client_procedure_timeline_screen.dart` usa `procedureTimelineProvider(processId)` |
| Atualizacao em destaque na home | `GET /api/v1/processes/my` | Parcial | `client_home_screen.dart` usa o primeiro tramite real; ainda nao combina timeline/notificacoes para escolher a movimentacao mais relevante |

### 1.3 Cliente lidando com arquivos

Na aba de arquivos, o cliente ve documentos enviados, aprovados ou em analise, e abre uma modal para enviar foto ou arquivo do dispositivo. O backend ja oferece as rotas centrais: listar documentos por processo, enviar arquivo, visualizar arquivo e remover documento.

O app ainda nao escolhe arquivo real, nao envia multipart e nao vincula o envio a um `processId`.

| Fluxo | Rotas | Status | Evidencia |
|---|---|---|---|
| Listar arquivos do processo | `GET /api/v1/documents/process/{processId}` | Parcial | Aba Arquivos dentro da timeline usa `procedureDocumentsProvider(processId)`; tela geral `client_files_screen.dart` ainda e local |
| Enviar arquivo | `POST /api/v1/documents/upload` | Pendente | Backend espera multipart + `legalProcessId`; UI abre modal local |
| Visualizar/baixar arquivo | `GET /api/v1/documents/view/{filename}` | Pendente | Backend existe; mobile ainda nao usa |
| Remover arquivo | `DELETE /api/v1/documents/{id}` | Pendente | Backend existe para advogado; sem acao mobile clara |

### 1.4 Cliente vendo notificacoes

A tela de notificacoes mostra alertas sobre movimentacao, arquivo recebido e audiencia. A API ja tem o fluxo basico de inbox: listar notificacoes do usuario, marcar uma como lida e marcar todas como lidas.

Hoje a tela altera uma lista em memoria e tambem permite excluir localmente, mas nao ha rota de exclusao no backend.

| Fluxo | Rotas | Status | Evidencia |
|---|---|---|---|
| Listar notificacoes | `GET /api/v1/notifications/my` | Integrado | `myNotificationsProvider` consumido em `client_notifications_screen.dart` e `lawyer_notification_screen.dart` |
| Marcar uma notificacao como lida | `PATCH /api/v1/notifications/{id}/read` | Integrado | `NotificationActions.markAsRead()` invalida a inbox apos a chamada |
| Marcar todas como lidas | `POST /api/v1/notifications/read-all` | Integrado | A acao "Lidas" chama `NotificationActions.markAllAsRead()` |
| Excluir notificacao | Sem rota dedicada | Pendente | UI remove localmente e oferece desfazer |

### 1.5 Cliente usando chat e espelhamento

O mobile mostra uma lista de conversas e um espelhamento do assistente juridico. O backend permite buscar historico por WhatsApp com `GET /api/v1/messages/{whatsappNumber}`.

O envio de mensagens pelo app ainda nao tem uma rota clara. A rota `POST /api/v1/messages/sync` existe, mas e protegida por API Key e foi desenhada para integracao Bot/WhatsApp.

Ponto de produto: o app pode mostrar espelhamento/historico da conversa do WhatsApp, mas nao deve assumir automaticamente que havera uma conversa direta com o bot dentro do app. Se a experiencia oficial continuar sendo WhatsApp, o mobile deve abrir/encaminhar para esse canal ou apenas exibir o historico sincronizado.

| Fluxo | Rotas | Status | Evidencia |
|---|---|---|---|
| Listar historico de mensagens | `GET /api/v1/messages/{whatsappNumber}` | Pendente | UI em `client_chats_screen.dart` e `client_chat_mirror_screen.dart` |
| Enviar mensagem pelo cliente | Sem rota mobile dedicada | Pendente | Campo de mensagem existe, mas nao dispara chamada |
| Sincronizar mensagem do WhatsApp/Bot | `POST /api/v1/messages/sync` | Nao se aplica ao mobile | Rota protegida por API Key em `message.routes.ts` |

### 1.6 Advogado vendo dashboard

O dashboard do advogado mostra metricas, handoffs, ultimos leads e arquivos recentes. O backend tem as pecas separadas para alimentar isso, mas nao uma rota agregadora de dashboard.

No estado atual, o app renderiza tudo com valores fixos.

| Fluxo | Rotas | Status | Evidencia |
|---|---|---|---|
| Metricas de processos e leads | `GET /api/v1/processes/my`, `GET /api/v1/leads` | Parcial | `lawyer_overview_screen.dart` usa contagens reais de providers; ainda nao ha rota agregadora nem recortes por periodo |
| Handoffs aguardando | `GET /api/v1/notifications/my`, possivelmente `GET /api/v1/messages/{whatsappNumber}` | Pendente | Card local no dashboard |
| Arquivos recentes | `GET /api/v1/documents/process/{processId}` ou rota agregadora futura | Pendente | UI lista arquivo fixo |
| Dashboard agregado | Sem rota dedicada | Pendente | Sugestao: criar rota de resumo se muitas chamadas forem necessarias |

### 1.7 Advogado triando leads

Esta e uma das historias mais alinhadas com o backend. O bot captura um possivel cliente, cria um lead, o advogado revisa a ficha e pode converter esse lead em cliente/processo.

No backend, o fluxo existe com `GET /api/v1/leads`, `GET /api/v1/leads/{id}` e `PATCH /api/v1/leads/{id}/convert`. No mobile, a fila e a conversao ainda sao locais.

| Fluxo | Rotas | Status | Evidencia |
|---|---|---|---|
| Listar leads pendentes | `GET /api/v1/leads` | Integrado | `pendingLeadsProvider` consumido em `lawyer_lead_triage_screen.dart` e overview |
| Ver detalhe do lead | `GET /api/v1/leads/{id}` | Integrado | Lista envia `id` real e `lawyer_lead_detail_screen.dart` carrega `leadDetailsProvider(id)` |
| Converter lead em cliente | `PATCH /api/v1/leads/{id}/convert` | Integrado | Acoes de aceitar/converter chamam `LeadActions.convert(id)` e invalidam a fila |
| Criar lead vindo do bot | `POST /api/v1/leads` | Nao se aplica ao mobile | Rota protegida por API Key |

### 1.8 Advogado gerenciando tramites

O advogado tem tela de lista, busca, filtros, detalhe com timeline/resumo/arquivos/chat e uma modal para "Novo Tramite". O backend permite listar processos do usuario, abrir processo, atualizar status, buscar timeline e documentos.

Decisao/hipotese de produto: o advogado provavelmente nao deve criar tramites manualmente no app. O fluxo mais coerente e o tramite nascer da conversao de lead, de uma operacao administrativa/backend ou de outra fonte controlada, e o advogado apenas acompanhar/atualizar o andamento. Portanto, a ausencia de `POST /api/v1/processes` nao deve ser tratada automaticamente como gap ate essa decisao mudar.

| Fluxo | Rotas | Status | Evidencia |
|---|---|---|---|
| Listar tramites do advogado | `GET /api/v1/processes/my` | Integrado | Backend agora lista por `lawyerId` quando o token e de advogado; UI consome `myProceduresProvider` |
| Abrir detalhe do tramite | `GET /api/v1/processes/{id}` | Pendente | UI navega sem ID real |
| Atualizar status do tramite | `PATCH /api/v1/processes/{id}/status` | Pendente | Backend existe; UI ainda nao expõe acao real |
| Ver timeline | `GET /api/v1/timeline/process/{processId}` | Pendente | UI usa timeline local |
| Ver arquivos do tramite | `GET /api/v1/documents/process/{processId}` | Pendente | UI usa lista local |
| Criar novo tramite | Fora do escopo assumido | Nao se aplica ao mobile | FAB agora informa que a criacao manual ainda nao existe no backend |

### 1.9 Advogado vendo clientes

A tela de clientes mostra uma agenda de clientes, busca por nome/CPF e abre a ficha com contato e tramites vinculados. Nao encontrei rota de clientes/usuarios para o advogado consumir diretamente.

Hoje essa area e inteiramente local no mobile.

| Fluxo | Rotas | Status | Evidencia |
|---|---|---|---|
| Listar clientes | Sem rota dedicada | Pendente | UI em `lawyer_client_list_screen.dart` |
| Abrir ficha do cliente | Sem rota dedicada | Pendente | UI em `lawyer_client_detail_screen.dart` |
| Ver tramites vinculados ao cliente | Sem rota dedicada; poderia derivar de processos | Pendente | UI usa historico local |

### 1.10 Advogado revisando arquivos

O mobile mostra uma fila de documentos aguardando revisao, preview, metadados e botoes de aprovar/recusar. O backend permite listar, visualizar, subir e deletar documentos, mas nao tem status de revisao nem endpoints de aprovacao/recusa.

| Fluxo | Rotas | Status | Evidencia |
|---|---|---|---|
| Listar arquivos para revisao | Sem rota dedicada | Pendente | UI em `lawyer_file_list_screen.dart` |
| Visualizar arquivo | `GET /api/v1/documents/view/{filename}` | Pendente | Backend existe; UI nao usa arquivo real |
| Aprovar arquivo | Sem rota dedicada | Pendente | Botao existe em `lawyer_file_review_screen.dart` |
| Recusar arquivo com motivo | Sem rota dedicada | Pendente | Campo e botao existem na UI |

### 1.11 Advogado gerenciando IA/RAG

A tela de Gestao de IA permite ligar/desligar o bot, editar tom de voz, ajustar criatividade e gerenciar PDFs da base de conhecimento. O backend so expoe a leitura da configuracao do bot por API Key.

Ponto de produto: o advogado nao deve ter conversa direta com o bot dentro do app. O papel do advogado no mobile deve ser configurar/revisar o bot, acompanhar handoffs e assumir atendimento humano quando necessario. A conversa do bot em si continua no canal WhatsApp/IA e entra no app como historico, notificacao ou handoff.

| Fluxo | Rotas | Status | Evidencia |
|---|---|---|---|
| Ler configuracao do bot | `GET /api/v1/bot/configurations` | Nao se aplica diretamente ao mobile | Rota existe para Bot/IA |
| Atualizar tom de voz/horarios | Sem rota mobile/admin dedicada | Pendente | UI em `lawyer_ai_manager_screen.dart` |
| Pausar/reativar bot | Sem rota dedicada | Pendente | Switch local na UI |
| Gerenciar PDFs do RAG | Sem rota dedicada | Pendente | UI lista PDFs locais |

### 1.12 Bot e WhatsApp alimentando o sistema

Esta parte nao e chamada pelo mobile, mas explica como o servidor recebe eventos do mundo externo que aparecem no app. O bot consulta usuarios por telefone, busca processos por WhatsApp, salva mensagens, cria leads e cria notificacoes de handoff.

| Fluxo | Rotas | Status | Evidencia |
|---|---|---|---|
| Verificar usuario por WhatsApp | `GET /api/v1/bot/users/by-phone/{whatsappNumber}` | Nao se aplica ao mobile | Rota em `bot.routes.ts` |
| Buscar processos por WhatsApp | `GET /api/v1/bot/processes/by-phone/{whatsappNumber}` | Nao se aplica ao mobile | Rota em `bot.routes.ts` |
| Ler configuracoes do bot | `GET /api/v1/bot/configurations` | Nao se aplica ao mobile | Rota em `bot.routes.ts` |
| Criar notificacao de handoff | `POST /api/v1/bot/notifications` | Nao se aplica ao mobile | Rota em `bot.routes.ts` |
| Criar lead via bot | `POST /api/v1/leads` | Nao se aplica ao mobile | Rota com API Key em `lead.routes.ts` |
| Sincronizar mensagem via bot | `POST /api/v1/messages/sync` | Nao se aplica ao mobile | Rota com API Key em `message.routes.ts` |

---

## 2. O que nao esta batendo (Gaps)

### Falta no Backend

| Gap | Impacto no Mobile | Prioridade sugerida |
|---|---|---|
| Login por OAB | So e gap se o produto exigir OAB; a rodada atual fechou CPF ou telefone conforme pedido | Media |
| Logout/invalidacao de token | Logout hoje e apenas navegacao local | Media |
| Listagem/detalhe de clientes para advogado | Aba "Clientes" nao tem fonte real | Alta |
| Aprovacao/recusa de documentos | Revisao de arquivos nao pode funcionar | Alta |
| Exclusao de notificacao | UI promete acao sem persistencia | Baixa |
| Envio de mensagem pelo app | So e gap se o produto decidir que o app tera chat nativo; se o canal oficial for WhatsApp, deve virar espelhamento/atalho | Media |
| Controle de handoff pelo advogado | "Assumir", "pausar" e "reativar bot" nao persistem | Alta |
| Configuracao de IA/RAG pelo advogado | Tela de gestao de IA e apenas local | Media |
| Dashboard agregado do advogado | App teria que compor metricas com varias chamadas | Media |

### Sobra no Backend

As rotas abaixo ainda sobram para o mobile ou permanecem fora do app por desenho de arquitetura.

Rotas que devem continuar fora do mobile por desenho de arquitetura:

- `GET /api/v1/bot/users/by-phone/{whatsappNumber}`
- `GET /api/v1/bot/processes/by-phone/{whatsappNumber}`
- `GET /api/v1/bot/configurations`
- `POST /api/v1/bot/notifications`
- `POST /api/v1/messages/sync`
- `POST /api/v1/leads`

Rotas prontas para o mobile, mas ainda nao consumidas:

- `POST /api/v1/auth/register`
- `PATCH /api/v1/processes/{id}/status`
- `POST /api/v1/documents/upload`
- `GET /api/v1/documents/view/{filename}`
- `DELETE /api/v1/documents/{id}`
- `GET /api/v1/messages/{whatsappNumber}`

---

## 3. Observacoes e Sugestoes

O backend esta mais perto de uma API de produto do que o mobile esta de um consumidor real. Ele ja tem rotas versionadas em `/api/v1`, controllers por dominio, validacao, JWT, RBAC e API Key para o Bot/IA.

O mobile esta em estagio de prototipo visual: a navegacao e as telas principais existem, mas os dados sao locais. A primeira frente tecnica deve ser criar uma camada de integracao Flutter com:

- cliente `Dio` centralizado;
- configuracao de `baseUrl`;
- interceptor de `Authorization: Bearer`;
- armazenamento seguro do token;
- repositories por feature;
- estados de loading/erro/vazio por tela.

Ordem sugerida de integracao:

1. Autenticacao real e `GET /api/v1/account`. **Concluido nesta rodada.**
2. Processos, timeline e documentos do cliente. **Parcialmente concluido nesta rodada.**
3. Leads do advogado e conversao. **Concluido nesta rodada.**
4. Notificacoes. **Concluido nesta rodada.**
5. Handoff e espelhamento de mensagens, sem conversa direta advogado-bot no app.
6. Clientes, revisao de documentos e gestao de IA.

---

## 4. Historico de Atualizacoes

| Data | Alteracao | Responsavel |
|---|---|---|
| 2026-04-24 | Integracao inicial implementada: login por CPF/telefone, account, processos/timeline/documentos na timeline, notificacoes, leads e ajustes de listagem de tramites por advogado | Codex |
| 2026-04-24 | Registradas hipoteses de produto: advogado nao cria tramites diretamente, nao conversa com o bot dentro do app, e rota recomendada para conta logada e `GET /api/v1/account` | Codex |
| 2026-04-24 | Criacao do mapa inicial a partir da analise de `server/src/routes/v1` e `mobile/lib/features` | Codex |
