import { ChatGoogleGenerativeAI } from "@langchain/google-genai";
import { AIMessage } from "@langchain/core/messages";
import { z } from "zod";
import axios from "axios";
import { OmniStateType } from "../state.js";
import { SYSTEM_PROMPT, ROUTER_PROMPT } from "../../config/prompts.js";
import { isWithinServiceHours } from "../../utils/service-hours.js";

const BACKEND_API_URL = process.env.BACKEND_API_URL || "http://localhost:3000";
const BOT_API_KEY = process.env.BOT_API_KEY || "";

const routerSchema = z.object({
  intent: z.enum([
    "TRIAGE",
    "STATUS_QUERY",
    "LEGAL_QUESTION",
    "HANDOFF_REQUEST",
    "GREETING",
  ]),
  confidence: z.number(),
});

async function checkUserExists(whatsappNumber: string): Promise<{
  userType: "UNKNOWN" | "LEAD" | "CLIENT";
  userId: string | null;
  leadId: string | null;
}> {
  try {
    const res = await axios.get(
      `${BACKEND_API_URL}/api/v1/users/by-phone/${whatsappNumber}`,
      { headers: { "x-api-key": BOT_API_KEY } }
    );
    return { userType: "CLIENT", userId: res.data.id, leadId: null };
  } catch {
    // Verifica se há lead pendente
    try {
      const res = await axios.get(
        `${BACKEND_API_URL}/api/v1/leads/by-phone/${whatsappNumber}`,
        { headers: { "x-api-key": BOT_API_KEY } }
      );
      if (res.data?.status === "PENDING") {
        return { userType: "LEAD", userId: null, leadId: res.data.id };
      }
    } catch { /* ignora */ }
    return { userType: "UNKNOWN", userId: null, leadId: null };
  }
}

function resolveNextNode(
  userType: "UNKNOWN" | "LEAD" | "CLIENT",
  intent: string
): string {
  if (intent === "HANDOFF_REQUEST") return "handoff_node";
  if (userType === "UNKNOWN" || userType === "LEAD") return "triage_node";
  if (intent === "STATUS_QUERY") return "status_node";
  if (intent === "LEGAL_QUESTION") return "rag_node";
  return "triage_node";
}

export async function routerNode(
  state: OmniStateType
): Promise<Partial<OmniStateType>> {
  const { whatsappNumber, messages, config } = state;

  // 1. Verifica horário de atendimento
  if (!isWithinServiceHours(new Date(), config.serviceHoursStart, config.serviceHoursEnd)) {
    return {
      currentNode: "sync_node",
      messages: [new AIMessage(config.awayMessage)],
    };
  }

  // 2. Identifica tipo de usuário no backend
  const userInfo = await checkUserExists(whatsappNumber);

  // 3. Classifica intenção via LLM com saída estruturada
  const model = new ChatGoogleGenerativeAI({
    modelName: process.env.GOOGLE_MODEL || "gemini-1.5-flash",
    apiKey: process.env.GOOGLE_API_KEY,
    temperature: 0,
  });
  const structured = model.withStructuredOutput(routerSchema);

  const lastMessage = messages.at(-1);
  const classification = await structured.invoke([
    { role: "system", content: `${SYSTEM_PROMPT}\n\n${ROUTER_PROMPT}` },
    { role: "user", content: String(lastMessage?.content ?? "") },
  ]);

  const nextNode = resolveNextNode(userInfo.userType, classification.intent);

  return {
    userType: userInfo.userType,
    userId: userInfo.userId,
    leadId: userInfo.leadId,
    currentNode: nextNode,
  };
}
