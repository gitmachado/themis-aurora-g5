import axios, { AxiosInstance } from "axios";
import jwt from "jsonwebtoken";

const BACKEND_API_URL = process.env.BACKEND_API_URL || "http://localhost:3000";
const JWT_SECRET = process.env.JWT_SECRET || "development_secret_key_change_me";

/**
 * Gera um JWT válido para autenticar como SYSTEM (IA)
 * Usado para todas as chamadas que requerem autenticação
 */
function generateSystemToken(): string {
  return jwt.sign(
    {
      sub: "11111111-1111-4111-8111-111111111111",
      id: "11111111-1111-4111-8111-111111111111",
      email: "ai@themis.local",
      role: "SYSTEM",
    },
    JWT_SECRET,
    { expiresIn: "24h" }
  );
}

/**
 * Cliente HTTP centralizado para comunicação AI → Backend.
 * Todas as chamadas ao backend passam por aqui com JWT válido.
 */
const client: AxiosInstance = axios.create({
  baseURL: `${BACKEND_API_URL}/api/v1`,
  timeout: 10000,
});

// Interceptor para adicionar JWT em todas as requisições
client.interceptors.request.use((config) => {
  const token = generateSystemToken();
  config.headers.Authorization = `Bearer ${token}`;
  config.headers["x-api-key"] = process.env.BOT_API_KEY || "development_bot_key_change_me";
  return config;
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
  email?: string;
  cpf?: string;
  caseType?: string;
  caseDescription?: string;
  urgency?: string;
  contactAvailability?: string;
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
  const res = await client.get(`/bot/appointments/slots`, {
    params: {
      lawyerId,
      date,
      slotDurationMinutes: 30,
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
  const res = await client.post("/bot/appointments", data);
  return {
    id: res.data.id,
    scheduledAt: res.data.scheduledAt,
  };
}
