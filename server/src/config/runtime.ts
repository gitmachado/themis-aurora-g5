import dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.join(__dirname, '../../.env') });

const DEFAULT_DEV_JWT_SECRET = 'development-only-secret-change-me';
const DEFAULT_DEV_CORS_ORIGINS = [
  'http://localhost:3000',
  'http://127.0.0.1:3000',
  'http://localhost:8080',
  'http://127.0.0.1:8080',
];

export const isProduction = (): boolean => process.env.NODE_ENV === 'production';

export const getJwtSecret = (): string => {
  if (process.env.JWT_SECRET) {
    return process.env.JWT_SECRET;
  }

  if (isProduction()) {
    throw new Error('JWT_SECRET is required when NODE_ENV=production');
  }

  console.warn('WARNING: JWT_SECRET not configured. Falling back to a development-only secret.');
  return DEFAULT_DEV_JWT_SECRET;
};

export const getBotApiKey = (): string | undefined => {
  if (process.env.BOT_API_KEY) {
    return process.env.BOT_API_KEY;
  }

  if (isProduction()) {
    throw new Error('BOT_API_KEY is required when NODE_ENV=production');
  }

  return undefined;
};

export const getSupabaseUrl = (): string | undefined => process.env.SUPABASE_URL;

export const getSupabasePublishableKey = (): string | undefined =>
  process.env.SUPABASE_PUBLISHABLE_KEY || process.env.SUPABASE_ANON_KEY;

export const getSupabaseServiceRoleKey = (): string | undefined =>
  process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SECRET_KEY;

export const getSupabaseAuthRedirectUrl = (): string | undefined =>
  process.env.SUPABASE_AUTH_REDIRECT_URL;

export const getAllowedCorsOrigins = (): string[] => {
  const configuredOrigins = process.env.CORS_ORIGIN
    ?.split(',')
    .map((origin: string) => origin.trim())
    .filter(Boolean);

  if (configuredOrigins && configuredOrigins.length > 0) {
    return configuredOrigins;
  }

  if (isProduction()) {
    throw new Error('CORS_ORIGIN is required when NODE_ENV=production');
  }

  return DEFAULT_DEV_CORS_ORIGINS;
};

export const isSwaggerEnabled = (): boolean => !isProduction();

export const validateRuntimeEnv = (): void => {
  getJwtSecret();
  getAllowedCorsOrigins();

  if (isProduction()) {
    getBotApiKey();
  }
};
