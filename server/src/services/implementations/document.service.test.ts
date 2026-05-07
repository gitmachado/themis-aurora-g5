/// <reference types="node" />

import { test } from 'node:test';
import assert from 'node:assert/strict';
import { DocumentService } from './document.service';
import { ValidationError, NotFoundError } from './errors';
import { ALLOWED_MIME_TYPES, MAX_FILE_SIZE_BYTES } from '../interfaces/document.service';

const baseDocument = {
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

test('upload delegates to repository.create with default mimeType when missing', async () => {
  let createdPayload: any;
  const service = new DocumentService({
    create: async (data: any) => {
      createdPayload = data;
      return { ...baseDocument, ...data };
    },
  } as any);

  await service.upload({
    legalProcessId: 'process-1',
    fileName: 'contrato.pdf',
    fileUrl: '/uploads/contrato.pdf',
    sentById: 'user-1',
  } as any);

  assert.equal(createdPayload.mimeType, 'application/octet-stream');
  assert.equal(createdPayload.sizeBytes, null);
});

test('upload preserves caller-provided mimeType and sizeBytes', async () => {
  let createdPayload: any;
  const service = new DocumentService({
    create: async (data: any) => {
      createdPayload = data;
      return { ...baseDocument, ...data };
    },
  } as any);

  await service.upload({
    legalProcessId: 'process-1',
    fileName: 'foto.jpg',
    fileUrl: '/uploads/foto.jpg',
    sentById: 'user-1',
    mimeType: 'image/jpeg',
    sizeBytes: 4096,
  } as any);

  assert.equal(createdPayload.mimeType, 'image/jpeg');
  assert.equal(createdPayload.sizeBytes, 4096);
});

test('validateFile rejects files larger than MAX_FILE_SIZE_BYTES', () => {
  const service = new DocumentService({} as any);

  assert.throws(
    () => service.validateFile(MAX_FILE_SIZE_BYTES + 1, 'application/pdf'),
    (err: Error) => err instanceof ValidationError
  );
});

test('validateFile rejects mimeType outside the allowlist', () => {
  const service = new DocumentService({} as any);

  assert.throws(
    () => service.validateFile(1024, 'application/x-msdownload'),
    (err: Error) => err instanceof ValidationError
  );
});

test('validateFile accepts a valid mimeType under the size cap', () => {
  const service = new DocumentService({} as any);

  const valid = service.validateFile(1024, ALLOWED_MIME_TYPES[0]);

  assert.equal(valid, true);
});

test('getByLegalProcess delegates to repository.findByLegalProcessId', async () => {
  let receivedId: string | undefined;
  const service = new DocumentService({
    findByLegalProcessId: async (id: string) => {
      receivedId = id;
      return [baseDocument];
    },
  } as any);

  const result = await service.getByLegalProcess('process-42');

  assert.equal(receivedId, 'process-42');
  assert.equal(result.length, 1);
});

test('delete throws NotFoundError when the document does not exist', async () => {
  const service = new DocumentService({
    findById: async () => null,
  } as any);

  await assert.rejects(
    () => service.delete('missing-id'),
    (err: Error) => err instanceof NotFoundError
  );
});

test('delete removes the document when it exists', async () => {
  const calls: string[] = [];
  const service = new DocumentService({
    findById: async () => baseDocument,
    delete: async (id: string) => {
      calls.push(`delete:${id}`);
    },
  } as any);

  await service.delete('doc-1');

  assert.deepEqual(calls, ['delete:doc-1']);
});
