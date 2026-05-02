/// <reference types="node" />

import { test } from 'node:test';
import assert from 'node:assert/strict';
import { LeadService } from './lead.service';

const baseLead = {
  id: 'lead-1',
  whatsappNumber: '5511999999999',
  name: 'Maria',
  email: 'maria@example.com',
  cpf: '12345678901',
  caseType: 'Civil',
  caseDescription: 'Descricao do caso',
  urgency: 'High',
  contactAvailability: 'Morning',
  status: 'PENDING',
  convertedUserId: null,
  lawyerNotes: null,
  discardReason: null,
  createdAt: new Date(),
  updatedAt: new Date(),
};

test('createFromWhatsapp preserves caseDescription and accepts legacy description', async () => {
  let created: any;
  const service = new LeadService(
    {
      findByWhatsapp: async () => null,
      create: async (lead: any) => {
        created = lead;
        return { ...baseLead, ...lead };
      },
    } as any,
    {} as any,
    {} as any,
    {} as any,
    {} as any
  );

  await service.createFromWhatsapp({
    whatsappNumber: '5511999999999',
    email: 'maria@example.com',
    description: 'Texto vindo do bot legado',
  });

  assert.equal(created.email, 'maria@example.com');
  assert.equal(created.caseDescription, 'Texto vindo do bot legado');
});

test('convertToClient creates local password and sends temporary password', async () => {
  const calls: string[] = [];
  let createdUser: any;
  let notificationBody: string | undefined;
  const service = new LeadService(
    {
      findById: async () => baseLead,
      update: async (_id: string, data: any) => ({ ...baseLead, ...data }),
    } as any,
    {
      findByWhatsapp: async () => null,
      create: async (user: any) => {
        createdUser = user;
        return { id: 'user-1', ...user };
      },
      delete: async () => calls.push('delete-user'),
    } as any,
    { generateTempPassword: () => 'TEMP1234' } as any,
    {
      sendPush: async (_userId: string, _title: string, body: string) => {
        notificationBody = body;
        calls.push('send-push');
      },
    } as any,
    { create: async () => calls.push('create-process') } as any
  );

  const result = await service.convertToClient({
    leadId: 'lead-1',
    lawyerId: 'lawyer-1',
  });

  assert.equal(createdUser.email, 'maria@example.com');
  assert.ok(createdUser.passwordHash);
  assert.notEqual(createdUser.passwordHash, 'TEMP1234');
  assert.equal(result.id, 'user-1');
  assert.equal(notificationBody, 'Bem-vindo! Baixe nosso app e use a senha temporária: TEMP1234');
  assert.deepEqual(calls, ['create-process', 'send-push']);
});
