import { ILegalProcessService } from '../interfaces/legal-process.service';
import { ILegalProcessRepository } from '../../repositories/interfaces/legal-process.repository';
import { ITimelineService } from '../interfaces/timeline.service';
import { INotificationService } from '../interfaces/notification.service';
import type { LegalProcess } from '@models';
import type { CreateLegalProcessDTO, UpdateLegalProcessStatusDTO } from '@dtos';
import { NotFoundError } from './errors';
import { TimelineEventType } from '@enums';

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

    const updatedProcess = await this.legalProcessRepository.updateStatus(dto.legalProcessId, dto.newStatus);

    // Side-effect: Timeline
    await this.timelineService.addEvent({
      legalProcessId: updatedProcess.id,
      content: `O status do processo foi alterado para: ${dto.newStatus}`,
      type: 'STATUS_UPDATE',
    });

    // Side-effect: Notification for Client
    await this.notificationService.send({
      userId: updatedProcess.clientId,
      title: 'Atualização no seu processo',
      body: `Seu processo "${updatedProcess.title}" foi atualizado para: ${dto.newStatus}`,
      type: 'STATUS_CHANGED',
    });

    return updatedProcess;
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
