import test from 'node:test';
import assert from 'node:assert/strict';
import { ClientController } from './client.controller';

test('getById returns only client linked to authenticated lawyer', async () => {
  let lookup: { lawyerId: string; clientId: string } | undefined;
  const controller = new ClientController({
    getClientByLawyerId: async (lawyerId: string, clientId: string) => {
      lookup = { lawyerId, clientId };
      return {
        id: clientId,
        name: 'Cliente',
        whatsappNumber: '5511888888888',
        cpf: '12345678900',
        email: 'cliente@example.com',
        role: 'CLIENT',
      };
    },
  } as any);
  const response = createResponse();

  await controller.getById(
    {
      params: { id: 'client-1' },
      user: { id: 'lawyer-1', role: 'LAWYER' },
    } as any,
    response as any,
    assert.ifError
  );

  assert.deepEqual(lookup, { lawyerId: 'lawyer-1', clientId: 'client-1' });
  assert.equal(response.body.id, 'client-1');
});

test('getById rejects non-lawyer user', async () => {
  const controller = new ClientController({} as any);
  let nextError: Error | undefined;

  await controller.getById(
    {
      params: { id: 'client-1' },
      user: { id: 'client-1', role: 'CLIENT' },
    } as any,
    createResponse() as any,
    (error?: any) => {
      nextError = error;
    }
  );

  assert.equal((nextError as any)?.errorCode, 'FORBIDDEN');
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
