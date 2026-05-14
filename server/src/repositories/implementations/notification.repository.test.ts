/// <reference types="node" />

import { test, beforeEach, afterEach } from 'node:test';
import assert from 'node:assert/strict';
import pool from '../../config/database';
import { NotificationRepository } from './notification.repository';

const baseRow = {
  id: 'notif-1',
  userId: 'user-1',
  title: 'hi',
  body: 'World',
  isRead: false,
  type: 'SYSTEM',
  extraData: null,
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

  const repo = new NotificationRepository();
  await repo.findById('notif-1');

  assert.equal(capturedParams?.[0], 'notif-1');
});

test('findByUserId binds userId as first parameter', async () => {
  let capturedParams: any[] | undefined;
  (pool as any).query = async (_sql: string, params: any[]) => {
    capturedParams = params;
    return { rows: [baseRow], rowCount: 1 };
  };

  const repo = new NotificationRepository();
  await repo.findByUserId('user-1');

  assert.equal(capturedParams?.[0], 'user-1');
});

test('findUnreadByUserId filters with is_read = false', async () => {
  let capturedSql: string | undefined;
  (pool as any).query = async (sql: string) => {
    capturedSql = sql;
    return { rows: [baseRow], rowCount: 1 };
  };

  const repo = new NotificationRepository();
  await repo.findUnreadByUserId('user-1');

  assert.match(capturedSql ?? '', /is_read\s*=\s*false/i);
});

test('create runs an INSERT INTO notifications and returns the row', async () => {
  let capturedSql: string | undefined;
  (pool as any).query = async (sql: string) => {
    capturedSql = sql;
    return { rows: [baseRow], rowCount: 1 };
  };

  const repo = new NotificationRepository();
  const notif = await repo.create({
    userId: 'user-1',
    title: 'hi',
    body: 'World',
    isRead: false,
    type: 'SYSTEM',
    extraData: null,
  } as any);

  assert.match(capturedSql ?? '', /INSERT INTO notifications/i);
  assert.equal(notif.id, 'notif-1');
});

test('markAsRead updates is_read for the given id', async () => {
  let capturedSql: string | undefined;
  let capturedParams: any[] | undefined;
  (pool as any).query = async (sql: string, params: any[]) => {
    capturedSql = sql;
    capturedParams = params;
    return { rows: [], rowCount: 1 };
  };

  const repo = new NotificationRepository();
  await repo.markAsRead('notif-1');

  assert.match(capturedSql ?? '', /UPDATE notifications/i);
  assert.match(capturedSql ?? '', /is_read/);
  assert.deepEqual(capturedParams, ['notif-1']);
});

test('markAllAsRead updates by user_id only', async () => {
  let capturedSql: string | undefined;
  let capturedParams: any[] | undefined;
  (pool as any).query = async (sql: string, params: any[]) => {
    capturedSql = sql;
    capturedParams = params;
    return { rows: [], rowCount: 5 };
  };

  const repo = new NotificationRepository();
  await repo.markAllAsRead('user-1');

  assert.match(capturedSql ?? '', /UPDATE notifications/i);
  assert.deepEqual(capturedParams, ['user-1']);
});

test('delete issues a DELETE FROM notifications WHERE id = $1', async () => {
  let capturedSql: string | undefined;
  let capturedParams: any[] | undefined;
  (pool as any).query = async (sql: string, params: any[]) => {
    capturedSql = sql;
    capturedParams = params;
    return { rows: [], rowCount: 1 };
  };

  const repo = new NotificationRepository();
  await repo.delete('notif-1');

  assert.match(capturedSql ?? '', /DELETE FROM notifications/i);
  assert.deepEqual(capturedParams, ['notif-1']);
});
