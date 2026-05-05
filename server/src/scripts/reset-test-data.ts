import fs from 'fs';
import path from 'path';
import { Client } from 'pg';
import dotenv from 'dotenv';

dotenv.config({ path: path.join(__dirname, '../../.env') });

async function reset() {
  // Tenta usar a DATABASE_URL do .env da IA se existir, ou localhost:5433 que é o padrão local observado
  const connectionString = process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5433/themis_db';
  
  const client = new Client({
    connectionString
  });

  try {
    await client.connect();
    console.log('🗑️ Removendo dados de teste (leads, processos, mensagens)...');
    
    await client.query('DELETE FROM notifications');
    await client.query('DELETE FROM messages');
    await client.query('DELETE FROM timeline_events');
    await client.query('DELETE FROM documents');
    await client.query('DELETE FROM legal_processes');
    await client.query('DELETE FROM leads');
    await client.query("DELETE FROM users WHERE role = 'CLIENT'");
    
    console.log('🌱 Re-populando com dados do seed...');
    const seedPath = path.join(__dirname, '../../database/seed.sql');
    const seedSql = fs.readFileSync(seedPath, 'utf8');
    
    await client.query(seedSql);

    console.log('✨ Sucesso! Leads resetados para o estado inicial (PENDING).');
    process.exit(0);
  } catch (err) {
    console.error('❌ Erro ao resetar dados:', err);
    process.exit(1);
  } finally {
    await client.end();
  }
}

reset();
