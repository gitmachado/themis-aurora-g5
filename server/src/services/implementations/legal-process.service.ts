import { ILegalProcessService } from '../interfaces/legal-process.service';
import { ILegalProcessRepository } from '../../repositories/interfaces/legal-process.repository';
import { ITimelineService } from '../interfaces/timeline.service';
import { INotificationService } from '../interfaces/notification.service';
import type { LegalProcess } from '@models';
import type { CreateLegalProcessDTO, UpdateLegalProcessStatusDTO } from '@dtos';
import { NotFoundError } from './errors';
import { formatLegalProcessStatus } from './legal-process-i18n';

export class LegalProcessService implements ILegalProcessService {
  constructor(
    private readonly legalProcessRepository: ILegalProcessRepository,
    private readonly timelineService: ITimelineService,
    private readonly notificationService: INotificationService
  ) {}

  async create(dto: CreateLegalProcessDTO): Promise<LegalProcess> {
    const process = await this.legalProcessRepository.create({
      clientId: dto.clientId,
      lawyerId: dto.lawyerId || null,
      processNumber: dto.processNumber || null,
      title: dto.title,
      description: dto.description || '',
      currentStatus: 'OPEN',
      caseType: dto.caseType || null,
      lastNote: null,
      lastMovementDate: null,
    });

    // Initial timeline event
    await this.timelineService.addEvent({
      legalProcessId: process.id,
      content: `Processo registrado no sistema com status: ${process.currentStatus}`,
      type: 'PROCESS_CREATED',
    });

    return process;
  }

  async updateStatus(dto: UpdateLegalProcessStatusDTO): Promise<LegalProcess> {
    const process = await this.legalProcessRepository.findById(dto.legalProcessId);
    if (!process) {
      throw new NotFoundError('Processo não encontrado');
    }

    const updatedProcess = await this.legalProcessRepository.update(dto.legalProcessId, {
      currentStatus: dto.newStatus,
      lastNote: dto.lawyerNote,
      lastMovementDate: new Date(),
    });

    // Side-effect: Timeline for Status Update
    await this.timelineService.addEvent({
      legalProcessId: updatedProcess.id,
      content: `O status do processo foi alterado para: ${dto.newStatus}`,
      type: 'STATUS_UPDATE',
      createdById: dto.updatedById,
    });

    // Side-effect: Timeline for Note (if provided)
    if (dto.lawyerNote) {
      await this.timelineService.addEvent({
        legalProcessId: updatedProcess.id,
        content: dto.lawyerNote,
        type: 'LAWYER_NOTE',
        createdById: dto.updatedById,
      });
    }

    const statusLabel = formatLegalProcessStatus(dto.newStatus);

    // Side-effect: Notification for Client
    await this.notificationService.send({
      userId: updatedProcess.clientId,
      title: 'Atualização no seu processo',
      body: `Seu processo "${updatedProcess.title}" foi atualizado para: ${statusLabel}`,
      type: 'STATUS_CHANGED',
    });

    // Side-effect: Notification for the assigned lawyer (skip if the lawyer triggered the change themselves)
    if (updatedProcess.lawyerId && updatedProcess.lawyerId !== dto.updatedById) {
      await this.notificationService.send({
        userId: updatedProcess.lawyerId,
        title: 'Status do processo atualizado',
        body: `O processo "${updatedProcess.title}" mudou de status para: ${statusLabel}`,
        type: 'STATUS_CHANGED',
      });
    }

    return updatedProcess;
  }

  async addNote(processId: string, note: string, lawyerId: string): Promise<void> {
    const process = await this.legalProcessRepository.findById(processId);
    if (!process) {
      throw new NotFoundError('Processo não encontrado');
    }

    // Update last note in process
    await this.legalProcessRepository.update(processId, {
      lastNote: note,
      lastMovementDate: new Date(),
    });

    // Add to timeline
    await this.timelineService.addEvent({
      legalProcessId: processId,
      content: note,
      type: 'LAWYER_NOTE',
      createdById: lawyerId,
    });

    // Notify client
    await this.notificationService.send({
      userId: process.clientId,
      title: 'Nova nota no seu processo',
      body: `O advogado adicionou uma nova observação ao seu processo "${process.title}"`,
      type: 'NEW_NOTE',
    });
  }

  async requestDocument(processId: string, documentName: string, lawyerId: string): Promise<void> {
    const process = await this.legalProcessRepository.findById(processId);
    if (!process) throw new NotFoundError('Processo não encontrado');

    const content = `Solicitação de documento: ${documentName}`;
    
    // Update last note
    await this.legalProcessRepository.update(processId, {
      lastNote: content,
      lastMovementDate: new Date(),
      currentStatus: 'AWAITING_DOCUMENT',
    });

    // Add to timeline
    await this.timelineService.addEvent({
      legalProcessId: processId,
      content,
      type: 'DOCUMENT_REQUESTED',
      createdById: lawyerId,
    });

    // Notify client
    await this.notificationService.send({
      userId: process.clientId,
      title: 'Documento solicitado',
      body: `O advogado solicitou o documento: ${documentName}`,
      type: 'DOCUMENT_REQUESTED',
    });
  }

  async scheduleEvent(processId: string, eventTitle: string, date: Date, lawyerId: string): Promise<void> {
    const process = await this.legalProcessRepository.findById(processId);
    if (!process) throw new NotFoundError('Processo não encontrado');

    const content = `Evento agendado: ${eventTitle} para ${date.toLocaleDateString('pt-BR')}`;

    // Add to timeline
    await this.timelineService.addEvent({
      legalProcessId: processId,
      content,
      type: 'EVENT_SCHEDULED',
      createdById: lawyerId,
      metadata: { scheduledAt: date.toISOString() },
    });

    // Notify client
    await this.notificationService.send({
      userId: process.clientId,
      title: 'Novo compromisso agendado',
      body: `Um novo evento foi agendado no seu processo: ${eventTitle}`,
      type: 'STATUS_CHANGED',
    });
  }

  async getByClientId(clientId: string): Promise<LegalProcess[]> {
    return this.legalProcessRepository.findByClientId(clientId);
  }

  async getByLawyerId(lawyerId: string): Promise<LegalProcess[]> {
    return this.legalProcessRepository.findByLawyerId(lawyerId);
  }

  async getById(id: string): Promise<LegalProcess | null> {
    return this.legalProcessRepository.findById(id);
  }
}
