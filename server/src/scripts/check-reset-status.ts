import { Client } from 'pg';
import dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.join(__dirname, '../../.env') });

async function run() {
  const connectionString = 'postgresql://postgres:postgres@localhost:5433/themis_db';
  const client = new Client({ connectionString });
  
  try {
    await client.connect();
    const res = await client.query("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'");
    console.log('Tabelas encontradas:', res.rows.map(r => r.table_name));
    
    // Verificar se tem dados na tabela configurations
    const configRes = await client.query("SELECT * FROM configurations");
    console.log('Configurações:', configRes.rows);
    
  } catch (err) {
    console.error('Erro:', err);
  } finally {
    await client.end();
  }
}

run();
