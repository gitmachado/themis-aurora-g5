import test from 'node:test';
import assert from 'node:assert/strict';
import { NotificationController } from './notification.controller';

test('delete removes only notifications owned by the authenticated user', async () => {
  let deletedId: string | undefined;
  const controller = new NotificationController({
    getById: async () => ({
      id: 'notification-1',
      userId: 'user-1',
      type: 'STATUS_CHANGED',
      title: 'Atualizacao',
      body: 'Seu tramite mudou',
      isRead: false,
      createdAt: new Date(),
      updatedAt: new Date(),
    }),
    delete: async (id: string) => {
      deletedId = id;
    },
  } as any);
  const response = createResponse();

  await controller.delete(
    { params: { id: 'notification-1' }, user: { id: 'user-1' } } as any,
    response as any,
    assert.ifError
  );

  assert.equal(deletedId, 'notification-1');
  assert.equal(response.statusCode, 204);
});

test('delete rejects notification from another user', async () => {
  const controller = new NotificationController({
    getById: async () => ({
      id: 'notification-1',
      userId: 'another-user',
      type: 'STATUS_CHANGED',
      title: 'Atualizacao',
      body: 'Seu tramite mudou',
      isRead: false,
      createdAt: new Date(),
      updatedAt: new Date(),
    }),
    delete: async () => undefined,
  } as any);
  let nextError: Error | undefined;

  await controller.delete(
    { params: { id: 'notification-1' }, user: { id: 'user-1' } } as any,
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
    status(code: number) {
      this.statusCode = code;
      return this;
    },
    send() {
      return this;
    },
  };
}
