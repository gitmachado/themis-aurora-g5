/// <reference types="node" />

import { test } from 'node:test';
import assert from 'node:assert/strict';
import bcrypt from 'bcryptjs';
import { UserService } from './user.service';
import {
  NotFoundError,
  ConflictError,
  ValidationError,
  UnauthorizedError,
} from './errors';

const baseUser = {
  id: 'user-1',
  name: 'Maria',
  whatsappNumber: '5511999999999',
  cpf: '12345678901',
  email: 'maria@example.com',
  avatarUrl: null,
  role: 'CLIENT' as const,
  passwordHash: null as string | null,
  fcmToken: null,
  notificationPreferences: { push: true, whatsapp: true },
  teamPermissions: {},
  lawyerAdminId: null,
  oabNumber: null,
  specialty: null,
  mustChangePassword: false,
  createdAt: new Date(),
  updatedAt: new Date(),
};

test('create rejects with ConflictError when whatsapp is taken', async () => {
  const service = new UserService({
    findByWhatsapp: async () => baseUser,
  } as any);

  await assert.rejects(
    () =>
      service.create({
        name: 'Pedro',
        whatsappNumber: '5511999999999',
        role: 'CLIENT',
      } as any),
    (err: Error) => err instanceof ConflictError
  );
});

test('create persists user with sane defaults when optional fields are missing', async () => {
  let createdPayload: any;
  const service = new UserService({
    findByWhatsapp: async () => null,
    create: async (data: any) => {
      createdPayload = data;
      return { id: 'new-user', ...data };
    },
  } as any);

  await service.create({
    name: 'Pedro',
    whatsappNumber: '5511888888888',
    role: 'CLIENT',
  } as any);

  assert.equal(createdPayload.cpf, null);
  assert.equal(createdPayload.email, null);
  assert.deepEqual(createdPayload.notificationPreferences, {
    push: true,
    whatsapp: true,
  });
  assert.equal(createdPayload.mustChangePassword, false);
});

test('update throws NotFoundError when user does not exist', async () => {
  const service = new UserService({
    findById: async () => null,
  } as any);

  await assert.rejects(
    () => service.update('missing', { name: 'X' } as any),
    (err: Error) => err instanceof NotFoundError
  );
});

test('delete throws NotFoundError when user does not exist', async () => {
  const service = new UserService({
    findById: async () => null,
  } as any);

  await assert.rejects(
    () => service.delete('missing'),
    (err: Error) => err instanceof NotFoundError
  );
});

test('hardDeleteClient throws NotFoundError when client does not exist at all', async () => {
  const service = new UserService({
    findClientByLawyerId: async () => null,
    findById: async () => null,
  } as any);

  await assert.rejects(
    () => service.hardDeleteClient('lawyer-1', 'missing'),
    (err: Error) => err instanceof NotFoundError
  );
});

test('hardDeleteClient throws UnauthorizedError when client belongs to another lawyer', async () => {
  const service = new UserService({
    findClientByLawyerId: async () => null,
    findById: async () => baseUser,
  } as any);

  await assert.rejects(
    () => service.hardDeleteClient('lawyer-1', 'user-1'),
    (err: Error) => err instanceof UnauthorizedError
  );
});

test('hardDeleteClient delegates to repository when client belongs to lawyer', async () => {
  let deletedId: string | undefined;
  const service = new UserService({
    findClientByLawyerId: async () => baseUser,
    hardDeleteClient: async (id: string) => {
      deletedId = id;
    },
  } as any);

  await service.hardDeleteClient('lawyer-1', 'user-1');

  assert.equal(deletedId, 'user-1');
});

test('changePassword rejects new password shorter than 6 chars', async () => {
  const service = new UserService({
    findById: async () => baseUser,
  } as any);

  await assert.rejects(
    () => service.changePassword('user-1', '12345', 'current'),
    (err: Error) => err instanceof ValidationError
  );
});

test('changePassword requires current password when mustChangePassword is false', async () => {
  const service = new UserService({
    findById: async () => baseUser,
  } as any);

  await assert.rejects(
    () => service.changePassword('user-1', 'newPassword'),
    (err: Error) => err instanceof ValidationError
  );
});

test('changePassword rejects when current password does not match', async () => {
  const passwordHash = await bcrypt.hash('actualCurrent', 4);
  const service = new UserService({
    findById: async () => ({ ...baseUser, passwordHash }),
  } as any);

  await assert.rejects(
    () => service.changePassword('user-1', 'newPassword', 'wrongCurrent'),
    (err: Error) => err instanceof UnauthorizedError
  );
});

test('changePassword updates passwordHash and clears mustChangePassword', async () => {
  let updatePayload: any;
  const service = new UserService({
    findById: async () => ({ ...baseUser, mustChangePassword: true }),
    update: async (_id: string, data: any) => {
      updatePayload = data;
      return { ...baseUser, ...data };
    },
  } as any);

  await service.changePassword('user-1', 'newSecret123');

  assert.notEqual(updatePayload.passwordHash, 'newSecret123');
  assert.ok(await bcrypt.compare('newSecret123', updatePayload.passwordHash));
  assert.equal(updatePayload.mustChangePassword, false);
});

test('getClientsByLawyerId delegates to repository.findClientsByLawyerId', async () => {
  let receivedId: string | undefined;
  const service = new UserService({
    findClientsByLawyerId: async (id: string) => {
      receivedId = id;
      return [baseUser];
    },
  } as any);

  const clients = await service.getClientsByLawyerId('lawyer-9');

  assert.equal(receivedId, 'lawyer-9');
  assert.equal(clients.length, 1);
});
