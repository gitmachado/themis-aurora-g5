import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import { errorHandler } from './middlewares/implementations/errorHandler';
import routes from './routes';
import swaggerUi from 'swagger-ui-express';
import { swaggerSpec } from './config/swagger';
import { getAllowedCorsOrigins, isSwaggerEnabled } from './config/runtime';
import { getUploadDir } from './utils/storage/storage-paths';

const app = express();
const allowedCorsOrigins = getAllowedCorsOrigins();

// Middlewares
app.use(helmet());
app.use(cors({
  origin: (origin: string | undefined, callback: (error: Error | null, allow?: boolean) => void) => {
    if (!origin || allowedCorsOrigins.includes(origin)) {
      return callback(null, true);
    }

    return callback(new Error('Origin not allowed by CORS'));
  },
}));
app.use(morgan('dev'));
app.use(express.json());
app.use('/uploads', express.static(getUploadDir()));

// API Routes
app.use('/api/v1', routes);

// Swagger Documentation
if (isSwaggerEnabled()) {
  app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
}

app.get('/health', (_req, res) => {
  res.status(200).json({ status: 'ok' });
});

// Base route
app.get('/', (req, res) => {
  res.json({ message: 'OmniConnect API is running', version: '1.0.0' });
});

// Error handling (must be last)
app.use(errorHandler);

export default app;
