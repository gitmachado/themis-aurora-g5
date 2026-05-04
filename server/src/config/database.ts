import { Pool } from 'pg';
import dotenv from 'dotenv';
import path from 'path';

// Load .env from root of server
dotenv.config({ path: path.join(__dirname, '../../.env') });

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || 'themis_db',
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
  client_encoding: 'UTF8',
});

// Test connection
pool.on('connect', () => {
  console.log('Database connected successfully');
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle client', err);
});

export const dbGet = async <T>(text: string, params?: any[]): Promise<T | null> => {
  const { rows } = await pool.query(text, params);
  return rows[0] || null;
};

export const dbAll = async <T>(text: string, params?: any[]): Promise<T[]> => {
  const { rows } = await pool.query(text, params);
  return rows;
};

export const dbRun = async (text: string, params?: any[]): Promise<number> => {
  const { rowCount } = await pool.query(text, params);
  return rowCount || 0;
};

export default pool;
