import { z } from 'zod';

/**
 * @openapi
 * components:
 *   schemas:
 *     LoginRequest:
 *       type: object
 *       required: [identifier, password]
 *       properties:
 *         identifier:
 *           type: string
 *           description: CPF ou numero de WhatsApp
 *         whatsappNumber:
 *           type: string
 *           deprecated: true
 *         cpf:
 *           type: string
 *           deprecated: true
 *         password:
 *           type: string
 *     RegisterRequest:
 *       type: object
 *       required: [name, whatsappNumber, cpf, password]
 *       properties:
 *         name:
 *           type: string
 *         whatsappNumber:
 *           type: string
 *         cpf:
 *           type: string
 *         password:
 *           type: string
 */

export const loginSchema = z.object({
  body: z.object({
    identifier: z.string().min(10).optional(),
    whatsappNumber: z.string().min(10).optional(),
    cpf: z.string().min(10).optional(),
    password: z.string().min(6),
  }).refine(
    data => data.identifier || data.whatsappNumber || data.cpf,
    {
      message: 'CPF ou numero de WhatsApp e obrigatorio',
      path: ['identifier'],
    }
  ),
});

export const registerSchema = z.object({
  body: z.object({
    name: z.string().min(3),
    whatsappNumber: z.string().min(10),
    cpf: z.string().length(11),
    password: z.string().min(6),
  }),
});
