import test from 'node:test';
import assert from 'node:assert/strict';
import { AccountController } from './account.controller';

test('updateNotificationPreferences validates and persists boolean map', async () => {
  let savedPreferences: Record<string, boolean> | undefined;
  const controller = new AccountController({
    update: async (_id: string, data: { notificationPreferences: Record<string, boolean> }) => {
      savedPreferences = data.notificationPreferences;
      return {
        id: 'user-1',
        name: 'Lucas',
        whatsappNumber: '5511999999999',
        cpf: '12345678900',
        email: 'lucas@example.com',
        role: 'CLIENT',
        notificationPreferences: data.notificationPreferences,
        createdAt: new Date(),
        updatedAt: new Date(),
      };
    },
  } as any);
  const response = createResponse();

  await controller.updateNotificationPreferences(
    {
      user: { id: 'user-1' },
      body: { notificationPreferences: { documents: false } },
    } as any,
    response as any,
    assert.ifError
  );

  assert.deepEqual(savedPreferences, { documents: false });
  assert.equal(response.statusCode, 200);
  assert.deepEqual(response.body.notificationPreferences, { documents: false });
});

test('updateNotificationPreferences rejects non-boolean values', async () => {
  const controller = new AccountController({ update: async () => undefined } as any);
  let nextError: Error | undefined;

  await controller.updateNotificationPreferences(
    {
      user: { id: 'user-1' },
      body: { notificationPreferences: { documents: 'yes' } },
    } as any,
    createResponse() as any,
    (error?: any) => {
      nextError = error;
    }
  );

  assert.equal((nextError as any)?.errorCode, 'VALIDATION_ERROR');
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
