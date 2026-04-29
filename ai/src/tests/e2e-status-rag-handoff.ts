// Script de teste E2E — Status + RAG + Handoff (T26)
// Uso: npm run test:e2e-rag
// Requer: banco PostgreSQL + backend rodando + PDFs indexados (T15)
import "dotenv/config";
import { HumanMessage, AIMessage } from "@langchain/core/messages";
import { graph } from "../graph/index.js";
import { INITIAL_TRIAGE, INITIAL_CONFIG } from "../graph/state.js";
import { setupCheckpointer } from "../config/checkpointer.js";
import { validateMessageType } from "../utils/message-validator.js";

async function sendMessage(threadId: string, content: string, isFirst: boolean = false, type: string = "TEXT") {
  // Validação de tipo de mensagem (Barreira de entrada)
  const validation = validateMessageType(type);
  if (!validation.isValid) {
    console.log(`  [USER] (${type}) ${content}`);
    console.log(`  [BOT]  ${validation.errorMessage}`);
    // Mock do retorno do grafo para manter compatibilidade de interface nos testes
    return {
      whatsappNumber: threadId,
      userType: "UNKNOWN",
      userId: null,
      leadId: null,
      messages: [new AIMessage(validation.errorMessage!)],
      triage: INITIAL_TRIAGE,
      currentNode: "barrier",
      needsHandoff: false,
      handoffReason: null,
      config: INITIAL_CONFIG
    };
  }

  const input: any = {
    messages: [new HumanMessage(content)],
  };

  if (isFirst) {
    input.whatsappNumber = threadId;
    input.userType = "UNKNOWN";
    input.triage = INITIAL_TRIAGE;
    input.config = INITIAL_CONFIG;
  }

  const result = await graph.invoke(
    input,
    { configurable: { thread_id: threadId } }
  );
  const last = result.messages.at(-1);
  console.log(`  [USER] ${content}`);
  console.log(`  [BOT]  ${String(last?.content ?? "(sem resposta)").slice(0, 200)}`);
  console.log(`  [STATE] node=${result.currentNode} handoff=${result.needsHandoff}`);
  return result;
}

async function runStatusQuery() {
  console.log("\n========== CENÁRIO 1: Consulta de Status ==========");
  const threadId = `test-status-${Date.now()}`;
  const result = await sendMessage(threadId, "Qual o status do meu processo?", true);
  // Com usuário sem processos cadastrados, espera-se mensagem de ausência ou triagem
  console.log(`  ${result.needsHandoff ? "⚠️ handoff" : "✅"} status ou triagem respondidos`);
}

async function runRAGQuery() {
  console.log("\n========== CENÁRIO 2: Pergunta Jurídica (RAG) ==========");
  const threadId = `test-rag-${Date.now()}`;
  const result = await sendMessage(threadId, "Quais documentos preciso para um divórcio?", true);
  if (!result.needsHandoff) {
    console.log("  ✅ RAG respondeu sem acionar handoff");
  } else {
    console.log("  ⚠️ RAG não encontrou contexto — handoff acionado (indexar PDFs com T15)");
  }
}

async function runHandoffKeyword() {
  console.log("\n========== CENÁRIO 3: Handoff por Palavra-chave ==========");
  const threadId = `test-handoff-kw-${Date.now()}`;
  const result = await sendMessage(threadId, "Quero falar com um advogado", true);
  if (result.needsHandoff) {
    console.log(`  ✅ Handoff ativado | razão: ${result.handoffReason ?? "N/A"}`);
  } else {
    console.log("  ❌ ERRO: handoff não foi acionado para keyword 'advogado'");
  }
}

async function runHandoffRAGFailure() {
  console.log("\n========== CENÁRIO 4: Handoff por RAG Failure (fora do domínio) ==========");
  const threadId = `test-ragfail-${Date.now()}`;
  const result = await sendMessage(threadId, "Quanto custa um Ferrari?", true);
  if (result.needsHandoff) {
    console.log("  ✅ Handoff acionado para pergunta fora do domínio jurídico");
  } else {
    console.log("  ⚠️ Bot respondeu sem handoff — verificar prompt defensivo do RAG");
  }
}

async function runNonTextMessage() {
  console.log("\n========== CENÁRIO 5: Mensagem Não-Texto (Áudio) ==========");
  const threadId = `test-audio-${Date.now()}`;
  const result = await sendMessage(threadId, "[Áudio de 10s]", true, "audio");
  const last = result.messages.at(-1);
  
  if (String(last?.content).includes("processar mensagens de texto")) {
    console.log("  ✅ Barreira bloqueou áudio corretamente");
  } else {
    console.log("  ❌ ERRO: Barreira não bloqueou áudio");
  }
}

(async () => {
  console.log("🚀 Iniciando testes E2E — Status + RAG + Handoff (T26)");
  await setupCheckpointer();
  await runStatusQuery();
  await runRAGQuery();
  await runHandoffKeyword();
  await runHandoffRAGFailure();
  await runNonTextMessage();
  console.log("\n✅ T26 — Todos os cenários executados");
  process.exit(0);
})().catch((err) => {
  console.error("❌ Erro nos testes:", err);
  process.exit(1);
});
