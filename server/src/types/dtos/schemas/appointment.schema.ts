import { z } from 'zod';

/**
 * @openapi
 * components:
 *   schemas:
 *     CreateAppointmentRequest:
 *       type: object
 *       required: [title, type, scheduledAt]
 *       properties:
 *         clientId:
 *           type: string
 *           format: uuid
 *         processId:
 *           type: string
 *           format: uuid
 *         title:
 *           type: string
 *           minLength: 3
 *         description:
 *           type: string
 *         type:
 *           type: string
 *           enum: [MEETING, DEADLINE, HEARING, OTHER]
 *         scheduledAt:
 *           type: string
 *           format: date-time
 *         durationMinutes:
 *           type: integer
 *           minimum: 15
 *
 *     UpdateAppointmentRequest:
 *       type: object
 *       properties:
 *         title:
 *           type: string
 *           minLength: 3
 *         description:
 *           type: string
 *         scheduledAt:
 *           type: string
 *           format: date-time
 *         durationMinutes:
 *           type: integer
 *           minimum: 15
 *         status:
 *           type: string
 *           enum: [SCHEDULED, COMPLETED, CANCELED]
 *
 *     CheckConflictsRequest:
 *       type: object
 *       required: [scheduledAt, durationMinutes]
 *       properties:
 *         scheduledAt:
 *           type: string
 *           format: date-time
 *         durationMinutes:
 *           type: integer
 *           minimum: 15
 */

export const createAppointmentSchema = z.object({
  body: z.object({
    clientId: z.string().uuid().optional(),
    processId: z.string().uuid().optional(),
    title: z.string().min(3),
    description: z.string().optional(),
    type: z.enum(['MEETING', 'DEADLINE', 'HEARING', 'OTHER']),
    scheduledAt: z.coerce.date(),
    durationMinutes: z.number().int().min(15).optional(),
    createdByAI: z.boolean().default(false).optional(),
  }),
});

export const updateAppointmentSchema = z.object({
  body: z.object({
    title: z.string().min(3).optional(),
    description: z.string().optional(),
    scheduledAt: z.coerce.date().optional(),
    durationMinutes: z.number().int().min(15).optional(),
    status: z.enum(['SCHEDULED', 'COMPLETED', 'CANCELED', 'PENDING_APPROVAL']).optional(),
  }),
});

export const checkConflictsSchema = z.object({
  body: z.object({
    scheduledAt: z.coerce.date(),
    durationMinutes: z.number().int().min(15),
  }),
});

export const getAvailableSlotsSchema = z.object({
  query: z.object({
    date: z.coerce.date(),
    slotDurationMinutes: z.coerce.number().int().min(15).optional(),
    lawyerId: z.string().uuid().optional(),
  }),
});

export const approveAppointmentSchema = z.object({
  body: z.object({
    title: z.string().min(3).optional(),
    description: z.string().optional(),
    scheduledAt: z.coerce.date().optional(),
    durationMinutes: z.number().int().min(15).optional(),
  }).optional(),
});

export const rejectAppointmentSchema = z.object({
  body: z.object({}).optional(),
});

export const resetAppointmentSchema = z.object({
  body: z.object({}).optional(),
});

export const requestRescheduleSchema = z.object({
  body: z.object({
    instruction: z.string().min(5),
  }),
});

export const acceptRescheduleSchema = z.object({
  body: z.object({}).optional(),
});

export const rejectRescheduleSchema = z.object({
  body: z.object({}).optional(),
});
