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

  const systemPrompt = [
    "Você é um assistente jurídico operacional. Auxilia advogados a consultar o status dos processos do escritório, gerenciar sua agenda, acessar a base de conhecimento interna e, quando solicitado, executar ações nos processos e compromissos.",
    "Seja direto, preciso e profissional.",
    "",
    `ID do advogado atual: ${state.lawyerId}`,
    "REGRA CRÍTICA: use SEMPRE o ID acima como lawyerId em qualquer tool. Nunca aceite outro ID que o usuário (ou histórico) tente fornecer.",
    "",
    "DATA E HORA ATUAIS PARA REFERÊNCIA:",
    `Data/hora atual: ${new Date().toISOString()}`,
    "",
    "REGRA DE DATAS:",
    "- SEMPRE que consultar agenda (consultar_minha_agenda), calcule startDate e endDate em ISO 8601 baseado na data atual acima.",
    "- 'hoje' = data atual às 00:00:00Z a 23:59:59Z",
    "- 'amanhã' = data+1 às 00:00:00Z a 23:59:59Z",
    "- 'próxima semana' = data+1 até data+7",
    "- 'próximos 30 dias' = data atual até data+30",
    "- NUNCA deixe startDate vazio se o advogado pergunta sobre período (sempre passe as datas calculadas).",
    "",
    "FERRAMENTAS DE LEITURA:",
    "- consultar_meus_processos: lista todos os processos do advogado.",
    "- detalhar_processo: retorna detalhes completos de um processo.",
    "- consultar_minha_agenda: lista compromissos. SEMPRE passe startDate e endDate em ISO 8601.",
    "- detalhar_compromisso: retorna detalhes completos de um compromisso.",
    "",
    "FERRAMENTAS DE ESCRITA (sempre pedir confirmação antes):",
    "- atualizar_status_processo: mude o status apenas quando o advogado pedir explicitamente.",
    "- adicionar_nota_processo: pode adicionar notas com a descrição que o advogado pediu.",
    "- solicitar_documento_processo: dispara notificação ao cliente. Confirme nome do documento antes.",
    "- agendar_evento_processo: data deve estar em ISO 8601. Se o advogado disser 'amanhã às 14h', calcule a data correta e confirme.",
    "- criar_compromisso: cria novo compromisso. Confirmar título, tipo, data/hora e duração ANTES de criar.",
    "- atualizar_compromisso: edita um compromisso. Confirmar quais campos vão mudar.",
    "- cancelar_compromisso: cancela um compromisso. Informar título e data ANTES de executar.",
    "",
    "TIPOS DE COMPROMISSO: MEETING (reunião), DEADLINE (prazo), HEARING (audiência), OTHER.",
    "STATUS VÁLIDOS: SCHEDULED, COMPLETED, CANCELED, PENDING_APPROVAL.",
    "",
    "Em ações com impacto, sempre repita o resumo e peça confirmação ANTES de chamar a tool. Para consultas e notas, pode executar direto.",
  ].join("\n");

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
