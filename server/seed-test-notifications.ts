import { dbRun } from './src/config/database';
import crypto from 'crypto';

async function seedNotifications() {
  const userId = 'b1f9e8d7-c6b5-a4b3-92a1-0f9e8d7c6b5a';
  
  const types = ['NEW_LEAD', 'STATUS_CHANGED', 'DOCUMENT_SENT', 'HUMAN_SUPPORT'];
  const titles = [
    'Novo Lead Recebido',
    'Documento Assinado',
    'Movimentação Processual',
    'Nova Mensagem do Cliente',
    'Alerta de Prazo'
  ];
  
  console.log('Inserting 15 notifications...');
  
  for (let i = 0; i < 15; i++) {
    const isRead = i % 3 === 0;
    const type = types[i % types.length];
    const title = `${titles[i % titles.length]} #${i + 1}`;
    
    await dbRun(
      'INSERT INTO notifications (id, user_id, title, body, type, is_read, created_at) VALUES ($1, $2, $3, $4, $5, $6, $7)',
      [
        crypto.randomUUID(),
        userId,
        title,
        `Esta é uma notificação de teste para validar o modo de seleção e exclusão em massa. Item número ${i + 1}.`,
        type,
        isRead,
        new Date(Date.now() - i * 3600000)
      ]
    );
  }
  
  console.log('Done!');
  process.exit(0);
}

seedNotifications().catch(err => {
  console.error(err);
  process.exit(1);
});
