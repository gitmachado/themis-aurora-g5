import fs from 'fs';
import path from 'path';
import dotenv from 'dotenv';
import pool from '../config/database';

dotenv.config({ path: path.join(__dirname, '../../.env') });

const migrationsDir = path.join(__dirname, '../../database/migrations');

async function ensureMigrationsTable() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS schema_migrations (
      id TEXT PRIMARY KEY,
      applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
  `);
}

async function getAppliedMigrations() {
  const { rows } = await pool.query<{ id: string }>('SELECT id FROM schema_migrations');
  return new Set(rows.map((row) => row.id));
}

async function runMigration(fileName: string) {
  const filePath = path.join(migrationsDir, fileName);
  const sql = fs.readFileSync(filePath, 'utf8');
  const client = await pool.connect();

  try {
    await client.query('BEGIN');
    await client.query(sql);
    await client.query('INSERT INTO schema_migrations (id) VALUES ($1)', [fileName]);
    await client.query('COMMIT');
    console.log(`Applied migration: ${fileName}`);
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

async function migrate() {
  try {
    await ensureMigrationsTable();

    if (!fs.existsSync(migrationsDir)) {
      console.log('No migrations directory found.');
      return;
    }

    const appliedMigrations = await getAppliedMigrations();
    const pendingMigrations = fs
      .readdirSync(migrationsDir)
      .filter((fileName) => fileName.endsWith('.sql'))
      .sort()
      .filter((fileName) => !appliedMigrations.has(fileName));

    if (pendingMigrations.length === 0) {
      console.log('No pending migrations.');
      return;
    }

    for (const fileName of pendingMigrations) {
      await runMigration(fileName);
    }

    console.log('Database migrations completed.');
  } catch (error) {
    console.error('Failed to run database migrations:', error);
    process.exitCode = 1;
  } finally {
    await pool.end();
  }
}

migrate();
