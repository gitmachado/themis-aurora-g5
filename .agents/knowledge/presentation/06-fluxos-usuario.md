# Fluxos de Usuário (User Flows)

## Fluxo 1: Novo Lead via WhatsApp

```
Pessoa envia "Oi" no WhatsApp
        │
        ▼
Bot verifica número no banco
        │
        ▼ (número novo)
Bot inicia coleta dos 6 campos:
  1. Nome completo
  2. CPF (valida formato)
  3. Tipo de caso
  4. Descrição resumida
  5. Urgência
  6. Disponibilidade para contato
        │
        ▼
Sistema salva Lead (status: PENDENTE)
Sistema salva cada mensagem da conversa
        │
        ▼
Push notification → App Advogado:
"Novo Lead: Maria Silva - Trabalhista"
        │
        ▼
Bot informa: "Um advogado entrará em contato"
```

## Fluxo 2: Consulta de Status via Bot

```
Cliente cadastrado envia mensagem
        │
        ▼
Bot identifica pelo número de WhatsApp
        │
        ├── 1 processo ──▶ Exibe: Título + Status + Data + Última Nota
        │
        ├── N processos ──▶ Lista numerada → cliente escolhe
        │
        └── 0 processos ──▶ "Sem processos. Quer abrir novo caso?"
```

## Fluxo 3: Conversão de Lead

```
Advogado abre tab "Leads" no app
        │
        ▼
Seleciona lead → vê dados + chat do bot
Adiciona observações internas
        │
        ▼
Clica "Converter Lead"
        │
        ▼
Sistema confirma dados do lead
Sistema cria User (role: CLIENTE)
Sistema gera senha temporária
Sistema envia senha via WhatsApp
Lead.status → CONVERTIDO
Lead.convertedUserId → novo User.id
        │
        ▼
Cliente recebe: "Baixe o app e use: senha XXXX"
```

## Fluxo 4: Atualização de Processo

```
Advogado seleciona processo no app
        │
        ▼
Altera status: "Em análise" → "Audiência marcada"
Adiciona nota: "Audiência dia 15/05 às 14h via Zoom"
Clica "Salvar e Notificar"
        │
        ▼
Sistema salva:
  - Processo.statusAtual = novo status
  - TimelineEvento (tipo: ATUALIZACAO_STATUS)
  - TimelineEvento (tipo: NOTA_ADVOGADO)
  - Notificação (tipo: STATUS_ALTERADO)
        │
        ▼
Push FCM → App Cliente:
"Seu processo mudou para: Audiência marcada"
        │
        ▼
Cliente clica na notificação
App abre na Linha do Tempo do processo
```

## Fluxo 5: Handoff para Humano

```
Cliente pergunta algo que a IA não sabe
    ou
Cliente digita "falar com advogado"
        │
        ▼
Bot detecta gatilho de handoff
        │
        ▼
Sistema cria Notificação:
  tipo: SUPORTE_HUMANO
  corpo: contexto da conversa
        │
        ▼
Push FCM → App Advogado:
"Suporte humano solicitado - Maria Silva"
        │
        ▼
Advogado vê na "Fila Suporte" do Dashboard
Visualiza histórico do chat
Inicia atendimento manual pelo WhatsApp
```

## Fluxo 6: Upload de Documento (Cliente)

```
Cliente abre detalhe do processo
Vai na tab "Documentos"
Clica "+"
        │
        ▼
Seleciona arquivo (câmera ou galeria)
        │
        ▼
Validação:
  - Tamanho ≤ 10MB? ✅
  - Formato PDF/PNG/JPG? ✅
        │
        ▼
Upload com barra de progresso
Sistema salva Documento
Sistema cria TimelineEvento (ENVIO_DOCUMENTO)
Sistema cria Notificação → Advogado
        │
        ▼
Push FCM → Advogado:
"Novo documento: Certidão - Maria"
```
