import { tool } from "@langchain/core/tools";
import axios from "axios";
import { z } from "zod";

const BACKEND_API_URL = process.env.BACKEND_API_URL || "http://localhost:3000";
const BOT_API_KEY = process.env.BOT_API_KEY || "";

const headers = () => ({ "x-api-key": BOT_API_KEY });

// 1. check_user_exists — verifica se o número pertence a um cliente cadastrado
export const checkUserExists = tool(
  async ({ whatsappNumber }: { whatsappNumber: string }) => {
    try {
      const res = await axios.get(
        `${BACKEND_API_URL}/api/v1/bot/users/by-phone/${whatsappNumber}`,
        { headers: headers() }
      );
      return res.data;
    } catch (err) {
      console.error("[check_user_exists] Erro:", err);
      return { exists: false };
    }
  },
  {
    name: "check_user_exists",
    description: "Verifica se um número WhatsApp pertence a um cliente cadastrado no sistema",
    schema: z.object({
      whatsappNumber: z.string().describe("Número WhatsApp do usuário (ex: 5511999999999)"),
    }),
  }
);

// 2. get_client_processes — lista processos jurídicos de um cliente
export const getClientProcesses = tool(
  async ({ whatsappNumber }: { whatsappNumber: string }) => {
    try {
      const res = await axios.get(
        `${BACKEND_API_URL}/api/v1/bot/processes/by-phone/${whatsappNumber}`,
        { headers: headers() }
      );
      return res.data;
    } catch (err) {
      console.error("[get_client_processes] Erro:", err);
      return { processes: [] };
    }
  },
  {
    name: "get_client_processes",
    description: "Lista os processos jurídicos de um cliente identificado pelo número WhatsApp",
    schema: z.object({
      whatsappNumber: z.string().describe("Número WhatsApp do cliente"),
    }),
  }
);

// 3. create_lead — cria novo lead após triagem completa
export const createLead = tool(
  async (input: {
    name: string;
    whatsappNumber: string;
    cpf: string;
    caseType: string;
    caseDescription: string;
    urgency: string;
    contactAvailability: string;
  }) => {
    try {
      const res = await axios.post(
        `${BACKEND_API_URL}/api/v1/leads`,
        input,
        { headers: headers() }
      );
      return res.data;
    } catch (err) {
      console.error("[create_lead] Erro:", err);
      throw new Error("Falha ao criar lead no backend");
    }
  },
  {
    name: "create_lead",
    description: "Cria um novo lead no backend após coleta completa dos dados da triagem",
    schema: z.object({
      name: z.string().min(3).describe("Nome completo do cliente"),
      whatsappNumber: z.string().min(10).describe("Número WhatsApp do cliente"),
      cpf: z.string().length(11).describe("CPF somente números, 11 dígitos"),
      caseType: z
        .enum(["Labor", "Civil", "Family", "Criminal", "SocialSecurity"])
        .describe("Tipo do caso em inglês"),
      caseDescription: z.string().describe("Descrição do caso jurídico"),
      urgency: z.enum(["High", "Medium", "Low"]).describe("Urgência do caso"),
      contactAvailability: z
        .enum(["Morning", "Afternoon", "Evening"])
        .describe("Melhor horário para contato"),
    }),
  }
);

// 4. sync_message — persiste mensagem da conversa no backend
export const syncMessage = tool(
  async (input: {
    whatsappNumber: string;
    content: string;
    senderRole: string;
    messageType: string;
  }) => {
    try {
      const res = await axios.post(
        `${BACKEND_API_URL}/api/v1/messages/sync`,
        input,
        { headers: headers() }
      );
      return res.data;
    } catch (err) {
      console.error("[sync_message] Erro:", err);
      return null;
    }
  },
  {
    name: "sync_message",
    description: "Persiste uma mensagem da conversa WhatsApp no backend para espelhamento no app",
    schema: z.object({
      whatsappNumber: z.string().min(10).describe("Número WhatsApp da conversa"),
      content: z.string().describe("Conteúdo da mensagem"),
      senderRole: z
        .enum(["CLIENT", "LAWYER", "BOT"])
        .describe("Quem enviou a mensagem"),
      messageType: z
        .enum(["TEXT", "IMAGE", "DOCUMENT"])
        .default("TEXT")
        .describe("Tipo da mensagem"),
    }),
  }
);

// 5. notify_lawyer — envia notificação push ao advogado
export const notifyLawyer = tool(
  async (input: { type: string; message: string; whatsappNumber: string }) => {
    try {
      const res = await axios.post(
        `${BACKEND_API_URL}/api/v1/bot/notifications`,
        input,
        { headers: headers() }
      );
      return res.data;
    } catch (err) {
      console.error("[notify_lawyer] Erro:", err);
      return null;
    }
  },
  {
    name: "notify_lawyer",
    description: "Envia notificação push ao advogado (handoff, novo lead, etc.)",
    schema: z.object({
      type: z.string().describe("Tipo da notificação (ex: HANDOFF, NEW_LEAD)"),
      message: z.string().describe("Corpo da notificação enviada ao advogado"),
      whatsappNumber: z.string().describe("Número WhatsApp do cliente relacionado"),
    }),
  }
);

// Export agrupado para binding no grafo (T17)
export const apiTools = [
  checkUserExists,
  getClientProcesses,
  createLead,
  syncMessage,
  notifyLawyer,
];
