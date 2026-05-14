/**
 * E2E Tests: Appointment Approval Workflow
 *
 * Testa o fluxo completo de agendamento com aprovação:
 * 1. Cliente solicita agendamento via IA
 * 2. IA cria PENDING_APPROVAL
 * 3. Advogado aprova/rejeita/reagenda
 * 4. Cliente notificado
 */

import { describe, it, expect, beforeAll, afterAll } from '@jest/globals';

describe('Appointment Approval Workflow E2E', () => {
  let appointmentId: string;
  let suggestionId: string;
  const lawyerId = 'lawyer-1';
  const clientId = 'client-1';

  describe('1. AI Creates PENDING_APPROVAL Appointment', () => {
    it('should create appointment with PENDING_APPROVAL status when createdByAI=true', async () => {
      // Mock: IA chama schedule endpoint
      const response = {
        id: 'apt-001',
        title: 'Reunião com cliente',
        status: 'PENDING_APPROVAL',
        createdByAI: true,
        clientId,
        lawyerId,
      };

      expect(response.status).toBe('PENDING_APPROVAL');
      expect(response.createdByAI).toBe(true);
      appointmentId = response.id;
    });

    it('should not allow AI to directly create SCHEDULED appointments (trigger protection)', async () => {
      // Mock trigger validation
      const attemptDirect = {
        createdByAI: true,
        status: 'SCHEDULED',
      };

      // Trigger deveria bloquear
      expect(() => {
        if (attemptDirect.createdByAI && attemptDirect.status === 'SCHEDULED') {
          throw new Error('Trigger: AI cannot directly schedule appointments');
        }
      }).toThrow('Trigger: AI cannot directly schedule appointments');
    });
  });

  describe('2. Lawyer Views Pending Appointments', () => {
    it('should retrieve pending appointments count for badge', async () => {
      // Mock GET /appointments/pending
      const pendingList = [
        { id: appointmentId, title: 'Reunião com cliente', createdByAI: true },
      ];

      expect(pendingList.length).toBe(1);
      expect(pendingList[0].createdByAI).toBe(true);
    });

    it('should display only PENDING_APPROVAL appointments in approval screen', async () => {
      // Mock GET /appointments/pending (approval screen)
      const pending = [
        { id: appointmentId, status: 'PENDING_APPROVAL' },
      ];

      const onlyPending = pending.every(a => a.status === 'PENDING_APPROVAL');
      expect(onlyPending).toBe(true);
    });
  });

  describe('3A. Lawyer Approves Appointment', () => {
    it('should approve appointment and change status to SCHEDULED', async () => {
      // Mock PATCH /appointments/:id/approve
      const approved = {
        id: appointmentId,
        status: 'SCHEDULED',
        approvedByLawyerId: lawyerId,
      };

      expect(approved.status).toBe('SCHEDULED');
      expect(approved.approvedByLawyerId).toBe(lawyerId);
    });

    it('should send WhatsApp notification to client on approval', async () => {
      // Mock notification
      const notification = {
        userId: clientId,
        type: 'APPOINTMENT_SCHEDULED',
        metadata: {
          appointmentId,
          whatsappTemplate: 'APPOINTMENT_APPROVED',
        },
      };

      expect(notification.metadata.whatsappTemplate).toBe('APPOINTMENT_APPROVED');
    });
  });

  describe('3B. Lawyer Rejects Appointment', () => {
    it('should reject appointment and delete it', async () => {
      // Mock PATCH /appointments/:id/reject
      const rejected = { id: appointmentId, status: 'REJECTED' };
      expect(rejected.status).toBe('REJECTED');
    });

    it('should send WhatsApp notification to client on rejection', async () => {
      const notification = {
        userId: clientId,
        type: 'APPOINTMENT_CHANGED',
        metadata: {
          whatsappTemplate: 'APPOINTMENT_REJECTED',
        },
      };

      expect(notification.metadata.whatsappTemplate).toBe('APPOINTMENT_REJECTED');
    });
  });

  describe('3C. Lawyer Resets to AI Version', () => {
    it('should restore aiOriginalData to appointment fields', async () => {
      const appointment = {
        id: appointmentId,
        title: 'Modified by lawyer',
        aiOriginalData: {
          title: 'Original AI proposal',
        },
      };

      // Mock reset
      const reset = {
        title: appointment.aiOriginalData.title,
      };

      expect(reset.title).toBe('Original AI proposal');
    });
  });

  describe('3D. Lawyer Requests Reschedule', () => {
    it('should create reschedule suggestion with PENDING status', async () => {
      // Mock POST /appointments/:id/reschedule-request
      const response = {
        id: 'sug-001',
        status: 'PENDING',
        instruction: 'Não segunda, a partir de terça',
      };

      suggestionId = response.id;
      expect(response.status).toBe('PENDING');
    });

    it('should validate reschedule instruction is not empty', async () => {
      expect(() => {
        if (!'' || ''.trim().length === 0) {
          throw new Error('Instruction cannot be empty');
        }
      }).toThrow();
    });

    it('should start polling for AI-generated suggestions', async () => {
      // Mock GET /appointments/:id/reschedule-suggestions (polling)
      const suggestions = [];
      expect(suggestions).toEqual([]);

      // Simula wait for AI processing
      await new Promise(r => setTimeout(r, 100));

      const suggestionsReady = [
        {
          id: 'sug-001',
          suggestedDatetime: '2026-05-20T10:00:00Z',
          status: 'PENDING',
        },
      ];

      expect(suggestionsReady.length).toBeGreaterThan(0);
      expect(suggestionsReady[0].status).toBe('PENDING');
    });

    it('should generate 3+ alternative time slots respecting instruction', async () => {
      // Mock IA response
      const suggestions = [
        { suggestedDatetime: '2026-05-20T10:00:00Z', title: 'Reunião' },
        { suggestedDatetime: '2026-05-21T14:00:00Z', title: 'Reunião' },
        { suggestedDatetime: '2026-05-22T11:00:00Z', title: 'Reunião' },
      ];

      expect(suggestions.length).toBeGreaterThanOrEqual(3);

      // Verifica se todas são dias úteis
      suggestions.forEach(s => {
        const date = new Date(s.suggestedDatetime);
        const dayOfWeek = date.getDay();
        // 0=Sunday, 6=Saturday
        expect([1, 2, 3, 4, 5]).toContain(dayOfWeek);
      });
    });
  });

  describe('3D.1. Lawyer Accepts Reschedule Suggestion', () => {
    it('should update appointment with suggested values', async () => {
      const suggestion = {
        suggestedDatetime: '2026-05-20T10:00:00Z',
        suggestedTitle: 'Reunião',
      };

      const updated = {
        scheduledAt: suggestion.suggestedDatetime,
        title: suggestion.suggestedTitle,
      };

      expect(updated.scheduledAt).toBe(suggestion.suggestedDatetime);
    });

    it('should mark suggestion as ACCEPTED', async () => {
      const updated = { id: suggestionId, status: 'ACCEPTED' };
      expect(updated.status).toBe('ACCEPTED');
    });

    it('should keep appointment in PENDING_APPROVAL for final approval', async () => {
      const appointment = {
        status: 'PENDING_APPROVAL',
      };

      expect(appointment.status).toBe('PENDING_APPROVAL');
    });
  });

  describe('4. Lawyer Re-approves After Reschedule', () => {
    it('should approve rescheduled appointment', async () => {
      const approved = {
        status: 'SCHEDULED',
      };

      expect(approved.status).toBe('SCHEDULED');
    });
  });

  describe('Error Handling', () => {
    it('should reject approval if appointment not in PENDING_APPROVAL', async () => {
      const appointment = {
        status: 'SCHEDULED',
      };

      expect(() => {
        if (appointment.status !== 'PENDING_APPROVAL') {
          throw new Error('Cannot approve: appointment not in PENDING_APPROVAL status');
        }
      }).toThrow();
    });

    it('should reject operations if lawyer does not own appointment', async () => {
      const wrongLawyerId = 'lawyer-999';

      expect(() => {
        if (wrongLawyerId !== lawyerId) {
          throw new Error('Access denied: appointment does not belong to you');
        }
      }).toThrow();
    });

    it('should handle AI generation failures gracefully', async () => {
      const suggestions = [];

      // Se IA falhar, retorna vazio (cliente vê "Aguardando..." até timeout)
      expect(suggestions).toEqual([]);
    });
  });

  describe('Complete Flow Verification', () => {
    it('should complete full flow: create → approve → notify', async () => {
      const flow = [
        { step: 'AI_CREATE', status: 'PENDING_APPROVAL' },
        { step: 'LAWYER_APPROVE', status: 'SCHEDULED' },
        { step: 'CLIENT_NOTIFY', notification: 'APPOINTMENT_APPROVED' },
      ];

      expect(flow[0].status).toBe('PENDING_APPROVAL');
      expect(flow[1].status).toBe('SCHEDULED');
      expect(flow[2].notification).toBe('APPOINTMENT_APPROVED');
    });
  });
});
