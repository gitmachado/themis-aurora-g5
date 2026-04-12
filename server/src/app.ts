import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import path from 'path';
import { errorHandler } from './middlewares/errorHandler';
import routes from './routes';

const app = express();

// Middlewares
app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());

// API Routes
app.use('/api/v1', routes);

// Base route
app.get('/', (req, res) => {
  res.json({ message: 'OmniConnect API is running', version: '1.0.0' });
});

// Error handling (must be last)
app.use(errorHandler);

export default app;
