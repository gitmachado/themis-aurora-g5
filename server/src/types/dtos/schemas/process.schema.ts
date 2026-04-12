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
