import test from 'node:test';
import assert from 'node:assert/strict';
import { LeadController } from './lead.controller';

test('convert passes authenticated lawyer id to lead service', async () => {
  let payload: { leadId: string; lawyerId: string } | undefined;
  const controller = new LeadController({
    convertToClient: async (data: { leadId: string; lawyerId: string }) => {
      payload = data;
      return { id: 'client-1' };
    },
  } as any);
  const response = createResponse();

  await controller.convert(
    { params: { id: 'lead-1' }, user: { id: 'lawyer-1' } } as any,
    response as any,
    assert.ifError
  );

  assert.deepEqual(payload, { leadId: 'lead-1', lawyerId: 'lawyer-1' });
  assert.equal(response.statusCode, 200);
});

test('discard archives lead with reason', async () => {
  let discarded: { id: string; reason?: string } | undefined;
  const controller = new LeadController({
    discard: async (id: string, reason?: string) => {
      discarded = { id, reason };
      return { id, status: 'DISCARDED' };
    },
  } as any);
  const response = createResponse();

  await controller.discard(
    { params: { id: 'lead-1' }, body: { reason: 'Sem aderencia' } } as any,
    response as any,
    assert.ifError
  );

  assert.deepEqual(discarded, { id: 'lead-1', reason: 'Sem aderencia' });
  assert.equal(response.body.status, 'DISCARDED');
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
