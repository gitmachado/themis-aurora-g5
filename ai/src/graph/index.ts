import { StateGraph, START, END } from "@langchain/langgraph";
import { AIMessage } from "@langchain/core/messages";
import { OmniState, OmniStateType } from "./state.js";
import { checkpointer } from "../config/checkpointer.js";
import { routerNode } from "./nodes/router.js";
import { triageNode } from "./nodes/triage.js";
import { statusNode } from "./nodes/status.js";
import { ragNode } from "./nodes/rag.js";
import { handoffNode } from "./nodes/handoff.js";
import { greetingNode } from "./nodes/greeting.js";
import { syncMessage } from "./nodes/sync.js";

// Wrapper do syncMessage (utilitário) para interface de nó LangGraph
async function syncNode(state: OmniStateType): Promise<Partial<OmniStateType>> {
  const lastMsg = state.messages.at(-1);
  // Sincroniza apenas se for uma mensagem da IA (BOT). 
  // Mensagens do CLIENTE agora são sincronizadas pelo Webhook para garantir tempo real.
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

// Função de roteamento: lê o próximo nó a partir do state
const routeByCurrentNode = (state: OmniStateType): string => state.currentNode;

// Encadeamento para inferência correta dos tipos de nó no TypeScript
const graphBuilder = new StateGraph(OmniState)
  .addNode("router_node", routerNode)
  .addNode("triage_node", triageNode)
  .addNode("status_node", statusNode)
  .addNode("rag_node", ragNode)
  .addNode("handoff_node", handoffNode)
  .addNode("greeting_node", greetingNode)
  .addNode("sync_node", syncNode)
  // Entrada
  .addEdge(START, "router_node")
  // Arestas condicionais
  .addConditionalEdges("router_node", routeByCurrentNode, {
    triage_node: "triage_node",
    status_node: "status_node",
    rag_node: "rag_node",
    handoff_node: "handoff_node",
    greeting_node: "greeting_node",
    sync_node: "sync_node",
  })
  .addConditionalEdges("triage_node", routeByCurrentNode, {
    triage_node: "triage_node",
    sync_node: "sync_node",
  })
  .addConditionalEdges("status_node", routeByCurrentNode, {
    status_node: "status_node",
    sync_node: "sync_node",
  })
  .addConditionalEdges("rag_node", routeByCurrentNode, {
    handoff_node: "handoff_node",
    sync_node: "sync_node",
  })
  // Arestas fixas
  .addEdge("greeting_node", "sync_node")
  .addEdge("handoff_node", "sync_node")
  .addEdge("sync_node", END);

// Compila com checkpointer PostgreSQL (persistência de estado por thread)
export const graph = graphBuilder.compile({ checkpointer });
