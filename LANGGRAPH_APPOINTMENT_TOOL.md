# Tool LangChain: agendar_compromisso (G5-79)

## Visão Geral
A tool `agendar_compromisso` permite que o bot WhatsApp:
1. **Consultar disponibilidade** da agenda do advogado
2. **Agendar reuniões** com clientes de forma autônoma

## Fluxo Típico

### Cenário 1: Cliente Solicita Reunião
```
Cliente: "Gostaria de marcar uma consulta com o advogado"

Bot (interno):
→ Recupera lawyerId do advogado responsável
→ Usa tool com action="check_availability", date="2026-05-20"

Resposta da tool:
"✓ Horários disponíveis em 2026-05-20: 09:00, 10:00, 11:30, 14:00, 15:30
Apresente essas opções ao cliente e use a ação 'schedule' quando ele escolher uma."

Bot (para cliente): 
"Excelente! Temos disponibilidade em 9:00, 10:00, 11:30, 14:00 ou 15:30. Qual você prefere?"

Cliente: "15:30"

Bot (interno):
→ Usa tool com action="schedule"
  - date: "2026-05-20"
  - time: "15:30"
  - title: "Consulta inicial"
  - clientPhone: "5511987654321"
  - durationMinutes: 60

Resposta da tool:
"✅ Compromisso agendado com sucesso!
Detalhes:
- Título: Consulta inicial
- Data/Hora: 2026-05-20 às 15:30
- Duração: 60 minutos
- ID: appt-xyz123

O cliente receberá uma notificação no app."

Bot (para cliente):
"Perfeito! Sua reunião está marcada para 20 de maio às 15:30. Você receberá uma confirmação no app em breve!"
```

## Parâmetros da Tool

### ✓ Obrigatórios

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `action` | enum | `"check_availability"` ou `"schedule"` |
| `lawyerId` | string | ID do advogado (obtém do contexto/BD) |
| `date` | string | Data em formato `YYYY-MM-DD` |

### Para check_availability
- Nenhum parâmetro adicional obrigatório

### Para schedule
| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|------------|-----------|
| `clientPhone` | string | ✓ | Número WhatsApp do cliente |
| `time` | string | ✓ | Horário em formato `HH:mm` |
| `title` | string | ✓ | Assunto (ex: "Consulta", "Reunião de acompanhamento") |
| `description` | string | ✗ | Detalhes adicionais |
| `durationMinutes` | number | ✗ | Duração em minutos (padrão: 60) |

## Casos de Uso

### 1️⃣ Verificar Disponibilidade
```typescript
// Bot quer mostrar opções ao cliente
await appointmentTool({
  action: "check_availability",
  lawyerId: "lawyer-001",
  date: "2026-05-22"
});

// Resposta: "✓ Horários disponíveis: 09:00, 10:00, 14:00, 16:00..."
```

### 2️⃣ Agendar Reunião
```typescript
// Bot confirma agendamento após cliente escolher horário
await appointmentTool({
  action: "schedule",
  lawyerId: "lawyer-001",
  clientPhone: "5511999887766",
  date: "2026-05-22",
  time: "10:00",
  title: "Consulta inicial - Ação trabalhista",
  description: "Cliente precisa de orientação sobre direitos trabalhistas",
  durationMinutes: 60
});

// Resposta: "✅ Compromisso agendado com sucesso! ID: appt-xyz..."
```

### 3️⃣ Reservação com Duração Customizada
```typescript
await appointmentTool({
  action: "schedule",
  lawyerId: "lawyer-002",
  clientPhone: "5511988776655",
  date: "2026-05-25",
  time: "15:30",
  title: "Reunião - Revisão de contrato",
  durationMinutes: 120  // Reunião mais longa
});
```

## Integração com o Grafo LangGraph

Na definição do seu grafo, a tool é automaticamente disponível:

```typescript
import { appointmentTool } from "./tools";

const tools = [
  // ... outras tools
  appointmentTool,
];

const agent = createReactAgent({
  llm,
  tools,
});
```

O LLM saberá usar `agendar_compromisso` quando detectar intenções de:
- "Marcar consulta" / "Agendar reunião"
- "Qual é sua disponibilidade?"
- "Pode me encaixar nas próximas horas?"

## Fluxo de API Backend

### GET /api/v1/appointments/slots
Retorna horários disponíveis:
```json
{
  "slots": [
    {
      "time": "09:00",
      "isoTime": "2026-05-20T09:00:00Z"
    },
    {
      "time": "10:00",
      "isoTime": "2026-05-20T10:00:00Z"
    }
  ]
}
```

### POST /api/v1/appointments
Cria novo compromisso:
```json
Request:
{
  "lawyerId": "lawyer-001",
  "clientId": "client-123",
  "title": "Consulta inicial",
  "description": "Discussão de caso",
  "type": "MEETING",
  "scheduledAt": "2026-05-20T15:30:00Z",
  "durationMinutes": 60
}

Response:
{
  "id": "appt-xyz123",
  "lawyerId": "lawyer-001",
  "clientId": "client-123",
  "title": "Consulta inicial",
  "scheduledAt": "2026-05-20T15:30:00Z",
  "status": "SCHEDULED"
}
```

## Tratamento de Erros

### Cliente não encontrado
```
Input:
- clientPhone: "5511987654300" (número não registrado)

Resposta:
"Erro ao processar agendamento: Cliente com WhatsApp 5511987654300 
não encontrado na base de dados."
```

### Sem horários disponíveis
```
Input:
- date: "2026-05-20" (dia totalmente ocupado)

Resposta:
"Não há horários disponíveis para o advogado em 2026-05-20. 
Sugira outra data ao cliente."
```

### Conflito de horário
```
Input:
- Horário já ocupado (validado pelo backend)

Resposta:
"Falha ao agendar: Horário indisponível: conflito com outro compromisso"
```

## Validation & Safety

1. **Zod Schema**: Todos os parâmetros são validados antes de enviar ao backend
2. **Backend Validation**: API de compromissos valida conflitos de horário
3. **User Lookup**: Tool verifica se cliente existe no sistema antes de agendar
4. **Error Handling**: Erros são capturados e retornam mensagens descritivas em português

## Próximas Integrações

- ✅ Job de lembretes (G5-79 - Cron) já está rodando (24h antes)
- ⏳ Mobile UI (Flutter) - mostrar agenda atualizada em tempo real
- ⏳ Notificações push - cliente recebe confirmação na hora
- ⏳ Webhook WhatsApp - bot envia confirmação automática para cliente

## Teste Manual

```bash
# Via curl (usando API Key do bot)
curl -X POST http://localhost:3000/api/v1/appointments \
  -H "x-api-key: $BOT_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "lawyerId": "lawyer-001",
    "clientId": "client-123",
    "title": "Teste agendamento",
    "type": "MEETING",
    "scheduledAt": "2026-05-20T15:30:00Z",
    "durationMinutes": 60
  }'
```
