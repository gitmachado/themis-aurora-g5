#!/usr/bin/env node

/**
 * Script simples de teste para a Themis AI
 * Simula conversas e valida respostas
 *
 * Uso: node test-ai-flow.js
 */

const http = require('http');

const API_BASE = process.env.API_BASE || 'http://localhost:3000';
const WEBHOOK_URL = `${API_BASE}/api/v1/bot/webhook`;

// Função para fazer requisições HTTP
function makeRequest(method, url, body) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(url);
    const options = {
      hostname: urlObj.hostname,
      port: urlObj.port || 80,
      path: urlObj.pathname + urlObj.search,
      method: method,
      headers: {
        'Content-Type': 'application/json',
      },
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          resolve({
            status: res.statusCode,
            data: JSON.parse(data),
          });
        } catch {
          resolve({
            status: res.statusCode,
            data: data,
          });
        }
      });
    });

    req.on('error', reject);
    if (body) {
      req.write(JSON.stringify(body));
    }
    req.end();
  });
}

// Testes
const tests = [
  {
    name: 'TESTE 1: Cliente Novo - Triagedata Completa',
    phone: '5585988882100',
    messages: [
      {
        text: 'Olá',
        waitFor: 'Themis AI',
        description: 'Abertura',
      },
      {
        text: 'Quero agendar uma consulta',
        waitFor: 'nome completo',
        description: 'Inicia triagedata',
      },
      {
        text: 'Maria Silva',
        waitFor: 'e-mail',
        description: 'Nome coletado',
      },
      {
        text: 'maria@test.com',
        waitFor: 'CPF',
        description: 'Email coletado',
      },
      {
        text: '12345678901',
        waitFor: 'tipo de caso',
        description: 'CPF coletado',
      },
      {
        text: 'Direito Trabalhista',
        waitFor: 'descrição',
        description: 'Tipo de caso coletado',
      },
      {
        text: 'Desvio de função',
        waitFor: 'disponibilidade',
        description: 'Descrição coletada',
      },
      {
        text: 'Tarde',
        waitFor: 'registrada',
        description: 'Triagedata completa',
      },
      {
        text: 'Sim',
        waitFor: 'horário',
        notWaitFor: ['nome', 'email', 'cpf'],
        description: 'CRÍTICO: Deve verificar disponibilidade SEM re-pedir triagedata',
      },
    ],
  },

  {
    name: 'TESTE 2: Cliente Retornando - Sem Reunião Aberta',
    phone: '5585988882101',
    messages: [
      {
        text: 'Oi, quero marcar outra reunião',
        waitFor: ['tipo de caso', 'novo'],
        notWaitFor: ['nome', 'email', 'cpf'],
        description: 'CRÍTICO: Não deve re-pedir triagedata para cliente retornando',
      },
    ],
  },
];

// Executar testes
async function runTests() {
  console.log('\n🧪 INICIANDO TESTES DE CONVERSA\n');
  console.log('═'.repeat(70));

  for (const test of tests) {
    console.log(`\n✅ ${test.name}`);
    console.log('─'.repeat(70));

    for (let i = 0; i < test.messages.length; i++) {
      const msg = test.messages[i];
      console.log(`\n   [${i + 1}/${test.messages.length}] ${msg.description}`);
      console.log(`   📱 User: "${msg.text}"`);

      try {
        // Enviar mensagem
        const response = await makeRequest('POST', WEBHOOK_URL, {
          messages: [
            {
              from: test.phone,
              body: msg.text,
              timestamp: new Date().toISOString(),
            },
          ],
        });

        console.log(`   ✅ Mensagem enviada (status: ${response.status})`);

        // Aguardar processamento
        await new Promise(r => setTimeout(r, 2000));

        // Validar resposta
        const validation = msg.waitFor
          ? Array.isArray(msg.waitFor)
            ? msg.waitFor.some(w => response.data?.toString?.().toLowerCase().includes(w.toLowerCase()))
            : response.data?.toString?.().toLowerCase().includes(msg.waitFor.toLowerCase())
          : true;

        if (validation) {
          console.log(`   ✅ Validação passou`);
        } else {
          console.log(`   ❌ Validação FALHOU`);
          console.log(`      Esperava: ${msg.waitFor}`);
        }

        if (msg.notWaitFor) {
          const notWaitForList = Array.isArray(msg.notWaitFor) ? msg.notWaitFor : [msg.notWaitFor];
          const hasWrongText = notWaitForList.some(w =>
            response.data?.toString?.().toLowerCase().includes(w.toLowerCase())
          );
          if (hasWrongText) {
            console.log(`   ⚠️  ALERTA: Contém texto que NÃO deveria: ${notWaitForList.join(', ')}`);
          } else {
            console.log(`   ✅ NÃO contém textos indesejados`);
          }
        }
      } catch (err) {
        console.log(`   ❌ Erro: ${err.message}`);
      }

      // Aguardar entre mensagens
      await new Promise(r => setTimeout(r, 1000));
    }
  }

  console.log('\n' + '═'.repeat(70));
  console.log('✅ Testes finalizados\n');
}

// Executar
runTests().catch(err => {
  console.error('❌ Erro:', err);
  process.exit(1);
});
