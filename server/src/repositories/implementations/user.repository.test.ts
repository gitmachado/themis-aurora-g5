/// <reference types="node" />

import { test, beforeEach, afterEach, mock } from 'node:test';
import assert from 'node:assert/strict';
import pool from '../../config/database';
import { UserRepository } from './user.repository';

const baseUserRow = {
  id: 'user-1',
  name: 'Maria',
  whatsappNumber: '5511999999999',
  cpf: '12345678901',
  email: 'maria@example.com',
  avatarUrl: null,
  role: 'CLIENT',
  passwordHash: 'hash',
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

let originalQuery: typeof pool.query;

beforeEach(() => {
  originalQuery = pool.query;
});

afterEach(() => {
  (pool as any).query = originalQuery;
});

test('findById issues a SELECT … WHERE id = $1 query', async () => {
  let capturedSql: string | undefined;
  let capturedParams: any[] | undefined;
  (pool as any).query = async (sql: string, params: any[]) => {
    capturedSql = sql;
    capturedParams = params;
    return { rows: [baseUserRow], rowCount: 1 };
  };

  const repo = new UserRepository();
  const user = await repo.findById('user-1');

  assert.match(capturedSql ?? '', /WHERE id = \$1/);
  assert.deepEqual(capturedParams, ['user-1']);
  assert.equal(user?.id, 'user-1');
});

test('findById returns null when no row matches', async () => {
  (pool as any).query = async () => ({ rows: [], rowCount: 0 });

  const repo = new UserRepository();
  const user = await repo.findById('missing');

  assert.equal(user, null);
});

test('findByEmail issues a SELECT … WHERE email = $1 query', async () => {
  let capturedSql: string | undefined;
  let capturedParams: any[] | undefined;
  (pool as any).query = async (sql: string, params: any[]) => {
    capturedSql = sql;
    capturedParams = params;
    return { rows: [baseUserRow], rowCount: 1 };
  };

  const repo = new UserRepository();
  await repo.findByEmail('maria@example.com');

  assert.match(capturedSql ?? '', /lower\(email\) = lower\(\$1\)/);
  assert.deepEqual(capturedParams, ['maria@example.com']);
});

test('findByWhatsapp does an exact lookup before falling back to normalization', async () => {
  let calls: { sql: string; params: any[] }[] = [];
  (pool as any).query = async (sql: string, params: any[]) => {
    calls.push({ sql, params });
    return { rows: [baseUserRow], rowCount: 1 };
  };

  const repo = new UserRepository();
  await repo.findByWhatsapp('5511999999999');

  // Apenas uma chamada esperada quando o exato bate.
  assert.equal(calls.length, 1);
  assert.match(calls[0].sql, /WHERE whatsapp_number = \$1/);
});

test('findByWhatsapp normalizes when exact lookup misses', async () => {
  let calls: { sql: string; params: any[] }[] = [];
  (pool as any).query = async (sql: string, params: any[]) => {
    calls.push({ sql, params });
    if (calls.length === 1) {
      return { rows: [], rowCount: 0 };
    }
    return { rows: [baseUserRow], rowCount: 1 };
  };

  const repo = new UserRepository();
  const user = await repo.findByWhatsapp('+55 (11) 99999-9999');

  assert.equal(calls.length, 2);
  assert.equal(user?.id, 'user-1');
});

test('create runs an INSERT and returns the resulting row', async () => {
  let capturedSql: string | undefined;
  (pool as any).query = async (sql: string) => {
    capturedSql = sql;
    return { rows: [baseUserRow], rowCount: 1 };
  };

  const repo = new UserRepository();
  const user = await repo.create({
    name: 'Maria',
    whatsappNumber: '5511999999999',
    cpf: '12345678901',
    email: 'maria@example.com',
    avatarUrl: null,
    role: 'CLIENT',
    passwordHash: 'hash',
    fcmToken: null,
    notificationPreferences: { push: true, whatsapp: true },
    teamPermissions: {},
    lawyerAdminId: null,
    oabNumber: null,
    specialty: null,
    mustChangePassword: false,
  } as any);

  assert.match(capturedSql ?? '', /INSERT INTO users/i);
  assert.equal(user.id, 'user-1');
});

test('delete issues a DELETE FROM users WHERE id = $1', async () => {
  let capturedSql: string | undefined;
  let capturedParams: any[] | undefined;
  (pool as any).query = async (sql: string, params: any[]) => {
    capturedSql = sql;
    capturedParams = params;
    return { rows: [], rowCount: 1 };
  };

  const repo = new UserRepository();
  await repo.delete('user-1');

  assert.match(capturedSql ?? '', /DELETE FROM users/i);
  assert.deepEqual(capturedParams, ['user-1']);
});
