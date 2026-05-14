import "dotenv/config";
import { HumanMessage } from "@langchain/core/messages";
import { getBotConfig } from "./tools/config-loader.js";
import { setupCheckpointer } from "./config/checkpointer.js";
import { INITIAL_TRIAGE, INITIAL_CONFIG } from "./graph/state.js";

const message = process.argv[2];
const whatsappNumber = process.argv[3] || "5511999999999";

if (!message) {
  console.error('Uso: npm run test:graph "sua mensagem" [numero]');
  console.error('Exemplo: npm run test:graph "Olá, preciso de ajuda"');
  process.exit(1);
}

async function main() {
  const { graph } = await import("./graph/index.js");
  await setupCheckpointer();

  const config = await getBotConfig().catch(() => INITIAL_CONFIG);

  const initialState = {
    whatsappNumber,
    userType: "UNKNOWN" as const,
    userId: null,
    leadId: null,
    messages: [new HumanMessage(message)],
    triage: INITIAL_TRIAGE,
    currentNode: "router_node",
    needsHandoff: false,
    handoffReason: null,
    config,
  };

  console.log(`\n[test-graph] Thread: ${whatsappNumber}`);
  console.log(`[test-graph] Mensagem: "${message}"\n`);

  const result = await graph.invoke(initialState, {
    configurable: { thread_id: whatsappNumber },
  });

  const lastMessage = result.messages.at(-1);
  console.log(`[BOT]: ${lastMessage?.content ?? "(sem resposta)"}`);
}

main().catch((err) => {
  console.error("[test-graph] Erro:", err.message);
  process.exit(1);
});
