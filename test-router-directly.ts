/**
 * Script para testar o router diretamente
 * Simula o que acontece quando uma mensagem chega do WhatsApp
 */

import { routerNode } from './ai/src/graph/nodes/router.js';
import { ThemisStateType } from './ai/src/graph/state.js';
import { HumanMessage, AIMessage } from '@langchain/core/messages';

const testCases: Array<{
  name: string;
  state: ThemisStateType;
  expectedBehavior: string;
}> = [
  {
    name: 'TESTE 1: Cliente Novo - "Quero agendar uma consulta"',
    state: {
      whatsappNumber: '5585988882100',
      messages: [
        new HumanMessage('Quero agendar uma consulta'),
      ],
      triage: {
        name: null,
        email: null,
        cpf: null,
        caseType: null,
        caseDescription: null,
        urgency: null,
        contactAvailability: null,
        currentStep: 'INITIAL',
      },
      needsHandoff: false,
      currentNode: 'router',
    },
    expectedBehavior: 'Deve iniciar coleta de triagedata (pedir nome)',
  },

  {
    name: 'TESTE 2: Cliente Retornando - "Quero marcar outra reunião" (SEM reunião aberta)',
    state: {
      whatsappNumber: '5585988882101',
      messages: [
        new HumanMessage('Olá, quero marcar outra reunião'),
      ],
      triage: {
        name: 'Jonas Lacerda',
        email: 'jonas@cliente.com',
        cpf: '08662542425',
        caseType: 'Direito Trabalhista',
        caseDescription: 'Demissão sem justa causa',
        urgency: 'MEDIA',
        contactAvailability: 'Noite',
        currentStep: 'DONE',
      },
      needsHandoff: false,
      currentNode: 'router',
    },
    expectedBehavior: 'Deve reconhecer cliente e pedir APENAS tipo do novo caso (NÃO re-pedir nome/email/cpf)',
  },

  {
    name: 'TESTE 3: Cliente com Reunião Aberta - "Quero agendar" (COM reunião aberta)',
    state: {
      whatsappNumber: '5585988882102',
      messages: [
        new HumanMessage('Gostaria de agendar uma reunião'),
      ],
      triage: {
        name: 'Carlos Silva',
        email: 'carlos@cliente.com',
        cpf: '12345678901',
        caseType: 'Direito Civil',
        caseDescription: 'Disputa contratual',
        urgency: 'ALTA',
        contactAvailability: 'Manhã',
        currentStep: 'DONE',
      },
      needsHandoff: false,
      currentNode: 'router',
    },
    expectedBehavior: 'Deve BLOQUEAR imediatamente (detectar reunião aberta e oferecer handoff)',
  },

  {
    name: 'TESTE 4: Cliente Confirmando Agendamento - "Sim"',
    state: {
      whatsappNumber: '5585988882103',
      messages: [
        new HumanMessage('Sua ficha foi registrada! Posso agendar uma consulta com o advogado para você agora?'),
        new HumanMessage('Sim'),
      ],
      triage: {
        name: 'Pedro Santos',
        email: 'pedro@cliente.com',
        cpf: '98765432100',
        caseType: 'Direito Trabalhista',
        caseDescription: 'Desvio de função',
        urgency: 'MEDIA',
        contactAvailability: 'Tarde',
        currentStep: 'DONE',
      },
      needsHandoff: false,
      currentNode: 'router',
    },
    expectedBehavior: 'Deve chamar check_open_appointments PRIMEIRO, depois oferecer horários de disponibilidade',
  },
];

async function runTest(testCase: typeof testCases[0]) {
  console.log(`\n${'═'.repeat(70)}`);
  console.log(`🔬 ${testCase.name}`);
  console.log(`${'═'.repeat(70)}`);
  console.log(`Expected: ${testCase.expectedBehavior}\n`);

  try {
    const result = await routerNode(testCase.state);

    if (result.messages && result.messages.length > 0) {
      console.log('✅ Router respondeu com mensagens:');
      for (const msg of result.messages) {
        const content = String(msg.content).substring(0, 200);
        console.log(`   • ${content}${String(msg.content).length > 200 ? '...' : ''}`);
      }
    } else {
      console.log('⚠️  Router retornou sem mensagens');
    }

    console.log(`\nNext node: ${result.currentNode}`);
    console.log(`Handoff needed: ${result.needsHandoff}`);

    // Validações específicas por teste
    if (testCase.name.includes('TESTE 2')) {
      const responseText = String(result.messages?.[0]?.content || '').toLowerCase();
      if (responseText.includes('nome') || responseText.includes('email') || responseText.includes('cpf')) {
        console.log('\n❌ FALHA: Está re-pedindo triagedata!');
      } else {
        console.log('\n✅ SUCESSO: Não re-pediu triagedata');
      }
    }

    if (testCase.name.includes('TESTE 3')) {
      const responseText = String(result.messages?.[0]?.content || '').toLowerCase();
      if (responseText.includes('reunião aberta') || responseText.includes('já tem')) {
        console.log('\n✅ SUCESSO: Bloqueou a reunião aberta');
      } else {
        console.log('\n❌ FALHA: Não bloqueou a reunião aberta');
      }
    }

    if (testCase.name.includes('TESTE 4')) {
      const responseText = String(result.messages?.[0]?.content || '').toLowerCase();
      // Verificar se contém contexto de open appointments
      if (responseText.includes('horário') || responseText.includes('disponível')) {
        console.log('\n✅ SUCESSO: Ofereceu horários após verificar abertas');
      } else if (responseText.includes('erro') || responseText === '') {
        console.log('\n❌ FALHA: Não respondeu ou deu erro');
      }
    }

  } catch (err: any) {
    console.log(`❌ Erro ao executar teste: ${err.message}`);
    console.log(err.stack);
  }
}

async function main() {
  console.log('\n🧪 TESTES DIREITOS DO ROUTER\n');
  console.log('Testando a lógica de roteamento com diferentes cenários...\n');

  for (const testCase of testCases) {
    await runTest(testCase);
    // Aguardar entre testes
    await new Promise(r => setTimeout(r, 1000));
  }

  console.log(`\n${'═'.repeat(70)}`);
  console.log('\n✅ Testes finalizados\n');
}

main().catch(err => {
  console.error('❌ Erro fatal:', err);
  process.exit(1);
});
