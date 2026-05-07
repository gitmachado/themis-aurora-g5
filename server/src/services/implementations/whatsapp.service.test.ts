/// <reference types="node" />

import { test, beforeEach, afterEach } from 'node:test';
import assert from 'node:assert/strict';
import { WhatsAppService } from './whatsapp.service';

const ORIGINAL_FETCH = global.fetch;

afterEach(() => {
  global.fetch = ORIGINAL_FETCH;
  delete process.env.WA_ACCESS_TOKEN;
  delete process.env.WA_PHONE_NUMBER_ID;
});

test('sendText returns a fake id when access token is not configured', async () => {
  // No env vars set — service should short-circuit instead of calling fetch.
  global.fetch = (async () => {
    throw new Error('fetch should not be called when token is missing');
  }) as any;

  const service = new WhatsAppService();
  const id = await service.sendText('5511999999999', 'hi');

  assert.match(id, /^fake-id-\d+$/);
});

test('sendText returns the WhatsApp message id when API responds 200', async () => {
  process.env.WA_ACCESS_TOKEN = 'token';
  process.env.WA_PHONE_NUMBER_ID = 'phone-id';

  let calledUrl: string | undefined;
  let calledBody: string | undefined;

  global.fetch = (async (url: string, init: any) => {
    calledUrl = url;
    calledBody = init?.body as string;
    return {
      ok: true,
      json: async () => ({ messages: [{ id: 'wa-id-123' }] }),
    } as any;
  }) as any;

  const service = new WhatsAppService();
  const id = await service.sendText('5511999999999', 'Hello!');

  assert.equal(id, 'wa-id-123');
  assert.match(calledUrl ?? '', /graph\.facebook\.com/);
  assert.match(calledBody ?? '', /5511999999999/);
  assert.match(calledBody ?? '', /Hello!/);
});

test('sendText falls back to unknown-id when response has no message id', async () => {
  process.env.WA_ACCESS_TOKEN = 'token';
  process.env.WA_PHONE_NUMBER_ID = 'phone-id';

  global.fetch = (async () => ({
    ok: true,
    json: async () => ({}),
  })) as any;

  const service = new WhatsAppService();
  const id = await service.sendText('5511999999999', 'Hello!');

  assert.equal(id, 'unknown-id');
});

test('sendText throws when WhatsApp API responds with non-OK status', async () => {
  process.env.WA_ACCESS_TOKEN = 'token';
  process.env.WA_PHONE_NUMBER_ID = 'phone-id';

  global.fetch = (async () => ({
    ok: false,
    json: async () => ({ error: { message: 'invalid_token' } }),
  })) as any;

  const service = new WhatsAppService();

  await assert.rejects(
    () => service.sendText('5511999999999', 'Hello!'),
    (err: Error) => /invalid_token/.test(err.message)
  );
});

test('sendText surfaces fetch errors (network down)', async () => {
  process.env.WA_ACCESS_TOKEN = 'token';
  process.env.WA_PHONE_NUMBER_ID = 'phone-id';

  global.fetch = (async () => {
    throw new Error('ENETUNREACH');
  }) as any;

  const service = new WhatsAppService();

  await assert.rejects(
    () => service.sendText('5511999999999', 'Hello!'),
    (err: Error) => /ENETUNREACH/.test(err.message)
  );
});
