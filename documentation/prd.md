# PRD - OmniConnect (Gestao Juridica Inteligente)

## 1. Visao Geral

O OmniConnect e um ecossistema de gestao juridica que une a agilidade da IA no WhatsApp com a organizacao de um app Flutter dedicado. Ele foca em eliminar o "ruido" na comunicacao entre advogado e cliente, automatizando tarefas repetitivas (triagem e consulta de status) e centralizando a troca de documentos e informacoes processuais.

- **Publico-Alvo:** Escritorios de advocacia de medio porte e seus clientes.
- **Diferencial Estrategico:** Resposta instantanea via RAG (IA) e transparencia total via Linha do Tempo no aplicativo.
- **Metrica de Sucesso:** Reducao de chamadas/mensagens manuais para consulta de status e tempo de resposta para novos leads inferior a 5 minutos (automacao).

## 2. Requisitos

### 2.1. Bloco 1 - Chatbot WhatsApp (IA + RAG)

#### [ ] Identificacao e Triagem de Leads

**Descricao:** O bot atua como a primeira linha de defesa do escritorio.

**Regras de Negocio:**

- **Validacao de Cadastro:** O sistema consulta o `phone_number` no banco. Se nao existir, inicia o fluxo de Lead.
- **Coleta Obrigatoria (6 campos):** Nome completo, CPF (validacao de formato), Tipo de Caso (Trabalhista, Civel, Familia, Criminal, Previdenciario), Descricao resumida, Urgencia (Alta/Media/Baixa) e Disponibilidade para contato (Manha/Tarde/Noite).
- **Persistencia:** Os dados sao salvos com status `LEAD_PENDENTE` e vinculados ao numero do WhatsApp.

**Regras de UI/UX:**

- **Tom de Voz:** Profissional, acolhedor e direto.
- **Feedback de Erro:** Se o usuario enviar um CPF invalido, o bot pede a correcao educadamente antes de prosseguir.

#### [ ] Consulta de Status via Bot

**Descricao:** Consulta self-service de processos ativos.

**Regras de Negocio:**

- **Busca por Telefone:** O sistema identifica o cliente e busca todos os registros na tabela `processos`.
- **Logica de Exibicao:**
  - **1 Processo:** Exibe Nome do Processo, Status Atual e "Ultima Nota do Advogado".
  - **Multiplos:** Lista numerada de processos para o usuario escolher um.
  - **Nenhum:** Informa que nao ha processos e oferece abertura de novo caso.

**Regras de UI/UX:**

- **Clareza:** O status deve vir acompanhado de uma data. Exemplo: `Status: Em analise - Atualizado em 07/04/2026`.

#### [ ] Inteligencia RAG e Suporte Humano

**Descricao:** Respostas a duvidas juridicas e transicao para o advogado.

**Regras de Negocio:**

- **Filtro de Contexto:** A IA (LangChain) so responde duvidas com base na base de conhecimento (PDFs/Docs) indexada.
- **Handoff Humano:** Gatilho ativado por palavras-chave (`ajuda`, `falar com alguem`, `advogado`) ou falha na resposta da IA.
- **Notificacao Critica:** Dispara Push FCM para o usuário Advogado com o historico da conversa anexado.

### 2.2. Bloco 2 - App Flutter Único (Perfis e Dashboard)

#### [ ] Perfil Cliente: Dashboard e Timeline

**Descricao:** Visualizacao centralizada da vida juridica do cliente.

**Regras de Negocio:**

- **Aba "Linha do Tempo":** Exibe cronologicamente as notas deixadas pelo advogado (Peticao protocolada, Audiencia marcada etc.).
- **Aba "Chat":** Espelhamento (somente leitura) da conversa tida com o bot no WhatsApp para referencia do cliente.
- **Botao Duvida Rapida:** Redireciona para o WhatsApp do escritorio com o texto: `Ola, tenho uma duvida sobre meu processo [ID-CASO]`.

**Regras de UI/UX:**

- **Estados:** Loading skeletons enquanto busca os dados do banco.
- **Acessibilidade:** Cores de alto contraste para facilitar a leitura de documentos.

#### [ ] Perfil Cliente: Gestao de Documentos

**Descricao:** Envio de arquivos comprobatorios.

**Regras de Negocio:**

- **Restricoes:** Limite de 10MB por arquivo. Formatos: PDF, PNG, JPG.
- **Vinculo:** O arquivo deve ser obrigatoriamente associado a um processo existente.

**Regras de UI/UX:**

- **Feedback:** Barra de progresso visivel durante o upload. Notificacao de "Sucesso" ao concluir.

#### [ ] Perfil Advogado: Painel de Controle (Dashboard)

**Descricao:** Visao 360o das operacoes do escritorio.

**Regras de Negocio:**

- **Metricas em Tempo Real:**
  - Total de casos (Abertos/Encerrados).
  - Fila de Transferencias para Humano (Prioridade Maxima).
  - Grafico de Pizza: Distribuicao por nicho (Trabalhista vs Civel).
  - Feed de Documentos Recentes: Lista dos ultimos arquivos subidos pelos clientes.

**Regras de UI/UX:**

- **Filtros:** Busca rapida por CPF, Nome do Cliente ou Status.
- **Pull-to-refresh:** Atualizacao manual da lista de leads e casos.

#### [ ] Perfil Advogado: Gestao de Leads e Cadastro

**Descricao:** Conversao de interessados em clientes.

**Regras de Negocio:**

- **Fluxo de Conversao:** O advogado clica em "Converter Lead", confirma os dados capturados pelo bot e o sistema cria automaticamente o usuario na tabela `clientes`.
- **Atribuicao de Login:** O sistema gera uma senha temporaria e envia automaticamente via WhatsApp para o cliente baixar o app.

### 2.3. Bloco 3 - Backend e Sincronizacao

#### [ ] Sincronizacao em Tempo Real e Notificacoes

**Regras de Negocio:**

- **Latencia:** Maximo de 2 segundos para o dado aparecer no App apos atualizacao no banco.
- **Push Notifications (FCM):**
  - **Para Cliente:** Quando o advogado altera o status do processo.
  - **Para Advogado:** Quando ha solicitacao de suporte humano ou novo documento enviado.
- **Modo Offline:** O app Flutter deve exibir uma Tela de Bloqueio de Conexao se o usuario perder o sinal, impedindo escritas no banco que possam causar conflito.

## 3. Fluxo de Usuario (User Flow)

### 3.1. Jornada do Novo Lead (WhatsApp)

- **Inicio:** O usuario envia "Oi" para o numero do escritorio.
- **Triagem:** O bot identifica numero novo e inicia a coleta dos 6 campos obrigatorios.
- **Persistencia:** O sistema salva o Lead e notifica o advogado via Push: `Novo Lead: [NOME] - Caso [TIPO]`.
- **Encerramento:** O bot informa a disponibilidade do advogado (baseado na agenda cadastrada no app).

### 3.2. Jornada de Atualizacao (Fluxo de Papéis no App)

- **Acao:** O advogado acessa o Dashboard, seleciona um processo e altera o status para "Audiencia Marcada".
- **Nota:** O advogado adiciona uma observacao: `A audiencia sera no dia 15/05 as 14h via Zoom`.
- **Processamento:** O backend salva, atualiza a timeline e dispara o Push FCM.
- **Recepcao:** O cliente recebe a notificacao no mesmo app (sob seu perfil), clica e o app abre direto na aba de Linha do Tempo do processo.

### 3.3. Jornada de Consulta RAG (WhatsApp)

- **Acao:** Cliente cadastrado pergunta: `Quais documentos preciso para um divorcio?`
- **IA:** O LangChain busca na base de conhecimento juridica do escritorio.
- **Resposta:** O bot lista os documentos conforme o PDF indexado.
- **Fechamento:** O bot pergunta se o usuario quer enviar esses documentos agora pelo App.

## 4. Fora do Escopo (Out of Scope)

- **Autocadastro de Usuarios:** Todo acesso e gerado a partir de um Lead ou pelo Advogado (seguranca).
- **Editor de Documentos:** O app nao edita PDFs ou DOCX; apenas visualiza e armazena.
- **Pagamentos e Cobrancas:** Gateway de pagamento nao sera implementado neste ciclo.
- **Chamadas de Video Nativas:** O suporte e textual; links para Zoom/Teams devem ser enviados manualmente nas notas.
- **Multi-Escritorio:** O sistema e Single-Tenant (um escritorio por instancia).
