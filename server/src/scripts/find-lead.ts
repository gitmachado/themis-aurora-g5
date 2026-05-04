import { Client } from 'pg';
import dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.join(__dirname, '../../.env') });

async function run() {
  const client = new Client({
    connectionString: 'postgresql://postgres:postgres@localhost:5433/themis_db'
  });
  
  try {
    await client.connect();
    console.log('🔍 Buscando por Mauricio Machado...');
    
    const leads = await client.query("SELECT * FROM leads WHERE name ILIKE '%Mauricio%' OR name ILIKE '%Machado%'");
    console.log('Leads encontrados:', leads.rows);
    
    const users = await client.query("SELECT * FROM users WHERE name ILIKE '%Mauricio%' OR name ILIKE '%Machado%'");
    console.log('Usuários encontrados:', users.rows);
    
  } catch (err) {
    console.error('Erro:', err);
  } finally {
    await client.end();
  }
}

run();
