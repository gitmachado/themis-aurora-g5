/// <reference types="node" />

import { test, beforeEach, afterEach } from 'node:test';
import assert from 'node:assert/strict';
import pool from '../../config/database';
import { LeadRepository } from './lead.repository';

const baseLeadRow = {
  id: 'lead-1',
  whatsappNumber: '5511999999999',
  name: 'Maria',
  cpf: '12345678901',
  email: 'maria@example.com',
  caseType: 'Civil',
  caseDescription: 'Descricao',
  urgency: 'High',
  contactAvailability: 'Morning',
  status: 'PENDING',
  convertedUserId: null,
  assignedLawyerId: null,
  assignedLawyerName: null,
  lawyerNotes: null,
  discardReason: null,
  isAIPaused: false,
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
    return { rows: [baseLeadRow], rowCount: 1 };
  };

  const repo = new LeadRepository();
  const lead = await repo.findById('lead-1');

  assert.match(capturedSql ?? '', /WHERE id = \$1/);
  assert.deepEqual(capturedParams, ['lead-1']);
  assert.equal(lead?.id, 'lead-1');
});

test('findPending filters by PENDING status', async () => {
  let capturedParams: any[] | undefined;
  (pool as any).query = async (_sql: string, params: any[]) => {
    capturedParams = params;
    return { rows: [baseLeadRow], rowCount: 1 };
  };

  const repo = new LeadRepository();
  await repo.findPending();

  assert.deepEqual(capturedParams, ['PENDING']);
});

test('findByStatus issues a SELECT WHERE status = $1', async () => {
  let capturedParams: any[] | undefined;
  (pool as any).query = async (_sql: string, params: any[]) => {
    capturedParams = params;
    return { rows: [], rowCount: 0 };
  };

  const repo = new LeadRepository();
  await repo.findByStatus('CONVERTED' as any);

  assert.deepEqual(capturedParams, ['CONVERTED']);
});

test('create runs an INSERT INTO leads and returns the row', async () => {
  let capturedSql: string | undefined;
  (pool as any).query = async (sql: string) => {
    capturedSql = sql;
    return { rows: [baseLeadRow], rowCount: 1 };
  };

  const repo = new LeadRepository();
  const lead = await repo.create({
    whatsappNumber: '5511999999999',
    status: 'PENDING',
  } as any);

  assert.match(capturedSql ?? '', /INSERT INTO leads/i);
  assert.equal(lead.id, 'lead-1');
});

test('delete issues a DELETE FROM leads WHERE id = $1', async () => {
  let capturedSql: string | undefined;
  let capturedParams: any[] | undefined;
  (pool as any).query = async (sql: string, params: any[]) => {
    capturedSql = sql;
    capturedParams = params;
    return { rows: [], rowCount: 1 };
  };

  const repo = new LeadRepository();
  await repo.delete('lead-1');

  assert.match(capturedSql ?? '', /DELETE FROM leads/i);
  assert.deepEqual(capturedParams, ['lead-1']);
});
