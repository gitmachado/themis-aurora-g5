import { StateGraph, START, END } from "@langchain/langgraph";
import { AIMessage } from "@langchain/core/messages";
import { OmniState, OmniStateType } from "./state.js";
import { checkpointer } from "../config/checkpointer.js";
import { routerNode } from "./nodes/router.js";
import { triageNode } from "./nodes/triage.js";
import { statusNode } from "./nodes/status.js";
import { ragNode } from "./nodes/rag.js";
import { handoffNode } from "./nodes/handoff.js";
import { syncMessage } from "./nodes/sync.js";

// Wrapper do syncMessage (utilitário) para interface de nó LangGraph
async function syncNode(state: OmniStateType): Promise<Partial<OmniStateType>> {
  const lastMsg = state.messages.at(-1);
  if (lastMsg) {
    await syncMessage({
      whatsappNumber: state.whatsappNumber,
      content: String(lastMsg.content),
      sender: lastMsg instanceof AIMessage ? "BOT" : "CLIENT",
      whatsappMessageId: null,
    });
  }
  return {};
}

// Função de roteamento: lê o próximo nó a partir do state
const routeByCurrentNode = (state: OmniStateType): string => state.currentNode;

// Encadeamento para inferência correta dos tipos de nó no TypeScript
const graphBuilder = new StateGraph(OmniState)
  .addNode("router", routerNode)
  .addNode("triage", triageNode)
  .addNode("status", statusNode)
  .addNode("rag", ragNode)
  .addNode("handoff", handoffNode)
  .addNode("sync", syncNode)
  // Entrada
  .addEdge(START, "router")
  // Arestas condicionais
  .addConditionalEdges("router", routeByCurrentNode, {
    triage: "triage",
    status: "status",
    rag: "rag",
    handoff: "handoff",
    sync: "sync",
  })
  .addConditionalEdges("triage", routeByCurrentNode, {
    triage: "triage",
    sync: "sync",
  })
  .addConditionalEdges("status", routeByCurrentNode, {
    status: "status",
    sync: "sync",
  })
  .addConditionalEdges("rag", routeByCurrentNode, {
    handoff: "handoff",
    sync: "sync",
  })
  // Arestas fixas
  .addEdge("handoff", "sync")
  .addEdge("sync", END);

// Compila com checkpointer PostgreSQL (persistência de estado por thread)
export const graph = graphBuilder.compile({ checkpointer });
