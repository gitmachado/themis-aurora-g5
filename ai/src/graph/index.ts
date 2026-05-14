import { StateGraph, START, END } from "@langchain/langgraph";
import { AIMessage } from "@langchain/core/messages";
import { ThemisState, ThemisStateType } from "./state.js";
import { checkpointer } from "../config/checkpointer.js";
import { routerNode } from "./nodes/router.js";
import { syncMessage } from "./nodes/sync.js";

/**
 * Wrapper do syncMessage (utilitário) para interface de nó LangGraph.
 * Sincroniza apenas mensagens da IA (BOT) — mensagens do cliente
 * são sincronizadas diretamente no webhook para garantir tempo real.
 */
async function syncNode(state: ThemisStateType): Promise<Partial<ThemisStateType>> {
  const lastMsg = state.messages.at(-1);
  if (lastMsg && lastMsg instanceof AIMessage) {
    await syncMessage({
      whatsappNumber: state.whatsappNumber,
      content: String(lastMsg.content),
      senderRole: "BOT",
      messageType: "TEXT",
      whatsappMessageId: null,
    });
  }
  return {};
}

/**
 * Grafo LangGraph — Arquitetura Agent Unificado.
 * 
 * Fluxo: START → router_node → sync_node → END
 * 
 * O Router é o agente central que:
 * - Responde cumprimentos e dúvidas
 * - Coleta dados de triagem conversacionalmente
 * - Usa Tools para registrar leads, consultar processos e acionar handoff
 * - Busca conhecimento via RAG automaticamente
 */
const graphBuilder = new StateGraph(ThemisState)
  .addNode("router_node", routerNode)
  .addNode("sync_node", syncNode)
  .addEdge(START, "router_node")
  .addEdge("router_node", "sync_node")
  .addEdge("sync_node", END);

// Compila com checkpointer PostgreSQL (persistência de estado por thread)
export const graph = graphBuilder.compile({ checkpointer });
