# Análise de Notificações e Listas Socket.io - Feature de Agenda

## 📋 Resumo Executivo

A feature de agenda (appointments) possui várias operações que envolvem mudanças de estado e criação de compromissos. Atualmente, **apenas notificações individuais** (`notification:new`) são propagadas via socket.io, mas **faltam eventos em stream para as listas compartilhadas de agenda**.

---

## 🔍 Estado Atual do Socket.io

### ✅ Eventos Socket.io Implementados

**Em `SocketService.ts`:**

1. **notification:new** - Notificação individual do usuário
   - Emitido para: `user:${userId}`
   - Disparado em: `NotificationService.send()`

2. **lead:updated** - Atualização de lead (não é agenda)
   - Emitido para: `lobby:lawyers`

3. **lead:locked / lead:unlocked** - Bloqueio de leads (não é agenda)
   - Emitido para: `lobby:lawyers`

4. **procedure:updated** - Atualização de processo legal
   - Emitido para: `user:${userId}`

5. **message:new** - Nova mensagem WhatsApp
   - Emitido para: `chat:${normalized}`

---

## ❌ Gaps Identificados na Feature de Agenda

### 1️⃣ **Notificações de Agenda SEM Socket.io Stream**

No `AppointmentService`, as seguintes operações geram notificações **mas não propagam para stream em tempo real**:

#### ✋ APPOINTMENT_SCHEDULED (Create)
- **Localização:** `server/src/services/implementations/appointment.service.ts:62`
- **Evento:** Novo compromisso criado
- **Quem notifica:** Cliente (`clientId`)
- **Problema:** Notificação é enviada, mas:
  - ❌ A lista de agenda do cliente não atualiza em tempo real
  - ❌ A lista pending do advogado não atualiza em tempo real

#### ✋ APPOINTMENT_CHANGED (Update)
- **Localização:** `server/src/services/implementations/appointment.service.ts:111`
- **Evento:** Compromisso foi modificado (data, status, descrição)
- **Quem notifica:** Cliente (`clientId`)
- **Problema:** Notificação é enviada, mas:
  - ❌ A lista de agenda do cliente não atualiza
  - ❌ A lista de agenda do advogado não atualiza

#### ✋ APPOINTMENT_CHANGED (Delete)
- **Localização:** `server/src/services/implementations/appointment.service.ts:133`
- **Evento:** Compromisso foi cancelado
- **Quem notifica:** Cliente (`clientId`)
- **Problema:** Notificação é enviada, mas:
  - ❌ A lista de agenda do cliente não atualiza
  - ❌ A lista de agenda do advogado não atualiza

---

### 2️⃣ **Eventos de Aprovação/Rejeição SEM Socket.io**

No `AppointmentApprovalService`, as seguintes operações geram notificações **mas não propagam via socket.io**:

#### ✋ Aprovação de Compromisso (`approveAppointment`)
- **Localização:** `server/src/services/implementations/appointment-approval.service.ts:43`
- **Evento:** Advogado aprovou um agendamento da IA
- **Notificação:** Cliente recebe "Reunião confirmada ✅"
- **Problema:**
  - ❌ A lista `pending` do advogado não atualiza em tempo real
  - ❌ Não há socket para comunicar mudança de status PENDING_APPROVAL → SCHEDULED

#### ✋ Rejeição de Compromisso (`rejectAppointment`)
- **Localização:** `server/src/services/implementations/appointment-approval.service.ts:79`
- **Evento:** Advogado rejeitou um agendamento da IA
- **Quem notifica:** Cliente
- **Problema:**
  - ❌ A lista `pending` do advogado não atualiza em tempo real
  - ❌ Não há socket para comunicar mudança de status

#### ✋ Reset para Versão IA (`resetToAIVersion`)
- **Evento:** Advogado resetou edições manuais
- **Problema:**
  - ❌ Sem notificação via socket.io para atualizar lista pending

#### ✋ Reagendamento Aceito (`acceptReschedule`)
- **Evento:** Advogado aceitou uma sugestão de reagendamento
- **Problema:**
  - ❌ Sem propagação para atualizar agendas em tempo real

#### ✋ Reagendamento Rejeitado (`rejectReschedule`)
- **Evento:** Advogado rejeitou uma sugestão de reagendamento
- **Problema:**
  - ❌ Sem propagação para atualizar lista de sugestões

---

### 3️⃣ **Lembretes de Prazos SEM Socket.io**

No `AppointmentService.processDeadlineReminders()`:
- **Localização:** `server/src/services/implementations/appointment.service.ts:218`
- **Evento:** Sistema envia lembretes DEADLINE_WARNING
- **Problema:**
  - ❌ Notificação é enviada via `notificationService.send()`
  - ❌ Mas não há propagação de evento para atualizar lista visual de prazos

---

## 📱 Estado Atual do Mobile (Riverpod)

### Providers que Precisam de Refresh

**Em `appointment_providers.dart`:**

```dart
final appointmentsProvider = AsyncNotifierProvider<AppointmentsNotifier, List<Appointment>>
```

**Problema:** O provider NÃO escuta socket.io. Ao criar/atualizar/deletar um compromisso, a tela **recarrega manualmente** via HTTP polling quando:
- Usuário puxa a tela para atualizar (refresh)
- Usuário marca like/completa ação
- Usuário volta da tela de detalhes

**Consequência:** Atualizações não aparecem em tempo real para outros usuários conectados.

---

## 🔧 O Que Precisa Ser Implementado

### **Fase 1: EventBus + Socket Events**

#### 1.1 Adicionar Métodos no `InternalEventBus.ts`

```typescript
// Appointment events
public emitAppointmentCreated(userId: string, appointment: Appointment): void
public emitAppointmentUpdated(userId: string, appointment: Appointment): void
public emitAppointmentDeleted(userId: string, appointmentId: string): void
public emitAppointmentApproved(lawyerId: string, appointment: Appointment): void
public emitAppointmentRejected(lawyerId: string, appointmentId: string): void
public emitPendingAppointmentListUpdated(lawyerId: string): void
public emitDeadlineReminder(userId: string, appointment: Appointment): void
public emitRescheduleRequested(lawyerId: string, suggestion: ReschedulesSuggestion): void
public emitRescheduleAccepted(lawyerId: string, appointment: Appointment): void
public emitRescheduleRejected(lawyerId: string, suggestionId: string): void
```

#### 1.2 Adicionar Listeners em `SocketService.ts`

```typescript
// Appointments
eventBus.on('appointment:created', ({ userId, appointment }) => {
  this.io?.to(`user:${userId}`).emit('appointment:created', appointment);
});

eventBus.on('appointment:updated', ({ userId, appointment }) => {
  this.io?.to(`user:${userId}`).emit('appointment:updated', appointment);
});

eventBus.on('appointment:deleted', ({ userId, appointmentId }) => {
  this.io?.to(`user:${userId}`).emit('appointment:deleted', { appointmentId });
});

eventBus.on('appointment:approved', ({ lawyerId, appointment }) => {
  this.io?.to(`user:${lawyerId}`).emit('appointment:approved', appointment);
  this.io?.to(`user:${lawyerId}`).emit('pending:appointments:updated');
});

eventBus.on('appointment:rejected', ({ lawyerId, appointmentId }) => {
  this.io?.to(`user:${lawyerId}`).emit('appointment:rejected', { appointmentId });
  this.io?.to(`user:${lawyerId}`).emit('pending:appointments:updated');
});

eventBus.on('deadline:reminder', ({ userId, appointment }) => {
  this.io?.to(`user:${userId}`).emit('deadline:reminder', appointment);
});

eventBus.on('reschedule:requested', ({ lawyerId, suggestion }) => {
  this.io?.to(`user:${lawyerId}`).emit('reschedule:requested', suggestion);
});

eventBus.on('reschedule:accepted', ({ lawyerId, appointment }) => {
  this.io?.to(`user:${lawyerId}`).emit('reschedule:accepted', appointment);
  this.io?.to(`user:${lawyerId}`).emit('pending:appointments:updated');
});

eventBus.on('reschedule:rejected', ({ lawyerId, suggestionId }) => {
  this.io?.to(`user:${lawyerId}`).emit('reschedule:rejected', { suggestionId });
});
```

---

### **Fase 2: Disparadores nos Services**

#### 2.1 `AppointmentService.ts`

```typescript
// Em create() - AFTER appointmentRepository.create()
eventBus.emitAppointmentCreated(dto.clientId || lawyerId, appointment);

// Em update() - AFTER appointmentRepository.update()
eventBus.emitAppointmentUpdated(appointment.clientId || lawyerId, updated);

// Em delete() - AFTER appointmentRepository.delete()
eventBus.emitAppointmentDeleted(appointment.clientId || lawyerId, id);
```

#### 2.2 `AppointmentApprovalService.ts`

```typescript
// Em approveAppointment() - AFTER appointmentRepository.approveAppointment()
eventBus.emitAppointmentApproved(lawyerId, updated);

// Em rejectAppointment() - AFTER appointmentRepository.rejectAppointment()
eventBus.emitAppointmentRejected(lawyerId, appointmentId);

// Em acceptReschedule() - AFTER update
eventBus.emitRescheduleAccepted(lawyerId, updatedAppointment);

// Em rejectReschedule() - AFTER delete
eventBus.emitRescheduleRejected(lawyerId, suggestionId);
```

#### 2.3 `AppointmentService.ts` - Lembretes

```typescript
// Em processDeadlineReminders() - AFTER notificationService.send()
eventBus.emitDeadlineReminder(reminder.lawyerId, reminder);
```

---

### **Fase 3: Socket.io Stream no Mobile (Dart)**

#### 3.1 Criar `AppointmentSocketListener` em Riverpod

```dart
// Listeners que atualizam o estado em tempo real
final appointmentSocketListenerProvider = FutureProvider<void>((ref) async {
  final socketClient = ref.watch(webSocketClientProvider);
  
  socketClient.on('appointment:created', (data) {
    ref.read(appointmentsProvider.notifier).addAppointment(data);
  });

  socketClient.on('appointment:updated', (data) {
    ref.read(appointmentsProvider.notifier).updateAppointment(data);
  });

  socketClient.on('appointment:deleted', (data) {
    ref.read(appointmentsProvider.notifier).removeAppointment(data['appointmentId']);
  });

  socketClient.on('pending:appointments:updated', (_) {
    ref.refresh(pendingAppointmentsProvider);
  });

  socketClient.on('deadline:reminder', (data) {
    // Show snackbar or notification
  });
});
```

#### 3.2 Atualizar `AppointmentsNotifier`

```dart
class AppointmentsNotifier extends AsyncNotifier<List<Appointment>> {
  
  void addAppointment(Appointment appointment) {
    state = AsyncValue.data([...state.value ?? [], appointment]);
  }
  
  void updateAppointment(Appointment updated) {
    final current = state.value ?? [];
    final index = current.indexWhere((a) => a.id == updated.id);
    if (index >= 0) {
      current[index] = updated;
      state = AsyncValue.data([...current]);
    }
  }
  
  void removeAppointment(String id) {
    state = AsyncValue.data(
      (state.value ?? []).where((a) => a.id != id).toList()
    );
  }
}
```

#### 3.3 Atualizar `PendingAppointmentsNotifier`

```dart
// Similar pattern para lista de pending
final pendingAppointmentsProvider = 
    AsyncNotifierProvider<PendingAppointmentsNotifier, List<Appointment>>(
  PendingAppointmentsNotifier.new,
);
```

---

## 📊 Matriz de Mudanças Necessárias

| Feature | Backend | Frontend |
|---------|---------|----------|
| Criar Compromisso | ✅ Notificação / ❌ Socket | ❌ Stream |
| Atualizar Compromisso | ✅ Notificação / ❌ Socket | ❌ Stream |
| Deletar Compromisso | ✅ Notificação / ❌ Socket | ❌ Stream |
| Aprovar Pendente | ✅ Notificação / ❌ Socket | ❌ Stream |
| Rejeitar Pendente | ✅ Notificação / ❌ Socket | ❌ Stream |
| Lista Pending | ✅ API / ❌ Stream | ❌ Real-time |
| Lembretes Prazos | ✅ Notificação / ❌ Socket | ❌ Stream |
| Reagendamento | ✅ Notificação / ❌ Socket | ❌ Stream |

---

## 🎯 Prioridade de Implementação

1. **Alta:** `appointment:created`, `appointment:updated`, `appointment:deleted` (afeta user feedback)
2. **Alta:** `pending:appointments:updated` (lista que advogado frequentemente observa)
3. **Média:** `appointment:approved`, `appointment:rejected` 
4. **Média:** `deadline:reminder`
5. **Baixa:** `reschedule:*` (fluxos menos frequentes)

---

## 📝 Checklist de Implementação

### Backend

- [ ] Adicionar métodos emit no `InternalEventBus.ts`
- [ ] Adicionar listeners em `SocketService.ts`
- [ ] Disparar eventos em `AppointmentService.ts` (create/update/delete)
- [ ] Disparar eventos em `AppointmentApprovalService.ts` (approve/reject)
- [ ] Disparar evento de deadline reminder
- [ ] Testar eventos com socket.io cliente

### Frontend (Dart)

- [ ] Criar `AppointmentSocketListener` provider
- [ ] Atualizar `AppointmentsNotifier` com métodos de atualização
- [ ] Atualizar `PendingAppointmentsNotifier`
- [ ] Integrar `appointmentSocketListenerProvider` no main/app screen
- [ ] Testar real-time updates na simulação
- [ ] Verificar sincronização entre múltiplos dispositivos

---

## 🔗 Arquivos Impactados

### Backend
- `server/src/services/communication/InternalEventBus.ts` → Adicionar métodos
- `server/src/services/communication/SocketService.ts` → Adicionar listeners
- `server/src/services/implementations/appointment.service.ts` → Disparar eventos
- `server/src/services/implementations/appointment-approval.service.ts` → Disparar eventos

### Frontend
- `mobile/lib/features/lawyer/schedule/presentation/providers/appointment_providers.dart` → Adicionar listener + notifier methods
- `mobile/lib/shared/network/websocket_client.dart` → Já existe, apenas usar

---

## 📚 Referências

- Socket Event Architecture: `SocketService.ts` (lead:updated pattern)
- Notification Pattern: `NotificationService.ts`
- Riverpod Async Pattern: `appointmentsProvider` (AsyncNotifierProvider)
- WebSocket Client: `mobile/lib/shared/network/websocket_client.dart`
