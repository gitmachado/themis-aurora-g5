/**
 * Script de teste para validar o fluxo de conversa da Themis AI
 * Simula múltiplos cenários e verifica se a IA responde corretamente
 */

import axios from 'axios';

const API_BASE = process.env.API_BASE || 'http://localhost:3000/api';
const TIMEOUT = 10000; // 10 segundos entre mensagens

interface TestCase {
  name: string;
  whatsappNumber: string;
  messages: Array<{
    role: 'user' | 'system';
    text: string;
    expectedContains?: string[];
    shouldNotContain?: string[];
    description?: string;
  }>;
}

class ConversationTester {
  private results: Array<{
    testName: string;
    messageIndex: number;
    passed: boolean;
    expected: string[];
    actual: string;
    error?: string;
  }> = [];

  async sendMessage(
    whatsappNumber: string,
    message: string,
    description: string
  ): Promise<{ text: string; success: boolean; error?: string }> {
    try {
      console.log(`\n📱 User (${whatsappNumber}): ${message}`);
      console.log(`   📝 Context: ${description}`);

      // Simular envio via webhook
      const response = await axios.post(
        `${API_BASE}/v1/bot/webhook`,
        {
          messages: [
            {
              from: whatsappNumber,
              body: message,
              timestamp: new Date().toISOString(),
            },
          ],
        },
        { timeout: TIMEOUT }
      );

      // Aguardar que a resposta seja enviada
      await new Promise(resolve => setTimeout(resolve, 2000));

      // Buscar últimas mensagens da conversa
      const messagesResponse = await axios.get(
        `${API_BASE}/v1/messages?phone=${whatsappNumber}&limit=1`,
        { timeout: TIMEOUT }
      );

      const lastMsg = messagesResponse.data?.[0];
      const aiText = lastMsg?.content || '[SEM RESPOSTA]';

      console.log(`   🤖 AI: ${aiText.substring(0, 150)}${aiText.length > 150 ? '...' : ''}`);

      return {
        text: aiText,
        success: aiText !== '[SEM RESPOSTA]',
      };
    } catch (err: any) {
      const error = err.response?.data?.message || err.message;
      console.log(`   ❌ Erro: ${error}`);
      return {
        text: '',
        success: false,
        error: String(error),
      };
    }
  }

  validateResponse(
    testName: string,
    messageIndex: number,
    aiResponse: string,
    expectedContains?: string[],
    shouldNotContain?: string[]
  ): boolean {
    let passed = true;
    const errors: string[] = [];

    if (expectedContains && expectedContains.length > 0) {
      const hasExpected = expectedContains.some(expected =>
        aiResponse.toLowerCase().includes(expected.toLowerCase())
      );
      if (!hasExpected) {
        passed = false;
        errors.push(`Não contém nenhum de: ${expectedContains.join(', ')}`);
      }
    }

    if (shouldNotContain && shouldNotContain.length > 0) {
      const hasForbidden = shouldNotContain.some(forbidden =>
        aiResponse.toLowerCase().includes(forbidden.toLowerCase())
      );
      if (hasForbidden) {
        passed = false;
        errors.push(`Contém texto que não deveria: ${shouldNotContain.join(', ')}`);
      }
    }

    this.results.push({
      testName,
      messageIndex,
      passed,
      expected: expectedContains || [],
      actual: aiResponse.substring(0, 100),
      error: errors.length > 0 ? errors.join('; ') : undefined,
    });

    return passed;
  }

  printResults(): void {
    console.log('\n\n═══════════════════════════════════════════════════════════');
    console.log('📊 RESULTADOS DOS TESTES');
    console.log('═══════════════════════════════════════════════════════════\n');

    const groupedByTest = new Map<string, typeof this.results>();
    for (const result of this.results) {
      if (!groupedByTest.has(result.testName)) {
        groupedByTest.set(result.testName, []);
      }
      groupedByTest.get(result.testName)!.push(result);
    }

    for (const [testName, results] of groupedByTest) {
      const passed = results.filter(r => r.passed).length;
      const total = results.length;
      const status = passed === total ? '✅' : '❌';

      console.log(`${status} ${testName}: ${passed}/${total} passou`);

      for (const result of results.filter(r => !r.passed)) {
        console.log(
          `   ❌ Mensagem ${result.messageIndex}: ${result.error}`
        );
      }
    }

    console.log('\n═══════════════════════════════════════════════════════════\n');
  }
}

const testCases: TestCase[] = [
  {
    name: '✅ CENÁRIO 1: Cliente Novo (Fluxo Completo)',
    whatsappNumber: '5585988882001',
    messages: [
      {
        role: 'user',
        text: 'Bom dia',
        expectedContains: ['Themis AI', 'como posso ajudar'],
        description: 'AI deve se apresentar',
      },
      {
        role: 'user',
        text: 'Eu gostaria de consultar um advogado',
        expectedContains: ['informações', 'nome completo'],
        description: 'AI deve iniciar triagedata collection',
      },
      {
        role: 'user',
        text: 'João Silva',
        expectedContains: ['e-mail', 'login'],
        description: 'AI deve pedir email após nome',
      },
      {
        role: 'user',
        text: 'joao@example.com',
        expectedContains: ['CPF'],
        description: 'AI deve pedir CPF após email',
      },
      {
        role: 'user',
        text: '12345678901',
        expectedContains: ['tipo de caso'],
        description: 'AI deve pedir tipo de caso após CPF',
      },
      {
        role: 'user',
        text: 'Direito Civil',
        expectedContains: ['descrição', 'caso'],
        description: 'AI deve pedir descrição',
      },
      {
        role: 'user',
        text: 'Disputa contratual',
        expectedContains: ['disponibilidade'],
        description: 'AI deve pedir disponibilidade',
      },
      {
        role: 'user',
        text: 'Manhã',
        expectedContains: ['registrada', 'agendar consulta'],
        description: 'AI deve confirmar triagedata e oferecer agendamento',
      },
      {
        role: 'user',
        text: 'Sim',
        expectedContains: ['disponível', 'horário', 'data'],
        shouldNotContain: ['nome', 'email', 'cpf'],
        description: 'AI deve verificar disponibilidade (NÃO pedir triagedata novamente)',
      },
    ],
  },

  {
    name: '⚠️ CENÁRIO 2: Cliente Retornando SEM Reunião Aberta',
    whatsappNumber: '5585988882002',
    messages: [
      {
        role: 'system',
        text: 'Preparar: Esta é a segunda vez que Jonas tenta agendar',
        description: 'Nota: Use o número de Jonas de antes',
      },
      {
        role: 'user',
        text: 'Bom dia',
        expectedContains: ['Themis', 'ajudar'],
        description: 'Greeting',
      },
      {
        role: 'user',
        text: 'Quero marcar outra reunião',
        expectedContains: ['Jonas', 'tipo de caso'],
        shouldNotContain: ['nome', 'email', 'cpf', 'disponibilidade'],
        description: 'AI deve reconhecer cliente e pedir APENAS novo tipo de caso (não re-coletar triagedata)',
      },
      {
        role: 'user',
        text: 'Direito Trabalhista',
        expectedContains: ['descrição'],
        description: 'AI deve pedir descrição do novo caso',
      },
      {
        role: 'user',
        text: 'Recebendo menos que combinado',
        expectedContains: ['disponível', 'horário'],
        description: 'AI deve oferecer agendamento (use availability anterior)',
      },
    ],
  },

  {
    name: '🚫 CENÁRIO 3: Cliente Retornando COM Reunião Aberta (BLOQUEIO)',
    whatsappNumber: '5585988882003',
    messages: [
      {
        role: 'system',
        text: 'Preparar: Este cliente tem 1 reunião em PENDING_APPROVAL',
        description: 'Setup: Crie manual uma reunião aberta para este número',
      },
      {
        role: 'user',
        text: 'Quero marcar uma reunião',
        expectedContains: ['já tem', 'reunião aberta', 'handoff'],
        shouldNotContain: ['disponível', 'horário', 'data', 'tipo de caso'],
        description: 'AI deve BLOQUEAR imediatamente (não oferecer agendamento)',
      },
    ],
  },
];

async function runTests() {
  const tester = new ConversationTester();

  console.log('🧪 INICIANDO TESTES DE CONVERSA DA THEMIS AI');
  console.log('═══════════════════════════════════════════════════════════\n');

  for (const testCase of testCases) {
    console.log(`\n${'═'.repeat(60)}`);
    console.log(`🔬 ${testCase.name}`);
    console.log(`${'═'.repeat(60)}`);

    for (let i = 0; i < testCase.messages.length; i++) {
      const msg = testCase.messages[i];

      if (msg.role === 'system') {
        console.log(`\nℹ️  ${msg.text}`);
        console.log(`   ${msg.description}`);
        continue;
      }

      const response = await tester.sendMessage(
        testCase.whatsappNumber,
        msg.text,
        msg.description || ''
      );

      if (response.success) {
        const passed = tester.validateResponse(
          testCase.name,
          i,
          response.text,
          msg.expectedContains,
          msg.shouldNotContain
        );

        if (passed) {
          console.log(`   ✅ Validação passou`);
        } else {
          console.log(`   ❌ Validação FALHOU`);
        }
      } else {
        console.log(`   ❌ Erro obtendo resposta: ${response.error}`);
        tester.validateResponse(testCase.name, i, '', msg.expectedContains);
      }

      // Aguardar entre mensagens
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
  }

  tester.printResults();
}

// Executar
runTests().catch(err => {
  console.error('❌ Erro ao executar testes:', err);
  process.exit(1);
});
