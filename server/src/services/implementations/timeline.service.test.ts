/// <reference types="node" />

import { test } from 'node:test';
import assert from 'node:assert/strict';
import { TimelineService } from './timeline.service';

const baseEvent = {
  id: 'event-1',
  legalProcessId: 'process-1',
  content: 'Audiencia agendada',
  type: 'NOTE',
  metadata: null,
  previousStatus: null,
  createdById: 'user-1',
  createdAt: new Date(),
};

test('addEvent persists with default null metadata when not provided', async () => {
  let createdPayload: any;
  const service = new TimelineService({
    create: async (data: any) => {
      createdPayload = data;
      return { ...baseEvent, ...data };
    },
  } as any);

  await service.addEvent({
    legalProcessId: 'process-1',
    content: 'Audiencia agendada',
    type: 'NOTE',
    createdById: 'user-1',
  } as any);

  assert.equal(createdPayload.metadata, null);
  assert.equal(createdPayload.previousStatus, null);
});

test('addEvent forwards metadata when caller provides it', async () => {
  let createdPayload: any;
  const service = new TimelineService({
    create: async (data: any) => {
      createdPayload = data;
      return { ...baseEvent, ...data };
    },
  } as any);

  await service.addEvent({
    legalProcessId: 'process-1',
    content: 'Documento enviado',
    type: 'DOCUMENT',
    metadata: { docId: 'doc-1' },
  } as any);

  assert.deepEqual(createdPayload.metadata, { docId: 'doc-1' });
});

test('addEvent stores null createdById when caller omits it', async () => {
  let createdPayload: any;
  const service = new TimelineService({
    create: async (data: any) => {
      createdPayload = data;
      return { ...baseEvent, ...data };
    },
  } as any);

  await service.addEvent({
    legalProcessId: 'process-1',
    content: 'Status atualizado',
    type: 'STATUS',
  } as any);

  assert.equal(createdPayload.createdById, null);
});

test('getByLegalProcess delegates to repository.findByLegalProcessId', async () => {
  let receivedId: string | undefined;
  const service = new TimelineService({
    findByLegalProcessId: async (id: string) => {
      receivedId = id;
      return [baseEvent];
    },
  } as any);

  const events = await service.getByLegalProcess('process-42');

  assert.equal(receivedId, 'process-42');
  assert.equal(events.length, 1);
});

test('getByLegalProcess returns empty list when repository has no events', async () => {
  const service = new TimelineService({
    findByLegalProcessId: async () => [],
  } as any);

  const events = await service.getByLegalProcess('process-empty');

  assert.deepEqual(events, []);
});
