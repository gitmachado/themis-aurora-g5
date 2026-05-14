import { EventEmitter } from 'events';
import type { Notification, Message, Lead, LegalProcess } from '@models';

/**
 * Centralized internal event bus to decouple services from the WebSocket implementation.
 * Services emit events here, and the SocketService listens to them to broadcast to clients.
 */
class InternalEventBus extends EventEmitter {
  private static instance: InternalEventBus;

  private constructor() {
    super();
  }

  public static getInstance(): InternalEventBus {
    if (!InternalEventBus.instance) {
      InternalEventBus.instance = new InternalEventBus();
    }
    return InternalEventBus.instance;
  }

  // Helper methods for typed events
  public emitNotification(userId: string, notification: Notification): void {
    this.emit('notification:new', { userId, notification });
  }

  public emitMessage(whatsappNumber: string, message: Message): void {
    this.emit('message:new', { whatsappNumber, message });
  }

  public emitLeadUpdate(lead: Lead): void {
    this.emit('lead:updated', { lead });
  }

  public emitLeadsReset(): void {
    this.emit('leads:reset');
  }

  public emitLeadLocked(leadId: string, whatsappNumber: string, lawyerId: string, lawyerName: string): void {
    this.emit('lead:locked', { leadId, whatsappNumber, lawyerId, lawyerName });
  }

  public emitLeadUnlocked(leadId: string, whatsappNumber: string): void {
    this.emit('lead:unlocked', { leadId, whatsappNumber });
  }

  public emitLeadDeleted(leadId: string): void {
    this.emit('lead:deleted', { leadId });
  }

  public emitProcedureUpdate(userId: string, procedure: LegalProcess): void {
    this.emit('procedure:updated', { userId, procedure });
  }

  // Appointment events
  public emitAppointmentCreated(userId: string, appointment: any): void {
    this.emit('appointment:created', { userId, appointment });
  }

  public emitAppointmentUpdated(userId: string, appointment: any): void {
    this.emit('appointment:updated', { userId, appointment });
  }

  public emitAppointmentDeleted(userId: string, appointmentId: string): void {
    this.emit('appointment:deleted', { userId, appointmentId });
  }

  public emitAppointmentApproved(lawyerId: string, appointment: any): void {
    this.emit('appointment:approved', { lawyerId, appointment });
    this.emit('pending:appointments:updated', { lawyerId });
  }

  public emitAppointmentRejected(lawyerId: string, appointmentId: string): void {
    this.emit('appointment:rejected', { lawyerId, appointmentId });
    this.emit('pending:appointments:updated', { lawyerId });
  }

  public emitDeadlineReminder(userId: string, appointment: any): void {
    this.emit('deadline:reminder', { userId, appointment });
  }

  public emitRescheduleRequested(lawyerId: string, suggestion: any): void {
    this.emit('reschedule:requested', { lawyerId, suggestion });
  }

  public emitRescheduleAccepted(lawyerId: string, appointment: any): void {
    this.emit('reschedule:accepted', { lawyerId, appointment });
    this.emit('pending:appointments:updated', { lawyerId });
  }

  public emitRescheduleRejected(lawyerId: string, suggestionId: string): void {
    this.emit('reschedule:rejected', { lawyerId, suggestionId });
  }

  public emitDocumentUploaded(userId: string, document: any): void {
    this.emit('document:uploaded', { userId, document });
  }

  public emitDocumentDeleted(userId: string, documentId: string, processId: string): void {
    this.emit('document:deleted', { userId, documentId, processId });
  }
}

export const eventBus = InternalEventBus.getInstance();
