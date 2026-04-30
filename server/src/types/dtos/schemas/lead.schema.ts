import { z } from 'zod';

/**
 * @openapi
 * components:
 *   schemas:
 *     LeadCreateRequest:
 *       type: object
 *       required: [whatsappNumber]
 *       properties:
 *         name:
 *           type: string
 *         email:
 *           type: string
 *         whatsappNumber:
 *           type: string
 *         cpf:
 *           type: string
 *         caseType:
 *           type: string
 *           enum: [Labor, Civil, Family, Criminal, SocialSecurity]
 *         caseDescription:
 *           type: string
 *         urgency:
 *           type: string
 *           enum: [High, Medium, Low]
 *         contactAvailability:
 *           type: string
 *           enum: [Morning, Afternoon, Evening]
 */

export const createLeadSchema = z.object({
  body: z.object({
    name: z.string().min(3).optional(),
    email: z.string().email().optional(),
    whatsappNumber: z.string().min(10),
    cpf: z.string().length(11).optional(),
    caseType: z.enum(['Labor', 'Civil', 'Family', 'Criminal', 'SocialSecurity']).optional(),
    caseDescription: z.string().optional(),
    description: z.string().optional(),
    urgency: z.enum(['High', 'Medium', 'Low']).optional(),
    contactAvailability: z.enum(['Morning', 'Afternoon', 'Evening']).optional(),
  }),
});
