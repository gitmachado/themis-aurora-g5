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

// ── Agenda/Compromissos ──

export interface AvailableSlot {
  time: string;
  isoTime: string;
}

export async function getAvailableSlots(
  lawyerId: string,
  date: string
): Promise<AvailableSlot[]> {
  const res = await client.get(`/appointments/slots`, {
    params: {
      lawyerId,
      date,
    },
  });
  return res.data.slots || [];
}

export async function scheduleAppointment(data: {
  lawyerId: string;
  clientId: string;
  title: string;
  description: string;
  type: "MEETING" | "DEADLINE" | "HEARING" | "OTHER";
  scheduledAt: string;
  durationMinutes: number;
  createdByAI?: boolean;
}): Promise<{ id: string; scheduledAt: string }> {
  const res = await client.post("/appointments", data);
  return {
    id: res.data.id,
    scheduledAt: res.data.scheduledAt,
  };
}
