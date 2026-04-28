// Script de teste E2E — Fluxo de Lead Novo (T25)
// Uso: npm run test:e2e-lead
// Requer: banco PostgreSQL + backend rodando
import "dotenv/config";
import { HumanMessage } from "@langchain/core/messages";
import { graph } from "../graph/index.js";
import { INITIAL_TRIAGE, INITIAL_CONFIG } from "../graph/state.js";
import { setupCheckpointer } from "../config/checkpointer.js";

const BASE_THREAD = `test-lead-${Date.now()}`;

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
  console.log(`  [USER] ${content || "(vazia)"}`);
  console.log(`  [BOT]  ${String(last?.content ?? "(sem resposta)").slice(0, 200)}`);
  console.log(`  [STATE] step=${result.triage?.currentStep ?? "?"} leadId=${result.leadId ?? "null"}`);
  return result;
}

async function runHappyPath() {
  console.log("\n========== CENÁRIO 1: Happy Path ==========");
  const thread = `${BASE_THREAD}-happy`;
  await sendMessage(thread, "Olá, preciso de ajuda");
  await sendMessage(thread, "Maria da Silva Oliveira");
  await sendMessage(thread, "529.982.247-25");
  await sendMessage(thread, "Trabalhista");
  await sendMessage(thread, "Fui demitida sem justa causa há 3 meses e não recebi verbas rescisórias.");
  await sendMessage(thread, "Alta");
  const final = await sendMessage(thread, "Tarde");
  if (final.leadId) {
    console.log(`  ✅ Lead criado com ID: ${final.leadId}`);
  } else {
    console.log("  ❌ ERRO: leadId não foi criado");
  }
}

async function runInvalidCPF() {
  console.log("\n========== CENÁRIO 2: CPF Inválido ==========");
  const thread = `${BASE_THREAD}-cpf`;
  await sendMessage(thread, "Carlos Teste");
  const r1 = await sendMessage(thread, "000.000.000-00");
  const r2 = await sendMessage(thread, "111.111.111-11");
  await sendMessage(thread, "529.982.247-25");
  if (r1.triage?.currentStep === "CPF" && r2.triage?.currentStep === "CPF") {
    console.log("  ✅ Bot pediu CPF novamente após inválido");
  } else {
    console.log("  ❌ ERRO: bot avançou com CPF inválido");
  }
}

async function runInvalidEnum() {
  console.log("\n========== CENÁRIO 3: Enum Inválido ==========");
  const thread = `${BASE_THREAD}-enum`;
  await sendMessage(thread, "João Teste");
  await sendMessage(thread, "529.982.247-25");
  const r1 = await sendMessage(thread, "XYZ tipo qualquer");
  await sendMessage(thread, "Cível");
  if (r1.triage?.currentStep === "CASE_TYPE") {
    console.log("  ✅ Bot manteve step CASE_TYPE após enum inválido");
  } else {
    console.log("  ❌ ERRO: bot avançou com enum inválido");
  }
}

async function runEmptyMessage() {
  console.log("\n========== CENÁRIO 4: Mensagem Vazia ==========");
  const thread = `${BASE_THREAD}-empty`;
  await sendMessage(thread, "Pedro Teste");
  await sendMessage(thread, "");
  const r = await sendMessage(thread, "529.982.247-25");
  if (r.triage?.currentStep !== undefined) {
    console.log("  ✅ Bot não crashou com mensagem vazia");
  }
}

(async () => {
  console.log("🚀 Iniciando testes E2E — Fluxo de Lead Novo (T25)");
  await setupCheckpointer();
  await runHappyPath();
  await runInvalidCPF();
  await runInvalidEnum();
  await runEmptyMessage();
  console.log("\n✅ T25 — Todos os cenários executados");
  process.exit(0);
})().catch((err) => {
  console.error("❌ Erro nos testes:", err);
  process.exit(1);
});
