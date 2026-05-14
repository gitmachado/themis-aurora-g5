# 📅 Fluxo de Aprovação de Agendamentos - Guia de Uso

## Quick Start

### Para o Cliente (Via WhatsApp/Chat)

```
Cliente: "Quero agendar uma reunião para a próxima semana"

IA: "Tudo bem! Deixa eu verificar a disponibilidade do nosso advogado.
    Que dias você prefere?"

Cliente: "Terça ou quarta, à tarde"

IA: "Ótimo! Tenho terça às 14:00 ou quarta às 15:30. Qual prefere?"

Cliente: "Terça às 14:00"

IA: "Perfeito! Sua reunião está pré-reservada para terça às 14:00.
    O advogado revisará em breve. Você receberá uma confirmação
    final via WhatsApp! 🎉"
```

**=> Cliente vê**: "Pré-reservado, aguardando aprovação"

---

### Para o Advogado (No App Flutter)

#### 1. Ver Agendamentos Pendentes

1. Abrir app
2. Tela **Agenda**
3. Ver badge com número → ex: "3" (3 agendamentos pra aprovar)
4. Clicar no ícone 📅

#### 2. Lista de Pendentes

- Tela **Agendamentos da IA**
- Pull-to-refresh para atualizar
- Cada card mostra:
  - Nome do cliente
  - Título: "Reunião com cliente"
  - Data/hora: "13/05 às 14:00"

#### 3. Opções de Aprovação

Clicar em um agendamento → 4 botões:

##### ✅ APROVAR
- Status muda para SCHEDULED
- Cliente recebe WhatsApp: "✅ Sua reunião foi confirmada!"
- **Fim do fluxo**

##### ❌ REJEITAR
- Agendamento é deletado
- Cliente recebe WhatsApp: "⚠️ Sua solicitação não foi confirmada"
- **Fim do fluxo**

##### 🔄 REVERTER À PROPOSTA ORIGINAL
- Volta os campos para o que a IA havia sugerido
- Útil se você editou e quer desfazer
- Permanece **PENDENTE** (não aprova ainda)

##### 🔄 PEDIR IA REAGENDAR
- Abre um campo de texto
- Você escreve a instrução: ex: "Não segunda, veja a partir de terça"
- Clica "Enviar"
- **Aguarda** enquanto a IA processa (mostra "Aguardando...")
- Depois de alguns segundos/minutos: aparecem **3 sugestões de horários**
- Para cada sugestão, você clica **ACEITAR** ou **REJEITAR**
- Quando aceita: apointment é atualizado, mas continua **PENDENTE**
- Você aprova novamente clicando em **APROVAR**

---

## Fluxos em Detalhe

### Fluxo 1: Aprovação Simples ✅

```
┌─────────────────────┐
│ Agendamento        │
│ PENDING_APPROVAL   │
│ (criado por IA)    │
└──────────┬──────────┘
           │
           ▼ Clica "Aprovar"
┌─────────────────────┐
│ Update Status       │
│ → SCHEDULED        │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ WhatsApp ao Cliente │
│ "Reunião aprovada" │
└─────────────────────┘
```

### Fluxo 2: Rejeição ❌

```
┌─────────────────────┐
│ Agendamento        │
│ PENDING_APPROVAL   │
└──────────┬──────────┘
           │
           ▼ Clica "Rejeitar"
┌─────────────────────┐
│ Delete Appointment │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ WhatsApp ao Cliente │
│ "Não foi confirmada"│
└─────────────────────┘
```

### Fluxo 3: Reagendamento 🔄

```
┌──────────────────────┐
│ Agendamento         │
│ PENDING_APPROVAL    │
│ Terça 14:00        │
└──────────┬───────────┘
           │
           ▼ Clica "Pedir IA Reagendar"
┌──────────────────────────────────┐
│ Bottom Sheet: "Instrução de IA"  │
│ [Campo de texto]                │
│ "Não segunda, veja terça..."   │
└──────────┬───────────────────────┘
           │
           ▼ Clica "Enviar"
┌──────────────────────────────────┐
│ Aguardando...                    │
│ (Cron job processa a cada 2min) │
└──────────┬───────────────────────┘
           │
           ▼ IA gera 3 opções
┌──────────────────────────────────┐
│ Sugestões de Reagendamento:     │
│                                │
│ 1. Terça 10:00 ✓ Rejeitar     │
│ 2. Quarta 14:00 ✓ Rejeitar    │
│ 3. Quinta 15:00 ✓ Rejeitar    │
└──────────┬───────────────────────┘
           │
           ▼ Clica "Aceitar" em uma (ex: Quinta)
┌──────────────────────────────────┐
│ Appointment Atualizado:          │
│ Quinta 15:00 (PENDING_APPROVAL) │
└──────────┬───────────────────────┘
           │
           ▼ Clica "Aprovar"
┌──────────────────────────────────┐
│ Status → SCHEDULED               │
│ WhatsApp: "Nova hora: Quinta   │
│            15:00"               │
└──────────────────────────────────┘
```

---

## Mensagens de Notificação

### Para o Cliente

#### Quando agendado pela IA (antes de aprovação)
```
📱 WhatsApp
✉️ Seu agendamento foi recebido!

Reunião com advogado
📅 Segunda, 13 de maio às 14:00
🕐 Duração: 1 hora

⏳ O advogado está revisando sua solicitação.
   Você receberá uma confirmação final em breve!
```

#### Quando advogado aprova
```
📱 WhatsApp
✅ Reunião confirmada!

Sua reunião foi oficialmente agendada.

📅 Segunda, 13 de maio às 14:00
📍 Escritório Central
📞 (11) 98765-4321 (em caso de atrasos)

Lembre-se: chegar 10 minutos antes.
```

#### Quando advogado rejeita
```
📱 WhatsApp
⚠️ Sua solicitação foi revisada

Infelizmente, não conseguimos agendar para o horário solicitado.

💬 Entre em contato conosco:
   • WhatsApp: (11) 98765-4321
   • Email: contato@escritorio.com

Vamos encontrar um horário melhor para você!
```

---

## Configuração de Horários (IA)

A IA sempre respeita:

✅ **Horários Comerciais**: 09:00 - 18:00  
✅ **Dias Úteis**: Segunda a Sexta  
✅ **Próximos 7-14 dias**: Não agenda coisa passada ou muito longe  
✅ **Duração**: Mantém a mesma duração (ex: 1 hora)  
✅ **Instruções do Advogado**: "Não segunda", "Prefiro terça/quarta", etc  

Exemplo de instrução:
```
"Não segunda ou terça. Prefiro quarta ou quinta no período da manhã"

=> IA gera sugestões para QUARTA e QUINTA, 09:00-12:00
```

---

## Endpoints da API

### Para Mobile (Flutter)

```
GET /appointments/pending
  └─ Retorna lista de agendamentos PENDING_APPROVAL

PATCH /appointments/:id/approve
  └─ Aprova e muda para SCHEDULED
  └─ Body: { edits?: { title, description, etc } }

PATCH /appointments/:id/reject
  └─ Rejeita e deleta

PATCH /appointments/:id/reset-to-ai-version
  └─ Restaura dados originais da IA

POST /appointments/:id/reschedule-request
  └─ Solicita reagendamento
  └─ Body: { instruction: "string" }

GET /appointments/:id/reschedule-suggestions
  └─ Busca sugestões geradas pela IA
  └─ Retorna array com { id, suggestedDatetime, suggestedTitle, ... }

PATCH /reschedule-suggestions/:id/accept?appointmentId=...
  └─ Aceita uma sugestão

PATCH /reschedule-suggestions/:id/reject
  └─ Rejeita uma sugestão
```

---

## Troubleshooting

### "Não vejo o badge de pendentes"
- Puxe a tela para baixo (refresh)
- Ou date 30s para atualizar
- Ou saia e entre na tela novamente

### "Cliquei em 'Pedir IA Reagendar' mas não aparecem sugestões"
- Espere alguns segundos (+/- 10-15 segundos é normal)
- O cron job roda a cada 2 minutos
- Se passar de 5 minutos, recarregue a tela
- Pode haver fila se muitos advogados pedirem reagendamento

### "Sugestão desapareceu"
- Talvez outro advogado tenha rejeitado e apagado
- Ou a sugestão expirou
- Clique em "Pedir IA Reagendar" novamente

### "Erro ao Aprovar"
- Verificar se o agendamento ainda está PENDING_APPROVAL
- Verificar conexão de internet
- Tentar novamente

---

## Logs & Auditoria

Todos os eventos são registrados:

```
[AUDIT] ✨ AI_SCHEDULE_CREATED | apt_id=... | lawyer_id=... | client_id=...
[AUDIT] ✅ APPOINTMENT_APPROVED | apt_id=... | lawyer_id=...
[AUDIT] ❌ APPOINTMENT_REJECTED | apt_id=... | lawyer_id=...
[AUDIT] 💬 NOTIFICATION_SENT | user_id=... | template=APPOINTMENT_APPROVED
```

Para análise, métricas e compliance.

---

## Permissões & Segurança

- ✅ Advogado só vê seus próprios agendamentos (via lawyerId)
- ✅ Advogado não pode aprovar agendamento de outro advogado
- ✅ Cliente não pode forçar aprovação (read-only para cliente)
- ✅ Trigger SQL protege: IA não consegue criar SCHEDULED direto
- ✅ Validações em todas as operações

---

## Integrações

#### Com Notifi/WhatsApp
- Usa NotificationService existente
- Envia com template_type para roteamento correto

#### Com Timeline
- Adiciona evento de aprovação/rejeição no processo

#### Com Socket.io
- WebSocket atualiza em tempo real quando agendamento é aprovado

---

## Métricas & Dashboard (Futuro)

Dados disponíveis para análise:
- Taxa de aprovação por advogado
- Tempo médio até aprovação
- Horários mais solicitados
- Clientes com mais solicitações
- Taxa de sucesso de sugestões de reagendamento

---

## Support

Para dúvidas técnicas ou melhorias, abra uma issue com tag `G5-79`.

---

**Versão**: 1.0  
**Última Atualização**: 2026-05-13  
**Status**: ✅ Pronto para Produção
