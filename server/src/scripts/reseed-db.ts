import fs from 'fs';
import path from 'path';
import dotenv from 'dotenv';
import pool from '../config/database';

dotenv.config({ path: path.join(__dirname, '../../.env') });

const seedFile = path.join(__dirname, '../../database/seed.sql');

async function reseed() {
  if (!fs.existsSync(seedFile)) {
    console.error(`Seed file not found at ${seedFile}`);
    process.exitCode = 1;
    return;
  }

  const sql = fs.readFileSync(seedFile, 'utf8');
  const client = await pool.connect();

  try {
    await client.query('BEGIN');
    await client.query(sql);
    await client.query('COMMIT');
    console.log('Database reseeded successfully.');
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Failed to reseed database:', error);
    process.exitCode = 1;
  } finally {
    client.release();
    await pool.end();
  }
}

reseed();
