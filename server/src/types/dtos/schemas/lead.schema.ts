import { z } from 'zod';

/**
 * @openapi
 * components:
 *   schemas:
 *     LeadCreateRequest:
 *       type: object
 *       required: [name, whatsappNumber, cpf, caseType, description, urgency, contactAvailability]
 *       properties:
 *         name:
 *           type: string
 *         whatsappNumber:
 *           type: string
 *         cpf:
 *           type: string
 *         caseType:
 *           type: string
 *           enum: [Labor, Civil, Family, Criminal, SocialSecurity]
 *         description:
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
    name: z.string().min(3),
    whatsappNumber: z.string().min(10),
    cpf: z.string().length(11),
    caseType: z.enum(['Labor', 'Civil', 'Family', 'Criminal', 'SocialSecurity']),
    description: z.string(),
    urgency: z.enum(['High', 'Medium', 'Low']),
    contactAvailability: z.enum(['Morning', 'Afternoon', 'Evening']),
  }),
});
