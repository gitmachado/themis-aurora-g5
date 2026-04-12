import { z } from 'zod';

/**
 * @openapi
 * components:
 *   schemas:
 *     MessageSyncRequest:
 *       type: object
 *       required: [whatsappNumber, content, senderRole, messageType]
 *       properties:
 *         whatsappNumber:
 *           type: string
 *         content:
 *           type: string
 *         senderRole:
 *           type: string
 *           enum: [CLIENT, LAWYER, BOT]
 *         messageType:
 *           type: string
 *           enum: [TEXT, IMAGE, DOCUMENT]
 */

export const syncMessageSchema = z.object({
  body: z.object({
    whatsappNumber: z.string().min(10),
    content: z.string(),
    senderRole: z.enum(['CLIENT', 'LAWYER', 'BOT']),
    messageType: z.enum(['TEXT', 'IMAGE', 'DOCUMENT']),
  }),
});
