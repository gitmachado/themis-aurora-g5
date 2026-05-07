import { z } from 'zod';

/**
 * @openapi
 * components:
 *   schemas:
 *     ProcessStatusUpdateRequest:
 *       type: object
 *       required: [status]
 *       properties:
 *         status:
 *           type: string
 *         reason:
 *           type: string
 */

export const updateProcessStatusSchema = z.object({
  body: z.object({
    status: z.string().min(1),
    reason: z.string().optional(),
  }),
});

export const createProcessSchema = z.object({
  body: z.object({
    clientId: z.string().uuid(),
    title: z.string().min(3),
    description: z.string().optional(),
    caseType: z.enum(['Labor', 'Civil', 'Family', 'Criminal', 'SocialSecurity']),
    processNumber: z.string().optional(),
  }),
});

