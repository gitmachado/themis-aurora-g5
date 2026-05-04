import fs from 'fs';
import path from 'path';
import { Client } from 'pg';
import dotenv from 'dotenv';

dotenv.config({ path: path.join(__dirname, '../../.env') });

async function run() {
  const connectionString = 'postgresql://postgres:postgres@localhost:5433/themis_db';
  const client = new Client({ connectionString });

  try {
    await client.connect();
    console.log('🧨 Iniciando RESET TOTAL do banco de dados...');

    // 1. Dropar todas as tabelas na ordem correta (ou usar DROP SCHEMA public CASCADE)
    console.log('🗑️ Removendo todas as tabelas...');
    await client.query('DROP SCHEMA public CASCADE; CREATE SCHEMA public;');
    await client.query('GRANT ALL ON SCHEMA public TO postgres; GRANT ALL ON SCHEMA public TO public;');
    
    // 2. Recriar Schema
    console.log('📝 Recriando Schema...');
    const schemaPath = path.join(__dirname, '../../database/schema.sql');
    const schemaSql = fs.readFileSync(schemaPath, 'utf8');
    await client.query(schemaSql);

    // 3. Rodar Seed
    console.log('🌱 Populando dados iniciais (Seed)...');
    const seedPath = path.join(__dirname, '../../database/seed.sql');
    const seedSql = fs.readFileSync(seedPath, 'utf8');
    await client.query(seedSql);

    console.log('✨ Banco de dados resetado com sucesso! Tudo limpo e pronto.');
    process.exit(0);
  } catch (err) {
    console.error('❌ Erro durante o reset total:', err);
    process.exit(1);
  } finally {
    await client.end();
  }
}

run();
