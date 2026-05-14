/// <reference types="node" />

import { test } from 'node:test';
import assert from 'node:assert/strict';
import bcrypt from 'bcryptjs';

process.env.JWT_SECRET = process.env.JWT_SECRET || 'test-secret';

import { AuthService } from './auth.service';
import { UnauthorizedError, ConflictError } from './errors';

const baseUser = {
  id: 'user-1',
  name: 'Maria',
  whatsappNumber: '5511999999999',
  cpf: '12345678901',
  email: 'maria@example.com',
  avatarUrl: null,
  role: 'CLIENT' as const,
  passwordHash: '',
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

test('login throws UnauthorizedError when user is not found', async () => {
  const service = new AuthService({
    findByEmail: async () => null,
  } as any);

  await assert.rejects(
    () => service.login({ email: 'noone@example.com', password: 'x' } as any),
    (err: Error) => err instanceof UnauthorizedError
  );
});

test('login throws UnauthorizedError when user has no passwordHash (sso-only)', async () => {
  const service = new AuthService({
    findByEmail: async () => ({ ...baseUser, passwordHash: null }),
  } as any);

  await assert.rejects(
    () => service.login({ email: 'maria@example.com', password: 'x' } as any),
    (err: Error) => err instanceof UnauthorizedError
  );
});

test('login throws UnauthorizedError when password does not match', async () => {
  const passwordHash = await bcrypt.hash('correct-password', 4);
  const service = new AuthService({
    findByEmail: async () => ({ ...baseUser, passwordHash }),
  } as any);

  await assert.rejects(
    () =>
      service.login({
        email: 'maria@example.com',
        password: 'wrong',
      } as any),
    (err: Error) => err instanceof UnauthorizedError
  );
});

test('login returns a token, userId and role on success', async () => {
  const passwordHash = await bcrypt.hash('correct-password', 4);
  const service = new AuthService({
    findByEmail: async () => ({ ...baseUser, passwordHash }),
  } as any);

  const result = await service.login({
    email: 'maria@example.com',
    password: 'correct-password',
  } as any);

  assert.equal(result.userId, 'user-1');
  assert.equal(result.role, 'CLIENT');
  assert.ok(result.token.length > 0);
});

test('login normalizes the email casing before lookup', async () => {
  let lookedUp: string | undefined;
  const passwordHash = await bcrypt.hash('correct-password', 4);

  const service = new AuthService({
    findByEmail: async (email: string) => {
      lookedUp = email;
      return { ...baseUser, passwordHash };
    },
  } as any);

  await service.login({
    email: '  MARIA@Example.com  ',
    password: 'correct-password',
  } as any);

  assert.equal(lookedUp, 'maria@example.com');
});

test('register throws ConflictError when whatsapp is already taken', async () => {
  const service = new AuthService({
    findByWhatsapp: async () => baseUser,
    findByCpf: async () => null,
    findByEmail: async () => null,
  } as any);

  await assert.rejects(
    () =>
      service.register({
        name: 'Maria',
        whatsappNumber: '5511999999999',
        cpf: '12345678901',
        email: 'maria@example.com',
        password: 'pwd123',
      } as any),
    (err: Error) => err instanceof ConflictError
  );
});

test('register throws ConflictError when cpf is already taken', async () => {
  const service = new AuthService({
    findByWhatsapp: async () => null,
    findByCpf: async () => baseUser,
    findByEmail: async () => null,
  } as any);

  await assert.rejects(
    () =>
      service.register({
        name: 'Maria',
        whatsappNumber: '5511999999999',
        cpf: '12345678901',
        email: 'maria@example.com',
        password: 'pwd123',
      } as any),
    (err: Error) => err instanceof ConflictError
  );
});

test('register hashes password and creates user with role CLIENT', async () => {
  let createdUser: any;
  const service = new AuthService({
    findByWhatsapp: async () => null,
    findByCpf: async () => null,
    findByEmail: async () => null,
    create: async (user: any) => {
      createdUser = user;
      return { id: 'user-new', ...user };
    },
  } as any);

  const result = await service.register({
    name: 'Pedro',
    whatsappNumber: '5511888888888',
    cpf: '99999999999',
    email: 'pedro@example.com',
    password: 'super-strong',
  } as any);

  assert.equal(createdUser.role, 'CLIENT');
  assert.equal(createdUser.email, 'pedro@example.com');
  assert.notEqual(createdUser.passwordHash, 'super-strong');
  assert.ok(await bcrypt.compare('super-strong', createdUser.passwordHash));
  assert.equal(result.userId, 'user-new');
  assert.equal(result.role, 'CLIENT');
  assert.ok(result.token.length > 0);
});

test('generateTempPassword returns an 8-char uppercase string', () => {
  const service = new AuthService({} as any);

  const password = service.generateTempPassword();

  assert.equal(password.length, 8);
  assert.equal(password, password.toUpperCase());
});
