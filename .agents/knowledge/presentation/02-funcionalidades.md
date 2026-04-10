# Funcionalidades do MVP

## Bloco 1 — Chatbot WhatsApp (IA + RAG)

### Triagem Automática de Leads

- O bot identifica números novos e inicia coleta de dados automaticamente.
- **6 campos obrigatórios:** Nome completo, CPF, Tipo de Caso, Descrição resumida, Urgência (Alta/Média/Baixa), Disponibilidade para contato (Manhã/Tarde/Noite).
- Validação de CPF em tempo real — pede correção educadamente se inválido.
- O lead é salvo com status `PENDENTE` e vinculado ao número do WhatsApp.
- O advogado recebe push notification imediata: "Novo Lead: [NOME] - Caso [TIPO]".

### Consulta de Status via Bot

- Cliente cadastrado pergunta "qual o status?" e o bot consulta o banco.
- **1 processo:** Exibe nome, status atual, data e última nota do advogado.
- **Múltiplos processos:** Lista numerada para o cliente escolher.
- **Nenhum processo:** Informa e oferece abertura de novo caso.

### Inteligência RAG

- O bot responde dúvidas jurídicas com base em documentos indexados (PDFs do escritório).
- Usa LangChain para busca vetorial na base de conhecimento.
- **Handoff humano:** Se o cliente pede "falar com advogado" ou a IA falha, transfere para atendimento humano com notificação push + histórico da conversa anexado.

---

## Bloco 2 — App Flutter (2 perfis)

### Perfil CLIENTE

#### Tela "Meus Processos" (Home)
- Lista de cards com todos os processos: título, status, tipo, data de atualização.
- Badge de notificações não lidas no header.
- Botão "Dúvida Rápida" — redireciona para WhatsApp do escritório.

#### Tela "Detalhe do Processo"
- **Tab Linha do Tempo:** Eventos cronológicos — cada nota do advogado, mudança de status, documento enviado.
- **Tab Chat:** Espelhamento (somente leitura) de toda a conversa com o bot WhatsApp.
- **Tab Documentos:** Lista de arquivos do processo + botão de upload.

#### Upload de Documentos
- Limite: 10MB por arquivo. Formatos: PDF, PNG, JPG.
- Obrigatoriamente vinculado a um processo existente.
- Barra de progresso durante upload + notificação de sucesso.

#### Notificações
- Lista de alertas push: status alterado, documento recebido, etc.
- Indicação visual de lidas vs não lidas.

### Perfil ADVOGADO

#### Dashboard (Home)
- **Métricas:** Total de casos abertos, encerrados, leads pendentes.
- **Fila de suporte humano:** Leads que pediram atendimento humano, com tempo de espera.
- **Gráfico de pizza:** Distribuição de casos por nicho (Trabalhista, Cível, Família...).
- **Feed de documentos recentes:** Últimos arquivos enviados pelos clientes.
- Filtros: busca por CPF, nome do cliente ou status.

#### Lista de Leads
- Cards com: nome, tipo de caso, urgência, telefone, status (Pendente/Convertido/Descartado).
- Preview da descrição do caso.
- Filtros por status, tipo e urgência.
- Ações rápidas: Ver, Converter, Descartar.

#### Detalhe do Lead
- Todos os 6 campos coletados pelo bot.
- Observações internas do advogado (campo livre para anotações).
- Histórico do chat com o bot.
- Botão "Converter" → gera login + senha temporária enviada via WhatsApp.
- Botão "Descartar" → exige motivo (Fora da área, Sem interesse, Conflito, Dados insuficientes, Outro).

#### Gerenciar Processo
- Alterar status com dropdown.
- Adicionar nota na timeline (texto livre).
- Botão "Salvar e Notificar" → dispara push para o cliente automaticamente.
- Ver timeline, documentos e dados do cliente.

#### Configurações
- Perfil do advogado (nome, email).
- Preferências de notificação (toggle por tipo: Novo Lead, Suporte Humano, Documento, Status).
- Alterar senha, sair.

---

## Bloco 3 — Backend e Sincronização

- **Latência máxima:** 2 segundos entre atualização no banco e aparição no app.
- **Push Notifications (FCM):**
  - Para Cliente: quando o advogado altera status do processo.
  - Para Advogado: suporte humano solicitado, novo documento enviado, novo lead.
- **Preferências de notificação:** Cada usuário controla quais tipos de push recebe.
- **Modo Offline:** Tela de bloqueio quando sem conexão (impede escritas conflitantes).
