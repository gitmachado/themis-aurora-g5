// Script de teste E2E — Status + RAG + Handoff (T26)
// Uso: npm run test:e2e-rag
// Requer: banco PostgreSQL + backend rodando + PDFs indexados (T15)
import "dotenv/config";
import { HumanMessage } from "@langchain/core/messages";
import { graph } from "../graph/index.js";
import { INITIAL_TRIAGE, INITIAL_CONFIG } from "../graph/state.js";
import { setupCheckpointer } from "../config/checkpointer.js";

async function sendMessage(threadId: string, content: string) {
  const result = await graph.invoke(
    {
      whatsappNumber: threadId,
      userType: "UNKNOWN" as const,
      userId: null,
      leadId: null,
      messages: [new HumanMessage(content)],
      triage: INITIAL_TRIAGE,
      currentNode: "router",
      needsHandoff: false,
      handoffReason: null,
      config: INITIAL_CONFIG,
    },
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
  const result = await sendMessage(threadId, "Qual o status do meu processo?");
  // Com usuário sem processos cadastrados, espera-se mensagem de ausência ou triagem
  console.log(`  ${result.needsHandoff ? "⚠️ handoff" : "✅"} status ou triagem respondidos`);
}

async function runRAGQuery() {
  console.log("\n========== CENÁRIO 2: Pergunta Jurídica (RAG) ==========");
  const threadId = `test-rag-${Date.now()}`;
  const result = await sendMessage(threadId, "Quais documentos preciso para um divórcio?");
  if (!result.needsHandoff) {
    console.log("  ✅ RAG respondeu sem acionar handoff");
  } else {
    console.log("  ⚠️ RAG não encontrou contexto — handoff acionado (indexar PDFs com T15)");
  }
}

async function runHandoffKeyword() {
  console.log("\n========== CENÁRIO 3: Handoff por Palavra-chave ==========");
  const threadId = `test-handoff-kw-${Date.now()}`;
  const result = await sendMessage(threadId, "Quero falar com um advogado");
  if (result.needsHandoff) {
    console.log(`  ✅ Handoff ativado | razão: ${result.handoffReason ?? "N/A"}`);
  } else {
    console.log("  ❌ ERRO: handoff não foi acionado para keyword 'advogado'");
  }
}

async function runHandoffRAGFailure() {
  console.log("\n========== CENÁRIO 4: Handoff por RAG Failure (fora do domínio) ==========");
  const threadId = `test-ragfail-${Date.now()}`;
  const result = await sendMessage(threadId, "Quanto custa um Ferrari?");
  if (result.needsHandoff) {
    console.log("  ✅ Handoff acionado para pergunta fora do domínio jurídico");
  } else {
    console.log("  ⚠️ Bot respondeu sem handoff — verificar prompt defensivo do RAG");
  }
}

(async () => {
  console.log("🚀 Iniciando testes E2E — Status + RAG + Handoff (T26)");
  await setupCheckpointer();
  await runStatusQuery();
  await runRAGQuery();
  await runHandoffKeyword();
  await runHandoffRAGFailure();
  console.log("\n✅ T26 — Todos os cenários executados");
  process.exit(0);
})().catch((err) => {
  console.error("❌ Erro nos testes:", err);
  process.exit(1);
});
