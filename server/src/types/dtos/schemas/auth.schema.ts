import { z } from 'zod';

/**
 * @openapi
 * components:
 *   schemas:
 *     LoginRequest:
 *       type: object
 *       required: [email, password]
 *       properties:
 *         email:
 *           type: string
 *           format: email
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
 *         email:
 *           type: string
 *         password:
 *           type: string
 */

export const loginSchema = z.object({
  body: z.object({
    email: z.string().email(),
    password: z.string().min(6),
  }),
});

export const registerSchema = z.object({
  body: z.object({
    name: z.string().min(3),
    whatsappNumber: z.string().min(10),
    cpf: z.string().length(11),
    email: z.string().email().optional(),
    password: z.string().min(6),
  }),
});
