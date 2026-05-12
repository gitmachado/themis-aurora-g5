import { StateGraph, START, END, Annotation } from "@langchain/langgraph";
import { BaseMessage } from "@langchain/core/messages";
import { ChatOpenAI } from "@langchain/openai";
import { ToolNode } from "@langchain/langgraph/prebuilt";
import { checkpointer } from "../config/checkpointer.js";
import { lawyerTools } from "../tools/lawyer-tools.js";
import { knowledgeSearchTool } from "../tools/knowledge.js";

/**
 * State próprio para o chat do Advogado.
 */
export const LawyerChatState = Annotation.Root({
  // Histórico de mensagens com o mesmo reducer inteligente de append e dedup do ThemisState
  messages: Annotation<BaseMessage[]>({
    reducer: (a, b) => {
      if (b.length === 1 && a.length > 0) {
        const lastA = a[a.length - 1];
        const newB = b[0];
        if (lastA.content === newB.content && (lastA as any)._getType?.() === (newB as any)._getType?.()) {
          return a;
        }
      }
      return a.concat(b);
    },
    default: () => [],
  }),
  // ID do advogado associado a esta sessão
  lawyerId: Annotation<string>,
});

/**
 * Nó do agente do advogado.
 */
async function lawyerAgentNode(state: typeof LawyerChatState.State) {
  const tools = [...lawyerTools, knowledgeSearchTool];
  
  const model = new ChatOpenAI({
    model: process.env.OPENAI_MODEL || "gpt-4o-mini",
    temperature: 0.1,
  }).bindTools(tools);

  const systemPrompt = `Você é um assistente jurídico operacional. Auxilia advogados a consultar o status dos processos do escritório e a base de conhecimento interna. Seja direto, preciso e profissional.\nID do advogado atual: ${state.lawyerId}`;

  const response = await model.invoke([
    { role: "system", content: systemPrompt },
    ...state.messages,
  ]);

  return {
    messages: [response],
  };
}

// Configuração do nó de ferramentas padrão do LangGraph
const tools = [...lawyerTools, knowledgeSearchTool];
const toolNode = new ToolNode(tools);

/**
 * Função de roteamento condicional para determinar se o fluxo continua para as ferramentas ou se encerra.
 */
function shouldContinue(state: typeof LawyerChatState.State) {
  const lastMessage = state.messages.at(-1);
  if (lastMessage && (lastMessage as any).tool_calls?.length > 0) {
    return "tools_node";
  }
  return END;
}

// Construção do Grafo de Estado para o Chat de Advogado
const graphBuilder = new StateGraph(LawyerChatState)
  .addNode("lawyer_agent_node", lawyerAgentNode)
  .addNode("tools_node", toolNode)
  .addEdge(START, "lawyer_agent_node")
  .addConditionalEdges("lawyer_agent_node", shouldContinue, {
    tools_node: "tools_node",
    [END]: END,
  })
  .addEdge("tools_node", "lawyer_agent_node");

// Compilação do grafo de advogado com persistência via PostgresSaver
export const lawyerGraph = graphBuilder.compile({ checkpointer });
