import { Client } from 'pg';
import dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.join(__dirname, '../../.env') });

async function run() {
  const client = new Client({
    connectionString: 'postgresql://postgres:postgres@localhost:5433/omniconnect_db'
  });
  
  try {
    await client.connect();
    console.log('➕ Adicionando lead Mauricio Machado...');
    
    // Deletar se já existir (mesmo nome ou número se soubéssemos, mas vamos pelo nome para garantir o "reset")
    await client.query("DELETE FROM leads WHERE name = 'Mauricio Machado'");
    
    const res = await client.query(`
      INSERT INTO leads (id, whatsapp_number, name, email, case_type, case_description, urgency, status)
      VALUES (uuid_generate_v4(), '5511912345678', 'Mauricio Machado', 'mauricio.machado@example.com', 'Civil', 'Teste de chat vivo e handoff.', 'High', 'PENDING')
      RETURNING *
    `);
    
    console.log('✅ Lead Mauricio Machado adicionado com sucesso:', res.rows[0]);
    
  } catch (err) {
    console.error('Erro:', err);
  } finally {
    await client.end();
  }
}

run();
