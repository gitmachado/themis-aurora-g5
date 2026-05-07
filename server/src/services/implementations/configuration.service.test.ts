/// <reference types="node" />

import { test } from 'node:test';
import assert from 'node:assert/strict';
import { ConfigurationService } from './configuration.service';

const baseConfig = {
  id: 'config-1',
  promptTemplate: 'You are a helpful assistant',
  ragEnabled: true,
  guardrailsEnabled: true,
  createdAt: new Date(),
  updatedAt: new Date(),
};

test('getConfiguration returns the first configuration row from the repository', async () => {
  const service = new ConfigurationService({
    findFirst: async () => baseConfig,
  } as any);

  const result = await service.getConfiguration();

  assert.deepEqual(result, baseConfig);
});

test('getConfiguration returns null when no configuration row exists yet', async () => {
  const service = new ConfigurationService({
    findFirst: async () => null,
  } as any);

  const result = await service.getConfiguration();

  assert.equal(result, null);
});

test('getConfiguration calls the repository exactly once per invocation', async () => {
  let callCount = 0;
  const service = new ConfigurationService({
    findFirst: async () => {
      callCount += 1;
      return baseConfig;
    },
  } as any);

  await service.getConfiguration();
  await service.getConfiguration();

  assert.equal(callCount, 2);
});

test('getConfiguration propagates repository errors transparently', async () => {
  const service = new ConfigurationService({
    findFirst: async () => {
      throw new Error('database offline');
    },
  } as any);

  await assert.rejects(
    () => service.getConfiguration(),
    (err: Error) => err.message === 'database offline'
  );
});
