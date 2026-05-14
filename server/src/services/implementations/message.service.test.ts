/// <reference types="node" />

import { test } from 'node:test';
import assert from 'node:assert/strict';
import { MessageService } from './message.service';

const baseMessage = {
  id: 'msg-1',
  leadId: null as string | null,
  userId: null as string | null,
  whatsappNumber: '5511999999999',
  content: 'Hello',
  sender: 'BOT',
  whatsappMessageId: null,
  createdAt: new Date(),
};

test('saveFromBot resolves whatsapp number to userId when user is registered', async () => {
  let createdPayload: any;
  const service = new MessageService(
    {
      create: async (data: any) => {
        createdPayload = data;
        return { ...baseMessage, ...data };
      },
    } as any,
    {
      findByWhatsapp: async () => ({ id: 'user-7' }),
    } as any,
    {
      findByWhatsapp: async () => null,
    } as any,
    { sendText: async () => 'wa-id' } as any
  );

  await service.saveFromBot({
    whatsappNumber: '5511999999999',
    content: 'Olá',
    sender: 'CLIENT',
  } as any);

  assert.equal(createdPayload.userId, 'user-7');
  assert.equal(createdPayload.leadId, null);
});

test('saveFromBot resolves whatsapp number to leadId when no user is registered', async () => {
  let createdPayload: any;
  const service = new MessageService(
    {
      create: async (data: any) => {
        createdPayload = data;
        return { ...baseMessage, ...data };
      },
    } as any,
    {
      findByWhatsapp: async () => null,
    } as any,
    {
      findByWhatsapp: async () => ({ id: 'lead-9' }),
    } as any,
    { sendText: async () => 'wa-id' } as any
  );

  await service.saveFromBot({
    whatsappNumber: '5511999999999',
    content: 'Pre-cadastro',
    sender: 'CLIENT',
  } as any);

  assert.equal(createdPayload.leadId, 'lead-9');
  assert.equal(createdPayload.userId, null);
});

test('saveFromBot saves message even when no user nor lead are linked', async () => {
  let createdPayload: any;
  const service = new MessageService(
    {
      create: async (data: any) => {
        createdPayload = data;
        return { ...baseMessage, ...data };
      },
    } as any,
    {
      findByWhatsapp: async () => null,
    } as any,
    {
      findByWhatsapp: async () => null,
    } as any,
    { sendText: async () => 'wa-id' } as any
  );

  const result = await service.saveFromBot({
    whatsappNumber: '5511999999999',
    content: 'Mensagem orfa',
    sender: 'BOT',
  } as any);

  assert.equal(createdPayload.userId, null);
  assert.equal(createdPayload.leadId, null);
  assert.equal(result.content, 'Mensagem orfa');
});

test('saveFromBot honors explicit userId / leadId from caller without lookup', async () => {
  let lookups = 0;
  let createdPayload: any;
  const service = new MessageService(
    {
      create: async (data: any) => {
        createdPayload = data;
        return { ...baseMessage, ...data };
      },
    } as any,
    {
      findByWhatsapp: async () => {
        lookups += 1;
        return null;
      },
    } as any,
    {
      findByWhatsapp: async () => {
        lookups += 1;
        return null;
      },
    } as any,
    { sendText: async () => 'wa-id' } as any
  );

  await service.saveFromBot({
    userId: 'user-explicit',
    whatsappNumber: '5511999999999',
    content: 'fixed',
    sender: 'BOT',
  } as any);

  assert.equal(lookups, 0);
  assert.equal(createdPayload.userId, 'user-explicit');
});

test('sendMessage persists with sender LAWYER and triggers whatsapp dispatch', async () => {
  let createdPayload: any;
  const sentTexts: string[] = [];
  const service = new MessageService(
    {
      create: async (data: any) => {
        createdPayload = data;
        return { ...baseMessage, ...data };
      },
    } as any,
    {
      findByWhatsapp: async () => ({ id: 'user-7' }),
    } as any,
    {
      findByWhatsapp: async () => null,
    } as any,
    {
      sendText: async (_to: string, text: string) => {
        sentTexts.push(text);
        return 'wa-id';
      },
    } as any
  );

  await service.sendMessage({
    whatsappNumber: '5511999999999',
    content: 'Boa tarde',
  } as any);

  // Permite que o dispatch async resolva sem esperar.
  await new Promise((r) => setImmediate(r));

  assert.equal(createdPayload.sender, 'LAWYER');
  assert.equal(createdPayload.userId, 'user-7');
  assert.deepEqual(sentTexts, ['Boa tarde']);
});

test('getHistoryByPhone sorts messages chronologically', async () => {
  const older = new Date('2024-01-01T10:00:00Z');
  const newer = new Date('2024-01-01T11:00:00Z');

  const service = new MessageService(
    {
      findByWhatsappNumber: async () => [
        { ...baseMessage, id: 'b', createdAt: newer },
        { ...baseMessage, id: 'a', createdAt: older },
      ],
    } as any,
    {} as any,
    {} as any,
    {} as any
  );

  const history = await service.getHistoryByPhone('5511999999999');

  assert.equal(history[0].id, 'a');
  assert.equal(history[1].id, 'b');
});
