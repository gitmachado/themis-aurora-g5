/// <reference types="node" />

import { test } from 'node:test';
import assert from 'node:assert/strict';
import { LegalProcessService } from './legal-process.service';
import { NotFoundError } from './errors';

const baseProcess = {
  id: 'process-1',
  clientId: 'client-1',
  lawyerId: 'lawyer-1',
  processNumber: '0001-23',
  title: 'Acao trabalhista',
  description: 'Reclamada deve verbas rescisorias',
  currentStatus: 'OPEN',
  caseType: 'Labor',
  lastNote: null,
  lastMovementDate: null,
  createdAt: new Date(),
  updatedAt: new Date(),
};

test('create persists process with default status OPEN and empty description', async () => {
  let created: any;
  const timelineCalls: any[] = [];
  const service = new LegalProcessService(
    {
      create: async (data: any) => {
        created = data;
        return { ...baseProcess, ...data };
      },
    } as any,
    {
      addEvent: async (e: any) => timelineCalls.push(e),
    } as any,
    {} as any
  );

  await service.create({
    clientId: 'client-1',
    title: 'Novo processo',
  } as any);

  assert.equal(created.currentStatus, 'OPEN');
  assert.equal(created.description, '');
  assert.equal(timelineCalls.length, 1);
  assert.equal(timelineCalls[0].type, 'PROCESS_CREATED');
});

test('create forwards optional fields and adds initial timeline event', async () => {
  let created: any;
  const service = new LegalProcessService(
    {
      create: async (data: any) => {
        created = data;
        return { ...baseProcess, ...data };
      },
    } as any,
    {
      addEvent: async () => undefined,
    } as any,
    {} as any
  );

  await service.create({
    clientId: 'client-1',
    lawyerId: 'lawyer-1',
    processNumber: '0001-23',
    title: 'Acao Trabalhista',
    description: 'detalhes',
    caseType: 'Labor',
  } as any);

  assert.equal(created.lawyerId, 'lawyer-1');
  assert.equal(created.processNumber, '0001-23');
  assert.equal(created.caseType, 'Labor');
});

test('updateStatus throws NotFoundError when process does not exist', async () => {
  const service = new LegalProcessService(
    {
      findById: async () => null,
    } as any,
    {} as any,
    {} as any
  );

  await assert.rejects(
    () =>
      service.updateStatus({
        legalProcessId: 'missing',
        newStatus: 'CLOSED',
        updatedById: 'lawyer-1',
      } as any),
    (err: Error) => err instanceof NotFoundError
  );
});

test('updateStatus emits timeline events for status and lawyer note', async () => {
  const timelineEvents: any[] = [];
  const service = new LegalProcessService(
    {
      findById: async () => baseProcess,
      update: async (_id: string, data: any) => ({ ...baseProcess, ...data }),
    } as any,
    {
      addEvent: async (e: any) => timelineEvents.push(e),
    } as any,
    {
      send: async () => undefined,
    } as any
  );

  await service.updateStatus({
    legalProcessId: 'process-1',
    newStatus: 'IN_PROGRESS',
    lawyerNote: 'Aguardando documentos',
    updatedById: 'lawyer-1',
  } as any);

  const types = timelineEvents.map((e) => e.type);
  assert.deepEqual(types, ['STATUS_UPDATE', 'LAWYER_NOTE']);
});

test('updateStatus skips lawyer-note timeline event when note is omitted', async () => {
  const timelineEvents: any[] = [];
  const service = new LegalProcessService(
    {
      findById: async () => baseProcess,
      update: async (_id: string, data: any) => ({ ...baseProcess, ...data }),
    } as any,
    {
      addEvent: async (e: any) => timelineEvents.push(e),
    } as any,
    {
      send: async () => undefined,
    } as any
  );

  await service.updateStatus({
    legalProcessId: 'process-1',
    newStatus: 'CLOSED',
    updatedById: 'lawyer-1',
  } as any);

  assert.equal(timelineEvents.length, 1);
  assert.equal(timelineEvents[0].type, 'STATUS_UPDATE');
});

test('updateStatus notifies the client about the status change', async () => {
  let notification: any;
  const service = new LegalProcessService(
    {
      findById: async () => baseProcess,
      update: async (_id: string, data: any) => ({ ...baseProcess, ...data }),
    } as any,
    {
      addEvent: async () => undefined,
    } as any,
    {
      send: async (n: any) => {
        notification = n;
      },
    } as any
  );

  await service.updateStatus({
    legalProcessId: 'process-1',
    newStatus: 'IN_PROGRESS',
    updatedById: 'lawyer-1',
  } as any);

  assert.equal(notification.userId, 'client-1');
  assert.equal(notification.type, 'STATUS_CHANGED');
  assert.match(notification.body, /IN_PROGRESS/);
});

test('addNote throws NotFoundError when process does not exist', async () => {
  const service = new LegalProcessService(
    {
      findById: async () => null,
    } as any,
    {} as any,
    {} as any
  );

  await assert.rejects(
    () => service.addNote('missing', 'note', 'lawyer-1'),
    (err: Error) => err instanceof NotFoundError
  );
});

test('getByClientId / getByLawyerId / getById delegate to repository', async () => {
  let calls: string[] = [];
  const service = new LegalProcessService(
    {
      findByClientId: async (id: string) => {
        calls.push(`client:${id}`);
        return [baseProcess];
      },
      findByLawyerId: async (id: string) => {
        calls.push(`lawyer:${id}`);
        return [baseProcess];
      },
      findById: async (id: string) => {
        calls.push(`by-id:${id}`);
        return baseProcess;
      },
    } as any,
    {} as any,
    {} as any
  );

  await service.getByClientId('client-1');
  await service.getByLawyerId('lawyer-1');
  await service.getById('process-1');

  assert.deepEqual(calls, [
    'client:client-1',
    'lawyer:lawyer-1',
    'by-id:process-1',
  ]);
});
