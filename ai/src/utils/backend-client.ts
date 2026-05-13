import axios, { AxiosInstance } from "axios";

const BACKEND_API_URL = process.env.BACKEND_API_URL || "http://localhost:3000";
const BOT_API_KEY = process.env.BOT_API_KEY || "";

/**
 * Cliente HTTP centralizado para comunicação AI → Backend.
 * Todas as chamadas ao backend passam por aqui com API Key.
 */
const client: AxiosInstance = axios.create({
  baseURL: `${BACKEND_API_URL}/api/v1`,
  headers: { "x-api-key": BOT_API_KEY },
  timeout: 10000,
});

/**
 * Re-lança erros do backend como Error com .status e a melhor mensagem
 * disponível. O backend responde indistintamente com { error } (rotas REST
 * novas) ou { message } (algumas rotas antigas), por isso checamos ambos.
 */
function throwHttp(error: any): never {
  const status = error.response?.status || 500;
  const message =
    error.response?.data?.error ||
    error.response?.data?.message ||
    error.message ||
    "Erro desconhecido";
  const err = new Error(message) as any;
  err.status = status;
  throw err;
}

// ── Usuários ──

export async function checkUserByCpf(cpf: string): Promise<{
  exists: boolean;
  userId?: string;
  name?: string;
}> {
  const res = await client.get(`/bot/users/by-cpf/${cpf}`);
  return res.data;
}

export async function getUserByPhone(whatsappNumber: string): Promise<{
  exists: boolean;
  userId?: string;
  name?: string;
}> {
  const res = await client.get(`/bot/users/by-phone/${whatsappNumber}`);
  return res.data;
}

// ── Leads ──

export async function getLeadByPhone(whatsappNumber: string): Promise<{
  exists: boolean;
  id?: string;
  status?: string;
  name?: string;
  isAIPaused?: boolean;
}> {
  const res = await client.get(`/bot/leads/by-phone/${whatsappNumber}`);
  return res.data;
}

export async function createLead(data: {
  name: string;
  email: string;
  whatsappNumber: string;
  cpf: string;
  caseType: string;
  caseDescription: string;
  urgency: string;
  contactAvailability: string;
}): Promise<{ id: string }> {
  const res = await client.post("/leads", data);
  return res.data;
}

// ── Processos ──

export interface ProcessData {
  title: string;
  processNumber: string | null;
  currentStatus: string;
  lastMovementDate: string | null;
  lastNote: string | null;
  recentTimeline?: {
    date: string;
    type: string;
    content: string;
  }[];
}

export async function getProcessesByPhone(whatsappNumber: string): Promise<ProcessData[]> {
  const res = await client.get(`/bot/processes/by-phone/${whatsappNumber}`);
  return (res.data.processes || []).map((p: any) => ({
    title: p.title,
    processNumber: p.processNumber || null,
    currentStatus: p.status || p.currentStatus,
    lastMovementDate: p.lastUpdate || p.lastMovementDate || null,
    lastNote: p.lawyerNote || p.lastNote || null,
    recentTimeline: p.recentTimeline || [],
  }));
}

// Tipo esperado de retorno de getProcessById:
export interface ProcessDetail {
  id: string;
  status: string;
  cliente: { nome: string; email: string } | null;
  recentTimeline: Array<{ data: string; descricao: string }>;
}

export async function getProcessesByLawyer(lawyerId: string): Promise<any[]> {
  try {
    const res = await client.get("/process", {
      params: { lawyerId },
    });
    return res.data;
  } catch (error: any) {
    throwHttp(error);
  }
}

export async function getProcessById(processId: string): Promise<ProcessDetail> {
  try {
    const res = await client.get(`/process/${processId}`);
    return res.data;
  } catch (error: any) {
    throwHttp(error);
  }
}

// ── Mutation helpers (AI write actions) ──
//
// All four routes hit the bot-protected backend (apiKey auth). The backend
// re-validates that `lawyerId` actually owns the target process, so a
// hallucinated lawyerId here translates to a 404, not a silent cross-tenant
// write.

export async function updateProcessStatus(
  processId: string,
  lawyerId: string,
  newStatus: string,
  lawyerNote?: string
): Promise<void> {
  try {
    await client.patch(`/bot/process/${processId}/status`, {
      newStatus,
      lawyerId,
      lawyerNote: lawyerNote ?? null,
    });
  } catch (error: any) {
    throwHttp(error);
  }
}

export async function addProcessNote(
  processId: string,
  lawyerId: string,
  note: string
): Promise<void> {
  try {
    await client.post(`/bot/process/${processId}/note`, { note, lawyerId });
  } catch (error: any) {
    throwHttp(error);
  }
}

export async function requestProcessDocument(
  processId: string,
  lawyerId: string,
  documentName: string
): Promise<void> {
  try {
    await client.post(`/bot/process/${processId}/request-document`, {
      documentName,
      lawyerId,
    });
  } catch (error: any) {
    throwHttp(error);
  }
}

export async function scheduleProcessEvent(
  processId: string,
  lawyerId: string,
  eventTitle: string,
  dateIso: string
): Promise<void> {
  try {
    await client.post(`/bot/process/${processId}/schedule-event`, {
      eventTitle,
      date: dateIso,
      lawyerId,
    });
  } catch (error: any) {
    throwHttp(error);
  }
}

// ── Mensagens ──

export async function syncMessage(data: {
  whatsappNumber: string;
  content: string;
  senderRole: "CLIENT" | "BOT";
  messageType: "TEXT" | "IMAGE" | "DOCUMENT";
  whatsappMessageId: string | null;
}): Promise<void> {
  await client.post("/messages/sync", {
    whatsappNumber: data.whatsappNumber,
    content: data.content,
    senderRole: data.senderRole,
    messageType: data.messageType,
    whatsappMessageId: data.whatsappMessageId,
  });
}

// ── Notificações ──

export async function notifyLawyer(data: {
  type: string;
  message: string;
  whatsappNumber: string;
}): Promise<void> {
  await client.post("/bot/notifications", data);
}

// ── Configurações ──

export async function getBotConfig(): Promise<{
  toneOfVoice: string;
}> {
  const res = await client.get("/bot/configurations");
  return res.data;
}
