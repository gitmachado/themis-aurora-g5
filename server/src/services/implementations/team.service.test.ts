/// <reference types="node" />

import { test } from 'node:test';
import assert from 'node:assert/strict';
import { TeamService } from './team.service';
import { ConflictError, NotFoundError } from './errors';

const baseLawyer = {
  id: 'lawyer-1',
  name: 'Ana',
  whatsappNumber: '5511777777777',
  cpf: null,
  email: 'ana@themis.com.br',
  avatarUrl: null,
  role: 'LAWYER' as const,
  passwordHash: null,
  fcmToken: null,
  notificationPreferences: { push: true, whatsapp: true },
  teamPermissions: {
    viewAllClients: false,
    convertLeads: true,
    manageDocuments: true,
    receiveSupportNotifications: false,
  },
  lawyerAdminId: 'admin-1',
  oabNumber: '12345',
  specialty: 'Civil',
  mustChangePassword: false,
  createdAt: new Date(),
  updatedAt: new Date(),
};

const fakeStats = { activeProcesses: 0, openLeads: 0, conversionsLast30d: 0 };

test('listTeam maps lawyers from repository to TeamMemberDTO', async () => {
  const service = new TeamService(
    {
      findByAdminId: async () => [baseLawyer],
      getStats: async () => fakeStats,
    } as any,
    {} as any
  );

  const team = await service.listTeam('admin-1');

  assert.equal(team.length, 1);
  assert.equal((team[0] as any).id, 'lawyer-1');
  assert.equal((team[0] as any).email, 'ana@themis.com.br');
});

test('getMember throws NotFoundError when lawyer is not in team', async () => {
  const service = new TeamService(
    {
      findOneByAdminId: async () => null,
    } as any,
    {} as any
  );

  await assert.rejects(
    () => service.getMember('admin-1', 'unknown'),
    (err: Error) => err instanceof NotFoundError
  );
});

test('addMember rejects with ConflictError when email is already taken', async () => {
  const service = new TeamService(
    {} as any,
    {
      findByEmail: async () => baseLawyer,
      findByWhatsapp: async () => null,
    } as any
  );

  await assert.rejects(
    () =>
      service.addMember('admin-1', {
        name: 'Bruno',
        email: 'ana@themis.com.br',
        whatsappNumber: '5511666666666',
        oabNumber: '99999',
        specialty: 'Trabalhista',
      } as any),
    (err: Error) => err instanceof ConflictError
  );
});

test('addMember rejects with ConflictError when whatsapp is already taken', async () => {
  const service = new TeamService(
    {} as any,
    {
      findByEmail: async () => null,
      findByWhatsapp: async () => baseLawyer,
    } as any
  );

  await assert.rejects(
    () =>
      service.addMember('admin-1', {
        name: 'Bruno',
        email: 'bruno@themis.com.br',
        whatsappNumber: '5511777777777',
        oabNumber: '99999',
        specialty: 'Trabalhista',
      } as any),
    (err: Error) => err instanceof ConflictError
  );
});

test('addMember creates LAWYER linked to adminId, returning tempPassword', async () => {
  let createdPayload: any;
  const service = new TeamService(
    {
      getStats: async () => fakeStats,
    } as any,
    {
      findByEmail: async () => null,
      findByWhatsapp: async () => null,
      create: async (data: any) => {
        createdPayload = data;
        return { ...baseLawyer, ...data, id: 'lawyer-new' };
      },
    } as any
  );

  const result = await service.addMember('admin-9', {
    name: 'Bruno',
    email: '  Bruno@Themis.com.BR ',
    whatsappNumber: '5511666666666',
    oabNumber: '99999',
    specialty: 'Trabalhista',
  } as any);

  assert.equal(createdPayload.role, 'LAWYER');
  assert.equal(createdPayload.lawyerAdminId, 'admin-9');
  assert.equal(createdPayload.email, 'bruno@themis.com.br');
  assert.equal(createdPayload.mustChangePassword, true);
  assert.ok(result.tempPassword.length > 0);
  assert.equal(typeof result.tempPassword, 'string');
});

test('updatePermissions throws NotFoundError when lawyer is not in team', async () => {
  const service = new TeamService(
    {
      findOneByAdminId: async () => null,
    } as any,
    {} as any
  );

  await assert.rejects(
    () => service.updatePermissions('admin-1', 'unknown', { x: true }),
    (err: Error) => err instanceof NotFoundError
  );
});

test('updatePermissions merges existing permissions with patch', async () => {
  let mergedPayload: any;
  const service = new TeamService(
    {
      findOneByAdminId: async () => baseLawyer,
      updatePermissions: async (_id: string, perms: any) => {
        mergedPayload = perms;
        return { ...baseLawyer, teamPermissions: perms };
      },
      getStats: async () => fakeStats,
    } as any,
    {} as any
  );

  await service.updatePermissions('admin-1', 'lawyer-1', {
    viewAllClients: true,
  });

  assert.equal(mergedPayload.viewAllClients, true);
  assert.equal(mergedPayload.convertLeads, true); // preserved
  assert.equal(mergedPayload.manageDocuments, true); // preserved
});

test('removeMember throws ConflictError when lawyer still has active processes', async () => {
  const service = new TeamService(
    {
      findOneByAdminId: async () => baseLawyer,
      countActiveProcesses: async () => 3,
    } as any,
    {} as any
  );

  await assert.rejects(
    () => service.removeMember('admin-1', 'lawyer-1'),
    (err: Error) => err instanceof ConflictError
  );
});

test('removeMember throws NotFoundError when lawyer is not in team', async () => {
  const service = new TeamService(
    {
      findOneByAdminId: async () => null,
    } as any,
    {} as any
  );

  await assert.rejects(
    () => service.removeMember('admin-1', 'unknown'),
    (err: Error) => err instanceof NotFoundError
  );
});
