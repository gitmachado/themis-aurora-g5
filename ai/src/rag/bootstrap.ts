import fs from 'fs';
import path from 'path';
import { execSync } from 'child_process';
import "dotenv/config";
import { Client } from 'pg';

/**
 * Script de inicialização do módulo de IA.
 * Garante que a base de conhecimento esteja sempre indexada e atualizada.
 */
async function bootstrap() {
  const DATABASE_URL = process.env.DATABASE_URL || "postgresql://postgres:postgres@localhost:5433/themis_db";
  const knowledgeDir = path.resolve('knowledge');

  console.log('[AI Bootstrap] Verificando base de conhecimento...');

  // 1. Conecta ao banco para verificar se já existem embeddings
  const client = new Client({ connectionString: DATABASE_URL });
  await client.connect();
  
  try {
    const res = await client.query('SELECT COUNT(*) FROM knowledge_embeddings');
    const count = parseInt(res.rows[0].count, 10);

    if (count > 0) {
      console.log(`[AI Bootstrap] Base já contém ${count} trechos indexados. Pulando indexação inicial.`);
      return;
    }

    console.log('[AI Bootstrap] Base vazia ou resetada. Iniciando indexação automática...');

    const pdfs = fs.readdirSync(knowledgeDir).filter(f => f.endsWith('.pdf'));

    for (const pdf of pdfs) {
      const fullPath = path.join(knowledgeDir, pdf);
      console.log(`[AI Bootstrap] Indexando: ${pdf}`);
      try {
        // Executa o indexador via CLI
        execSync(`tsx src/rag/indexer.ts "${fullPath}"`, { stdio: 'inherit' });
      } catch (err) {
        console.error(`[AI Bootstrap] Erro ao indexar ${pdf}:`, err.message);
      }
    }

    console.log('[AI Bootstrap] ✅ Indexação concluída com sucesso!');
  } catch (err) {
    console.warn('[AI Bootstrap] Erro ao verificar banco (tabela pode não existir ainda):', err.message);
  } finally {
    await client.end();
  }
}

bootstrap().catch(err => {
  console.error('[AI Bootstrap] Falha crítica:', err);
  process.exit(1);
});
