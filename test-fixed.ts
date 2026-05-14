/**
 * Script de teste SIMPLIFICADO para validar o fluxo de conversa da Themis AI
 * Testa apenas os casos críticos
 */

import axios from 'axios';

const AI_BASE = process.env.AI_BASE || 'http://localhost:3005';
const TIMEOUT = 8000;

interface Message {
  from: string;
  body: string;
  timestamp: Date;
}

async function sendMessage(whatsappNumber: string, text: string): Promise<{ ok: boolean; error?: string }> {
  try {
    console.log(`📱 Enviando para ${whatsappNumber}: "${text}"`);

    const payload = {
      entry: [{
        changes: [{
          value: {
            messages: [{
              from: whatsappNumber,
              type: 'text',
              text: { body: text },
              timestamp: new Date().toISOString(),
              id: `msg_${Date.now()}`,
            }],
          },
        }],
      }],
    };

    const response = await axios.post(
      `${AI_BASE}/webhook`,
      payload,
      { timeout: TIMEOUT }
    );

    console.log(`   ✅ Webhook recebeu (status: ${response.status})`);

    // Aguardar para IA processar
    await new Promise(resolve => setTimeout(resolve, 2000));

    return { ok: true };
  } catch (err: any) {
    const msg = err.message || err.response?.statusText || 'Erro desconhecido';
    console.log(`   ❌ Erro: ${msg}`);
    return { ok: false, error: msg };
  }
}

async function runTest() {
  console.log('🧪 TESTE SIMPLIFICADO - Fluxo de Triagedata e Agendamento\n');

  const testPhone = '5585988882001';

  console.log('─'.repeat(60));
  console.log('📋 TESTE 1: Cliente Novo - Triagedata Completo');
  console.log('─'.repeat(60));

  const steps = [
    { text: 'Olá', desc: 'Abertura' },
    { text: 'Quero agendar uma consulta', desc: 'Intent de agendamento' },
    { text: 'João Silva', desc: 'Nome completo' },
    { text: 'joao@example.com', desc: 'Email' },
    { text: '12345678901', desc: 'CPF' },
    { text: 'Direito Civil', desc: 'Tipo de caso' },
    { text: 'Disputa contratual', desc: 'Descrição' },
    { text: 'Manhã', desc: 'Disponibilidade' },
    { text: 'Sim', desc: '**CRÍTICO** - Deve chamar check_open_appointments e depois check_availability' },
  ];

  for (let i = 0; i < steps.length; i++) {
    const step = steps[i];
    console.log(`\n[${i + 1}/${steps.length}] ${step.desc}`);

    const result = await sendMessage(testPhone, step.text);
    if (!result.ok) {
      console.log(`❌ FALHOU: ${result.error}`);
      break;
    }

    if (i < steps.length - 1) {
      await new Promise(resolve => setTimeout(resolve, 500));
    }
  }

  console.log('\n' + '─'.repeat(60));
  console.log('✅ Teste concluído');
  console.log('─'.repeat(60));
  console.log('\n📌 Próximos passos: Verifique os logs do servidor para confirmar que a IA respondeu corretamente.');
}

runTest().catch(err => {
  console.error('Erro:', err);
  process.exit(1);
});
