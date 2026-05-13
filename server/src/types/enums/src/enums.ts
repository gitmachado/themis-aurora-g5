// ========================
// Themis Domain Enums
// ========================

/** Supported legal practice niches */
export type CaseType =
  | 'Labor'
  | 'Civil'
  | 'Family'
  | 'Criminal'
  | 'SocialSecurity';

/** Urgency level reported by the lead */
export type UrgencyLevel = 'High' | 'Medium' | 'Low';

/** State of the lead in the conversion funnel */
export type LeadStatus = 'PENDING' | 'IN_CONTACT' | 'CONVERTED' | 'DISCARDED';

/** Legal process status */
export type LegalProcessStatus =
  | 'OPEN'
  | 'UNDER_ANALYSIS'
  | 'AWAITING_DOCUMENT'
  | 'COMPLETED'
  | 'ARCHIVED';

/** System access roles */
export type UserRole = 'LAWYER' | 'CLIENT' | 'LAWYER_ADMIN';

/** Permissions configurable by the head lawyer for each team member */
export type TeamPermissionKey =
  | 'viewAllClients'
  | 'convertLeads'
  | 'manageDocuments'
  | 'receiveSupportNotifications';

/** Event types in a legal process timeline */
export type TimelineEventType =
  | 'STATUS_UPDATE'
  | 'LAWYER_NOTE'
  | 'DOCUMENT_SENT'
  | 'DOCUMENT_REQUESTED'
  | 'EVENT_SCHEDULED'
  | 'PROCESS_CREATED';

/** Contact availability reported by the lead */
export type ContactAvailability = 'Morning' | 'Afternoon' | 'Evening';

/** Push notification types (FCM) */
export type NotificationType =
  | 'NEW_LEAD'
  | 'STATUS_CHANGED'
  | 'DOCUMENT_SENT'
  | 'DOCUMENT_REQUESTED'
  | 'NEW_NOTE'
  | 'HUMAN_SUPPORT'
  | 'DEADLINE_WARNING'
  | 'APPOINTMENT_SCHEDULED'
  | 'APPOINTMENT_CHANGED';

/** Who sent the message in the chat */
export type MessageSender = 'BOT' | 'CLIENT' | 'LAWYER';

/** Types of appointments in the schedule */
export type AppointmentType = 'MEETING' | 'DEADLINE' | 'HEARING' | 'OTHER';

/** Status of an appointment */
export type AppointmentStatus = 'SCHEDULED' | 'COMPLETED' | 'CANCELED';

