import swaggerJsdoc from 'swagger-jsdoc';

const options: swaggerJsdoc.Options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'OmniConnect API',
      version: '1.0.0',
      description: 'Documentação da API do projeto OmniConnect - Aurora G5',
    },
    servers: [
      {
        url: 'http://localhost:3000/api/v1',
        description: 'Servidor de Desenvolvimento',
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          description: 'Insira o token JWT retornado no login: "Bearer {token}"',
        },
        apiKeyAuth: {
          type: 'apiKey',
          in: 'header',
          name: 'x-api-key',
          description: 'Chave de API para integrações externas (Bot WhatsApp)',
        },
      },
      schemas: {
        User: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            name: { type: 'string' },
            whatsappNumber: { type: 'string' },
            cpf: { type: 'string', nullable: true },
            email: { type: 'string', nullable: true },
            role: { type: 'string', enum: ['CLIENT', 'LAWYER'] },
            createdAt: { type: 'string', format: 'date-time' },
            updatedAt: { type: 'string', format: 'date-time' },
          },
        },
        Lead: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            name: { type: 'string', nullable: true },
            whatsappNumber: { type: 'string' },
            cpf: { type: 'string', nullable: true },
            caseType: { type: 'string', nullable: true },
            caseDescription: { type: 'string', nullable: true },
            urgency: { type: 'string', nullable: true },
            contactAvailability: { type: 'string', nullable: true },
            status: { type: 'string', enum: ['PENDING', 'CONTACTED', 'CONVERTED', 'DISCARDED'] },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        LegalProcess: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            clientId: { type: 'string' },
            lawyerId: { type: 'string', nullable: true },
            title: { type: 'string' },
            description: { type: 'string', nullable: true },
            currentStatus: { type: 'string' },
            processNumber: { type: 'string', nullable: true },
            caseType: { type: 'string' },
            lastNote: { type: 'string', nullable: true },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        Document: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            legalProcessId: { type: 'string' },
            fileName: { type: 'string' },
            fileUrl: { type: 'string' },
            sizeBytes: { type: 'number', nullable: true },
            mimeType: { type: 'string', nullable: true },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        Notification: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            userId: { type: 'string' },
            type: { type: 'string' },
            title: { type: 'string' },
            body: { type: 'string' },
            isRead: { type: 'boolean' },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        TimelineEvent: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            legalProcessId: { type: 'string' },
            type: { type: 'string' },
            content: { type: 'string' },
            previousStatus: { type: 'string', nullable: true },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        Message: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            sender: { type: 'string', enum: ['CLIENT', 'LAWYER', 'BOT'] },
            content: { type: 'string' },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        Error: {
          type: 'object',
          properties: {
            message: { type: 'string' },
            errorCode: { type: 'string' },
            statusCode: { type: 'number' },
          },
        },
        ValidationError: {
          type: 'object',
          properties: {
            message: { type: 'string' },
            errors: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  path: { type: 'array', items: { type: 'string' } },
                  message: { type: 'string' },
                },
              },
            },
          },
        },
      },
    },
  },
  apis: ['./src/routes/v1/*.ts', './src/types/dtos/schemas/*.ts'], // Caminho para os arquivos de rotas e schemas
};

export const swaggerSpec = swaggerJsdoc(options);
