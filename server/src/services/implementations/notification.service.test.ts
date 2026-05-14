/// <reference types="node" />

import { test } from 'node:test';
import assert from 'node:assert/strict';
import { NotificationService } from './notification.service';
import { NotFoundError } from './errors';

const baseNotification = {
  id: 'notif-1',
  userId: 'user-1',
  title: 'Hello',
  body: 'World',
  isRead: false,
  type: 'SYSTEM',
  extraData: null,
  createdAt: new Date(),
};

const baseUser = {
  id: 'user-1',
  fcmToken: 'fcm-token-xyz',
} as any;

test('send persists notification with default type SYSTEM and triggers push', async () => {
  let createdPayload: any;
  const pushCalls: any[] = [];
  const service = new NotificationService(
    {
      create: async (data: any) => {
        createdPayload = data;
        return { ...baseNotification, ...data };
      },
    } as any,
    {
      findById: async () => baseUser,
    } as any,
    {
      sendPushNotification: async (args: any) => {
        pushCalls.push(args);
      },
    } as any
  );

  await service.send({
    userId: 'user-1',
    title: 'Hello',
    body: 'World',
  } as any);

  assert.equal(createdPayload.type, 'SYSTEM');
  assert.equal(createdPayload.isRead, false);
  assert.equal(pushCalls.length, 1);
  assert.equal(pushCalls[0].token, 'fcm-token-xyz');
});

test('send forwards explicit type and extraData when provided', async () => {
  let createdPayload: any;
  const service = new NotificationService(
    {
      create: async (data: any) => {
        createdPayload = data;
        return { ...baseNotification, ...data };
      },
    } as any,
    {
      findById: async () => null,
    } as any,
    {
      sendPushNotification: async () => undefined,
    } as any
  );

  await service.send({
    userId: 'user-1',
    title: 'Update',
    body: 'A new doc was added',
    type: 'DOCUMENT',
    extraData: { docId: 'doc-1' },
  } as any);

  assert.equal(createdPayload.type, 'DOCUMENT');
  assert.deepEqual(createdPayload.extraData, { docId: 'doc-1' });
});

test('sendPush skips when user has no fcmToken', async () => {
  const pushCalls: any[] = [];
  const service = new NotificationService(
    {} as any,
    { findById: async () => ({ ...baseUser, fcmToken: null }) } as any,
    {
      sendPushNotification: async (args: any) => {
        pushCalls.push(args);
      },
    } as any
  );

  await service.sendPush('user-1', 'T', 'B');

  assert.equal(pushCalls.length, 0);
});

test('sendPush skips silently when user does not exist', async () => {
  const pushCalls: any[] = [];
  const service = new NotificationService(
    {} as any,
    { findById: async () => null } as any,
    {
      sendPushNotification: async (args: any) => {
        pushCalls.push(args);
      },
    } as any
  );

  await service.sendPush('user-missing', 'T', 'B');

  assert.equal(pushCalls.length, 0);
});

test('sendPush swallows push provider errors without throwing', async () => {
  const service = new NotificationService(
    {} as any,
    { findById: async () => baseUser } as any,
    {
      sendPushNotification: async () => {
        throw new Error('FCM down');
      },
    } as any
  );

  // Should not throw — error is logged, not propagated.
  await service.sendPush('user-1', 'T', 'B');
});

test('markAsRead throws NotFoundError when notification is missing', async () => {
  const service = new NotificationService(
    {
      findById: async () => null,
    } as any,
    {} as any,
    {} as any
  );

  await assert.rejects(
    () => service.markAsRead('missing'),
    (err: Error) => err instanceof NotFoundError
  );
});

test('markAsRead delegates to repository.markAsRead when notification exists', async () => {
  let markedId: string | undefined;
  const service = new NotificationService(
    {
      findById: async () => baseNotification,
      markAsRead: async (id: string) => {
        markedId = id;
      },
    } as any,
    {} as any,
    {} as any
  );

  await service.markAsRead('notif-1');

  assert.equal(markedId, 'notif-1');
});

test('delete throws NotFoundError when notification is missing', async () => {
  const service = new NotificationService(
    {
      findById: async () => null,
    } as any,
    {} as any,
    {} as any
  );

  await assert.rejects(
    () => service.delete('missing'),
    (err: Error) => err instanceof NotFoundError
  );
});

test('deleteMany delegates ids and userId to repository.deleteMany', async () => {
  let receivedIds: string[] | undefined;
  let receivedUser: string | undefined;
  const service = new NotificationService(
    {
      deleteMany: async (ids: string[], userId: string) => {
        receivedIds = ids;
        receivedUser = userId;
      },
    } as any,
    {} as any,
    {} as any
  );

  await service.deleteMany(['n-1', 'n-2'], 'user-1');

  assert.deepEqual(receivedIds, ['n-1', 'n-2']);
  assert.equal(receivedUser, 'user-1');
});
