import 'dotenv/config';
import { createLead } from '../utils/backend-client.js';

async function main() {
  try {
    const lead = await createLead({
      name: 'Mauricio Machado',
      whatsappNumber: '555183342505',
      cpf: '04702674021',
      caseType: 'Civil',
      caseDescription: 'Triagem em andamento via WhatsApp',
      urgency: 'Medium',
      contactAvailability: 'Morning'
    });
    console.log('✅ Lead criado com ID:', lead.id);
  } catch (err) {
    console.error('❌ Erro ao criar lead:', err);
  }
  process.exit(0);
}

main();
