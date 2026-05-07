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

  public emitProcedureUpdate(userId: string, procedure: LegalProcess): void {
    this.emit('procedure:updated', { userId, procedure });
  }
}

export const eventBus = InternalEventBus.getInstance();
