/// <reference types="node" />

import { test, describe, beforeEach, mock } from 'node:test';
import assert from 'node:assert/strict';
import { AppointmentService } from './appointment.service';
import { ConflictError, NotFoundError } from './errors';
import type { IAppointmentRepository } from '../../repositories/interfaces/appointment.repository';
import type { ITimelineService } from '../interfaces/timeline.service';
import type { INotificationService } from '../interfaces/notification.service';
import type { Appointment } from '@models';

const mockAppointment: Appointment = {
  id: '1',
  lawyerId: 'lawyer-1',
  clientId: 'client-1',
  processId: null,
  title: 'Test Meeting',
  description: null,
  type: 'MEETING',
  scheduledAt: new Date('2026-05-15T14:00:00Z'),
  durationMinutes: 60,
  status: 'SCHEDULED',
  reminded: false,
  createdByAI: false,
  aiCreatedAt: null,
  approvedByLawyerId: null,
  approvedAt: null,
  aiOriginalData: null,
  clientName: null,
  clientWhatsappNumber: null,
  createdAt: new Date(),
  updatedAt: new Date(),
};

const makeRepo = (overrides: Partial<IAppointmentRepository> = {}): IAppointmentRepository => ({
  findById: async () => mockAppointment,
  findByLawyerId: async () => [mockAppointment],
  findByClientId: async () => [mockAppointment],
  findByClientWhatsapp: async () => [mockAppointment],
  findByProcessId: async () => [mockAppointment],
  findConflicts: async () => [],
  findPendingDeadlineReminders: async () => [],
  create: async () => mockAppointment,
  update: async () => mockAppointment,
  delete: async () => {},
  ...overrides,
});

const makeTimeline = (): ITimelineService => ({
  addEvent: async () => ({} as any),
  getByLegalProcess: async () => [],
});

const makeNotification = (): INotificationService => ({
  send: async () => null,
  sendPush: async () => {},
  getById: async () => null,
  getByUser: async () => [],
  getUnread: async () => [],
  markAsRead: async () => {},
  markAllAsRead: async () => {},
  delete: async () => {},
  deleteMany: async () => {},
});

describe('AppointmentService', () => {
  test('should create appointment without conflicts', async () => {
    const service = new AppointmentService(makeRepo(), makeTimeline(), makeNotification());

    const dto = {
      clientId: 'client-1',
      title: 'Meeting',
      type: 'MEETING' as const,
      scheduledAt: new Date('2026-05-15T14:00:00Z'),
      durationMinutes: 60,
    };

    const result = await service.create(dto, 'lawyer-1');
    assert.equal(result.id, '1');
  });

  test('should throw ConflictError when time slot has conflicts', async () => {
    const repo = makeRepo({
      findConflicts: async () => [mockAppointment],
    });

    const service = new AppointmentService(repo, makeTimeline(), makeNotification());

    const dto = {
      title: 'Conflicting',
      type: 'MEETING' as const,
      scheduledAt: new Date('2026-05-15T14:00:00Z'),
      durationMinutes: 60,
    };

    await assert.rejects(() => service.create(dto, 'lawyer-1'), ConflictError);
  });

  test('should create timeline event when processId provided', async () => {
    let timelineCalled = false;
    const timeline: ITimelineService = {
      addEvent: async () => { timelineCalled = true; return {} as any; },
      getByLegalProcess: async () => [],
    };

    const service = new AppointmentService(makeRepo(), timeline, makeNotification());

    await service.create(
      {
        processId: 'process-1',
        title: 'Hearing',
        type: 'HEARING',
        scheduledAt: new Date('2026-05-15T14:00:00Z'),
      },
      'lawyer-1'
    );

    assert.ok(timelineCalled);
  });

  test('should throw NotFoundError when updating non-existent appointment', async () => {
    const repo = makeRepo({
      findById: async () => null,
    });

    const service = new AppointmentService(repo, makeTimeline(), makeNotification());

    await assert.rejects(
      () => service.update('999', { title: 'Updated' }, 'lawyer-1'),
      NotFoundError
    );
  });

  test('should throw ConflictError when updating appointment of another lawyer', async () => {
    const service = new AppointmentService(makeRepo(), makeTimeline(), makeNotification());

    await assert.rejects(
      () => service.update('1', { title: 'Updated' }, 'other-lawyer'),
      ConflictError
    );
  });

  test('should return available slots for a given date', async () => {
    const repo = makeRepo({
      findByLawyerId: async () => [],
    });

    const service = new AppointmentService(repo, makeTimeline(), makeNotification());

    const date = new Date('2026-05-15T00:00:00Z');
    const slots = await service.getAvailableSlots('lawyer-1', date, 60);

    assert.ok(slots.length > 0);
  });

  test('should exclude booked slots from available slots', async () => {
    const date = new Date('2026-05-15');
    const bookedStart = new Date(date);
    bookedStart.setHours(12, 0, 0, 0);

    const bookedAppointment: Appointment = {
      ...mockAppointment,
      scheduledAt: bookedStart,
      durationMinutes: 60,
    };

    const repo = makeRepo({
      findByLawyerId: async () => [bookedAppointment],
    });

    const service = new AppointmentService(repo, makeTimeline(), makeNotification());

    const slots = await service.getAvailableSlots('lawyer-1', date, 60);

    const conflictSlots = slots.filter(slot => {
      return slot.getTime() === bookedStart.getTime();
    });

    assert.equal(conflictSlots.length, 0);
  });

  test('should process deadline reminders and mark as reminded', async () => {
    const deadlineAppointment: Appointment = {
      ...mockAppointment,
      type: 'DEADLINE',
      reminded: false,
    };

    let updateCalled = false;
    let notifSent = false;

    const repo = makeRepo({
      findPendingDeadlineReminders: async () => [deadlineAppointment],
      update: async () => { updateCalled = true; return deadlineAppointment; },
    });

    const notification: INotificationService = {
      send: async () => { notifSent = true; return null; },
      sendPush: async () => {},
      getById: async () => null,
      getByUser: async () => [],
      getUnread: async () => [],
      markAsRead: async () => {},
      markAllAsRead: async () => {},
      delete: async () => {},
      deleteMany: async () => {},
    };

    const service = new AppointmentService(repo, makeTimeline(), notification);
    await service.processDeadlineReminders();

    assert.ok(notifSent);
    assert.ok(updateCalled);
  });

  test('should delete appointment and notify client', async () => {
    let notifSent = false;
    let deleteCalled = false;

    const repo = makeRepo({
      delete: async () => { deleteCalled = true; },
    });

    const notification: INotificationService = {
      send: async () => { notifSent = true; return null; },
      sendPush: async () => {},
      getById: async () => null,
      getByUser: async () => [],
      getUnread: async () => [],
      markAsRead: async () => {},
      markAllAsRead: async () => {},
      delete: async () => {},
      deleteMany: async () => {},
    };

    const service = new AppointmentService(repo, makeTimeline(), notification);
    await service.delete('1', 'lawyer-1');

    assert.ok(deleteCalled);
    assert.ok(notifSent);
  });

  test('should exclude self from conflict check when excludeId provided', async () => {
    const repo = makeRepo({
      findConflicts: async () => [mockAppointment],
    });

    const service = new AppointmentService(repo, makeTimeline(), makeNotification());

    const conflicts = await service.checkConflicts(
      'lawyer-1',
      new Date('2026-05-15T14:00:00Z'),
      60,
      '1'
    );

    assert.equal(conflicts.length, 0);
  });
});
