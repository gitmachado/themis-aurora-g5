import test from 'node:test';
import assert from 'node:assert/strict';
import { DocumentController } from './document.controller';

const document = {
  id: 'document-1',
  legalProcessId: 'process-1',
  fileName: 'contrato.pdf',
  fileUrl: '/uploads/contrato.pdf',
  mimeType: 'application/pdf',
  sizeBytes: 1024,
  sentById: 'client-1',
  createdAt: new Date(),
  updatedAt: new Date(),
};

test('getById returns document metadata when client owns process', async () => {
  const controller = new DocumentController(
    { getById: async () => document } as any,
    {
      getById: async () => ({
        id: 'process-1',
        clientId: 'client-1',
        lawyerId: 'lawyer-1',
      }),
    } as any,
    {} as any
  );
  const response = createResponse();

  await controller.getById(
    { params: { id: 'document-1' }, user: { id: 'client-1', role: 'CLIENT' } } as any,
    response as any,
    assert.ifError
  );

  assert.equal(response.statusCode, 200);
  assert.equal(response.body.id, 'document-1');
});

test('getById rejects document metadata from another client process', async () => {
  const controller = new DocumentController(
    { getById: async () => document } as any,
    {
      getById: async () => ({
        id: 'process-1',
        clientId: 'another-client',
        lawyerId: 'lawyer-1',
      }),
    } as any,
    {} as any
  );
  let nextError: Error | undefined;

  await controller.getById(
    { params: { id: 'document-1' }, user: { id: 'client-1', role: 'CLIENT' } } as any,
    createResponse() as any,
    (error?: any) => {
      nextError = error;
    }
  );

  assert.equal((nextError as any)?.errorCode, 'FORBIDDEN');
});

test('getAccessUrl returns signed document URL when user can access process', async () => {
  const controller = new DocumentController(
    { getById: async () => document } as any,
    {
      getById: async () => ({
        id: 'process-1',
        clientId: 'client-1',
        lawyerId: 'lawyer-1',
      }),
    } as any,
    {
      getAccessUrl: async (fileUrl: string) =>
        `https://storage.example.test/signed?path=${encodeURIComponent(fileUrl)}`,
    } as any
  );
  const response = createResponse();

  await controller.getAccessUrl(
    { params: { id: 'document-1' }, user: { id: 'client-1', role: 'CLIENT' } } as any,
    response as any,
    assert.ifError
  );

  assert.equal(response.statusCode, 200);
  assert.equal(
    response.body.url,
    'https://storage.example.test/signed?path=%2Fuploads%2Fcontrato.pdf'
  );
});

function createResponse() {
  return {
    statusCode: 200,
    body: undefined as any,
    status(code: number) {
      this.statusCode = code;
      return this;
    },
    json(body: any) {
      this.body = body;
      return this;
    },
  };
}
