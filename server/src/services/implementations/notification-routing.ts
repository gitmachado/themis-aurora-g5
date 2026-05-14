import type { NotificationType, UserRole } from '@enums';

const ANY_ROLE: ReadonlyArray<UserRole> = ['LAWYER', 'LAWYER_ADMIN', 'CLIENT'];
const LAWYER_ONLY: ReadonlyArray<UserRole> = ['LAWYER', 'LAWYER_ADMIN'];
const CLIENT_ONLY: ReadonlyArray<UserRole> = ['CLIENT'];

const ROUTING_RULES: Record<NotificationType, ReadonlyArray<UserRole>> = {
  NEW_LEAD: LAWYER_ONLY,
  HUMAN_SUPPORT: LAWYER_ONLY,
  DOCUMENT_SENT: LAWYER_ONLY,
  DOCUMENT_REQUESTED: CLIENT_ONLY,
  NEW_NOTE: CLIENT_ONLY,
  STATUS_CHANGED: ANY_ROLE,
  DEADLINE_WARNING: LAWYER_ONLY,
  APPOINTMENT_SCHEDULED: ANY_ROLE,
  APPOINTMENT_CHANGED: ANY_ROLE,
  NEW_APPOINTMENT_AI: LAWYER_ONLY,
};

export function isRoleAllowedForNotificationType(
  type: string | undefined,
  role: UserRole
): boolean {
  // Unknown / 'SYSTEM' / missing type → fall back to any role.
  // Routing rules only restrict the explicitly mapped types.
  if (!type) return true;
  const allowed = (ROUTING_RULES as Record<string, ReadonlyArray<UserRole>>)[type];
  if (!allowed) return true;
  return allowed.includes(role);
}
