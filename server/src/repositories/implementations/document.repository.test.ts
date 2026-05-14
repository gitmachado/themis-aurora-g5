/// <reference types="node" />

import { test, beforeEach, afterEach } from 'node:test';
import assert from 'node:assert/strict';
import pool from '../../config/database';
import { DocumentRepository } from './document.repository';

const baseRow = {
  id: 'doc-1',
  legalProcessId: 'process-1',
  fileName: 'contrato.pdf',
  fileUrl: '/uploads/contrato.pdf',
  mimeType: 'application/pdf',
  sizeBytes: 1024,
  sentById: 'user-1',
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

test('findById issues SELECT … WHERE id = $1', async () => {
  let capturedSql: string | undefined;
  let capturedParams: any[] | undefined;
  (pool as any).query = async (sql: string, params: any[]) => {
    capturedSql = sql;
    capturedParams = params;
    return { rows: [baseRow], rowCount: 1 };
  };

  const repo = new DocumentRepository();
  const doc = await repo.findById('doc-1');

  assert.match(capturedSql ?? '', /WHERE id = \$1/);
  assert.deepEqual(capturedParams, ['doc-1']);
  assert.equal(doc?.id, 'doc-1');
});

test('findByLegalProcessId issues SELECT … WHERE legal_process_id = $1', async () => {
  let capturedParams: any[] | undefined;
  (pool as any).query = async (_sql: string, params: any[]) => {
    capturedParams = params;
    return { rows: [baseRow], rowCount: 1 };
  };

  const repo = new DocumentRepository();
  const docs = await repo.findByLegalProcessId('process-1');

  assert.deepEqual(capturedParams, ['process-1']);
  assert.equal(docs.length, 1);
});

test('findByFileName binds file name as first parameter', async () => {
  let capturedParams: any[] | undefined;
  (pool as any).query = async (_sql: string, params: any[]) => {
    capturedParams = params;
    return { rows: [baseRow], rowCount: 1 };
  };

  const repo = new DocumentRepository();
  await repo.findByFileName('contrato.pdf');

  assert.equal(capturedParams?.[0], 'contrato.pdf');
});

test('create runs an INSERT INTO documents and returns the row', async () => {
  let capturedSql: string | undefined;
  (pool as any).query = async (sql: string) => {
    capturedSql = sql;
    return { rows: [baseRow], rowCount: 1 };
  };

  const repo = new DocumentRepository();
  const doc = await repo.create({
    legalProcessId: 'process-1',
    fileName: 'contrato.pdf',
    fileUrl: '/uploads/contrato.pdf',
    mimeType: 'application/pdf',
    sizeBytes: 1024,
    sentById: 'user-1',
  } as any);

  assert.match(capturedSql ?? '', /INSERT INTO documents/i);
  assert.equal(doc.id, 'doc-1');
});

test('delete issues a DELETE FROM documents WHERE id = $1', async () => {
  let capturedSql: string | undefined;
  let capturedParams: any[] | undefined;
  (pool as any).query = async (sql: string, params: any[]) => {
    capturedSql = sql;
    capturedParams = params;
    return { rows: [], rowCount: 1 };
  };

  const repo = new DocumentRepository();
  await repo.delete('doc-1');

  assert.match(capturedSql ?? '', /DELETE FROM documents/i);
  assert.deepEqual(capturedParams, ['doc-1']);
});
