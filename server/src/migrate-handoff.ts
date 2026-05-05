import { Pool } from 'pg';
import path from 'path';
import dotenv from 'dotenv';

dotenv.config({ path: path.join(__dirname, '../.env') });

const pool = new Pool({
  host: process.env.DB_HOST === 'postgres' ? 'localhost' : process.env.DB_HOST,
  port: process.env.DB_HOST === 'postgres' ? 5433 : parseInt(process.env.DB_PORT || '5432'),
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || 'themis_db',
});

async function migrate() {
  try {
    console.log('Iniciando migração: Adicionando coluna is_ai_paused à tabela leads...');
    await pool.query('ALTER TABLE leads ADD COLUMN IF NOT EXISTS is_ai_paused BOOLEAN DEFAULT FALSE;');
    console.log('Migração concluída com sucesso!');
  } catch (err) {
    console.error('Erro na migração:', err);
  } finally {
    await pool.end();
  }
}

migrate();
