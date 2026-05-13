# Implementação do Cron Job - G5-79

## Resumo
Implementado um agendador de prazos críticos (`DeadlineRemindersJob`) que executa a cada 24 horas para notificar o advogado sobre compromissos/prazos vencendo.

## Arquivos Criados/Modificados

### 1. `server/src/jobs/deadline-reminders.job.ts` (novo)
Classe `DeadlineRemindersJob` que:
- Inicia imediatamente no startup do servidor (para verificação rápida)
- Executa periodicamente a cada 24 horas
- Chama `appointmentService.processDeadlineReminders()` que:
  - Busca prazos vencendo nas próximas 24h
  - Envia notificações push para o advogado
  - Marca os prazos como "reminded" no banco

**Métodos principais:**
- `start()`: Inicia o agendador com intervalo de 24h
- `stop()`: Para o agendador (útil para testes/shutdown)
- `executeReminders()`: Executa a lógica de processamento com tratamento de erros

### 2. `server/src/jobs/index.ts` (novo)
Arquivo de exportação padrão para o módulo de jobs.

### 3. `server/src/server.ts` (modificado)
Adicionada inicialização do job ao startup:
```typescript
const deadlineRemindersJob = new DeadlineRemindersJob(appointmentService);
deadlineRemindersJob.start();
```

**Dependências injetadas:**
- `AppointmentRepository`
- `TimelineService`
- `NotificationService`
- Todas as dependências transitivas (repositories, push notification service)

## Comportamento

### Na Inicialização do Servidor
1. Todas as dependências são criadas
2. `DeadlineRemindersJob` é instanciado
3. Job executa imediatamente: busca prazos vencendo em 24h e notifica
4. Job agenda execução periódica para cada 24 horas

### A Cada 24 Horas
1. Job dispara automaticamente
2. Busca todos os compromissos do tipo "DEADLINE" não notificados vencendo em 24h
3. Para cada prazo:
   - Envia notificação push ao advogado: "⚠️ Prazo Crítico Vencendo Amanhã"
   - Marca o prazo como "reminded: true"

### Tratamento de Erros
- Erros de conexão/banco são logados e não interrompem o servidor
- Logs descritivos indicam sucesso ou falha do job

## Integração com Sistema Existente

### AppointmentService.processDeadlineReminders()
Método existente que:
- Chama `AppointmentRepository.findPendingDeadlineReminders(24)` → busca no BD
- Itera sobre os prazos
- Envia notificações via `NotificationService.send()`
- Atualiza status `reminded` no repositório

### Pipeline de Notificações
```
DeadlineRemindersJob
    ↓
AppointmentService.processDeadlineReminders()
    ↓
NotificationService.send()
    ↓
PushNotificationService (Firebase)
    ↓
Cliente/App do Advogado
```

## O Que Destranca

✅ **Tool LangChain** — Agora é possível implementar `check_availability_and_schedule` com confiança, pois o backend notifica automaticamente prazos críticos.

✅ **Validação End-to-End** — Sistema de agenda agora tem ciclo completo:
- Agenda criada ✓
- Notificações enviadas ✓
- Ciclo de lembretes automático ✓

✅ **Mobile UI** — Interface Flutter pode contar com prazos sendo notificados em tempo (quase) real.

## Próximos Passos

1. **Tool LangChain** (`ai/src/tools/check_availability_and_schedule`)
   - Usar `AppointmentService.getAvailableSlots()`
   - Usar `AppointmentService.create()`
   
2. **Mobile UI** (`mobile/lib/features/lawyer/schedule/`)
   - Integrar com Riverpod para escutar notificações
   - Exibir calendário com prazos/reuniões

## Testes

Todos os 140 testes passam (incluindo testes do AppointmentService):
```bash
npm test
# ✓ 140 passed
```

## Notas Técnicas

- **Sem dependências externas**: Usa apenas `setInterval` (Node.js nativo)
- **Type-safe**: Implementa interface `IAppointmentService`
- **Testável**: Pode ser facilmente mockado nos testes
- **Escalável**: Padrão de job pode ser reutilizado para outras tarefas periódicas
