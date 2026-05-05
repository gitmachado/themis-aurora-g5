import { z } from 'zod';

/**
 * @openapi
 * components:
 *   schemas:
 *     CreateTeamMemberRequest:
 *       type: object
 *       required: [name, email, whatsappNumber, oabNumber, specialty]
 *       properties:
 *         name:
 *           type: string
 *         email:
 *           type: string
 *           format: email
 *         whatsappNumber:
 *           type: string
 *         oabNumber:
 *           type: string
 *         specialty:
 *           type: string
 *           enum: [Labor, Civil, Family, Criminal, SocialSecurity]
 *     UpdateTeamPermissionsRequest:
 *       type: object
 *       required: [permissions]
 *       properties:
 *         permissions:
 *           type: object
 *           additionalProperties:
 *             type: boolean
 */

export const createTeamMemberSchema = z.object({
  body: z.object({
    name: z.string().min(3, 'Nome deve ter ao menos 3 caracteres'),
    email: z.string().email('E-mail inválido'),
    whatsappNumber: z.string().min(10, 'WhatsApp inválido'),
    oabNumber: z.string().min(3, 'OAB inválida'),
    specialty: z.enum(['Labor', 'Civil', 'Family', 'Criminal', 'SocialSecurity']),
  }),
});

export const updateTeamPermissionsSchema = z.object({
  body: z.object({
    permissions: z.record(z.string(), z.boolean()),
  }),
});
