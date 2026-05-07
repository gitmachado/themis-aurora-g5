/// <reference types="node" />

import { test, beforeEach, afterEach } from 'node:test';
import assert from 'node:assert/strict';
import pool from '../../config/database';
import { MessageRepository } from './message.repository';

const baseRow = {
  id: 'msg-1',
  leadId: null,
  userId: 'user-1',
  whatsappNumber: '5511999999999',
  content: 'hi',
  sender: 'BOT',
  whatsappMessageId: null,
  createdAt: new Date(),
};

let originalQuery: typeof pool.query;

beforeEach(() => {
  originalQuery = pool.query;
});

afterEach(() => {
  (pool as any).query = originalQuery;
});

test('findById binds id as first parameter', async () => {
  let capturedParams: any[] | undefined;
  (pool as any).query = async (_sql: string, params: any[]) => {
    capturedParams = params;
    return { rows: [baseRow], rowCount: 1 };
  };

  const repo = new MessageRepository();
  await repo.findById('msg-1');

  assert.equal(capturedParams?.[0], 'msg-1');
});

test('findByUserId binds userId as first parameter', async () => {
  let capturedParams: any[] | undefined;
  (pool as any).query = async (_sql: string, params: any[]) => {
    capturedParams = params;
    return { rows: [baseRow], rowCount: 1 };
  };

  const repo = new MessageRepository();
  await repo.findByUserId('user-1');

  assert.equal(capturedParams?.[0], 'user-1');
});

test('findByLeadId binds leadId as first parameter', async () => {
  let capturedParams: any[] | undefined;
  (pool as any).query = async (_sql: string, params: any[]) => {
    capturedParams = params;
    return { rows: [], rowCount: 0 };
  };

  const repo = new MessageRepository();
  await repo.findByLeadId('lead-1');

  assert.equal(capturedParams?.[0], 'lead-1');
});

test('findByWhatsappNumber binds the phone as first parameter', async () => {
  let capturedParams: any[] | undefined;
  (pool as any).query = async (_sql: string, params: any[]) => {
    capturedParams = params;
    return { rows: [baseRow], rowCount: 1 };
  };

  const repo = new MessageRepository();
  await repo.findByWhatsappNumber('5511999999999');

  assert.equal(capturedParams?.[0], '5511999999999');
});

test('create runs an INSERT INTO messages', async () => {
  let capturedSql: string | undefined;
  (pool as any).query = async (sql: string) => {
    capturedSql = sql;
    return { rows: [baseRow], rowCount: 1 };
  };

  const repo = new MessageRepository();
  const msg = await repo.create({
    leadId: null,
    userId: 'user-1',
    whatsappNumber: '5511999999999',
    content: 'hi',
    sender: 'BOT',
    whatsappMessageId: null,
  } as any);

  assert.match(capturedSql ?? '', /INSERT INTO messages/i);
  assert.equal(msg.id, 'msg-1');
});
