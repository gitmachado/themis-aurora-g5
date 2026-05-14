import { tool } from "@langchain/core/tools";
import { z } from "zod";
import { getAvailableSlots, scheduleAppointment, getOpenAppointmentsByPhone } from "../utils/backend-client.js";

const DEFAULT_LAWYER_ID = process.env.DEFAULT_LAWYER_ID || "11111111-1111-1111-1111-111111111111";

/**
 * Tool para consultar disponibilidade do advogado e agendar compromissos.
 * O clientId é omitido intencionalmente — o appointment é criado sem vínculo direto,
 * pois o lead já contém todas as informações do cliente.
 */
export const appointmentTool = tool(
  async ({ action, date, title, description, time, durationMinutes, triageData, whatsappNumber }: any) => {
    const effectiveLawyerId = DEFAULT_LAWYER_ID;
    try {
      if (action === "check_availability") {
        if (!date) {
          return "Para verificar disponibilidade, preciso da data. Use o formato YYYY-MM-DD.";
        }
        return await handleCheckAvailability(effectiveLawyerId, date);
      } else if (action === "check_open_appointments") {
        // Tentar pegar whatsappNumber de múltiplas fontes
        const finalWhatsapp = whatsappNumber || (triageData as any)?.whatsappNumber;
        if (!finalWhatsapp) {
          console.error("[Tool: Appointment] WhatsApp não encontrado em nenhuma fonte");
          return "ERRO: Número do WhatsApp não encontrado no sistema. Não é possível verificar reuniões abertas.";
        }
        return await handleCheckOpenAppointments(finalWhatsapp);
      } else if (action === "schedule") {
        const triageValidation = validateTriageDataForScheduling(triageData);
        if (!triageValidation.valid) {
          return triageValidation.message;
        }

        return await handleScheduleAppointment(
          effectiveLawyerId,
          date,
          time ?? undefined,
          title ?? "Consulta inicial",
          description ?? undefined,
          durationMinutes ?? 30,
          triageData
        );
      }
      return "Ação desconhecida. Use 'check_availability', 'check_open_appointments' ou 'schedule'.";
    } catch (err: any) {
      console.error("[Tool: Appointment]", err.message);
      return `Erro: ${err.message}. NÃO peça os dados novamente ao cliente — informe que houve uma falha técnica.`;
    }
  },
  {
    name: "agendar_compromisso",
    description: `Ferramenta para consultar disponibilidade de agenda do advogado e agendar compromissos.

Ações:
1. **check_open_appointments**: Verifica se cliente já tem reunião aberta (SEMPRE fazer primeiro!)
2. **check_availability**: Lista horários disponíveis em uma data
3. **schedule**: Cria um novo compromisso com data e hora específicas

O WhatsApp do cliente já está registrado — NÃO é necessário informá-lo.`,
    schema: z.object({
      action: z.enum(["check_availability", "check_open_appointments", "schedule"])
        .describe("Ação a executar: verificar disponibilidade ou agendar"),
      date: z.string().nullable().optional()
        .describe("Data no formato YYYY-MM-DD. Necessária para 'check_availability' e 'schedule'. Não é necessária para 'check_open_appointments'."),
      title: z.string().nullable().optional()
        .describe("Título do compromisso (ex: 'Consulta inicial - Direito Trabalhista'). Se não informado, será 'Consulta inicial'."),
      description: z.string().nullable().optional()
        .describe("Descrição detalhada do compromisso"),
      time: z.string().nullable().optional()
        .describe("Horário no formato HH:mm (ex: 14:30) — necessário para 'schedule'"),
      durationMinutes: z.number().nullable().optional()
        .describe("Duração em minutos (padrão: 30)"),
      triageData: z.object({
        name: z.string().nullable().optional(),
        email: z.string().nullable().optional(),
        cpf: z.string().nullable().optional(),
        caseType: z.string().nullable().optional(),
        caseDescription: z.string().nullable().optional(),
        contactAvailability: z.string().nullable().optional(),
        whatsappNumber: z.string().nullable().optional(),
      }).nullable().optional()
        .describe("Dados de triagem do cliente já coletados — automaticamente compilado pelo agente"),
      whatsappNumber: z.string()
        .describe("WhatsApp do cliente (injetado automaticamente pelo router)"),
    }),
  }
);

async function handleCheckOpenAppointments(whatsappNumber: string): Promise<string> {
  console.log(`[Tool: Appointment] CHECK_OPEN_APPOINTMENTS iniciado para ${whatsappNumber}`);

  if (!whatsappNumber) {
    console.warn(`[Tool: Appointment] WhatsAppNumber não fornecido`);
    return "ERRO: Número do WhatsApp não encontrado. Não é possível verificar reuniões abertas.";
  }

  try {
    console.log(`[Tool: Appointment] Chamando getOpenAppointmentsByPhone(${whatsappNumber})...`);
    const result = await getOpenAppointmentsByPhone(whatsappNumber);
    console.log(`[Tool: Appointment] Resultado recebido:`, result);

    if (result.hasOpenAppointments) {
      const statusList = result.appointments
        .map((a: any) => `• ${a.title} (${a.status}) — ${a.scheduledAt ? new Date(a.scheduledAt).toLocaleDateString('pt-BR') : 'sem data'}`)
        .join('\n');
      const response = `🚫 REUNIAO_ABERTA: Este cliente já possui ${result.count} reunião(ões) pendente(s):\n${statusList}\n\nNão é permitido agendar nova reunião. Responda que há reunião pendente e ofereça handoff.`;
      console.log(`[Tool: Appointment] Retornando BLOQUEIO (reunião aberta)`);
      return response;
    }

    const response = `✅ NENHUMA_REUNIAO_ABERTA: Cliente não tem reuniões abertas. PROSSIGA IMEDIATAMENTE: Chame check_availability para hoje (veja {currentDate} no contexto) e apresente os horários na mesma mensagem.`;
    console.log(`[Tool: Appointment] Retornando SUCESSO (sem reunião aberta)`);
    return response;
  } catch (err: any) {
    console.error(`[Tool: Appointment] ERRO ao verificar reuniões abertas:`, err);
    throw new Error(`Falha ao verificar reuniões abertas: ${err.message}`);
  }
}

async function handleCheckAvailability(lawyerId: string, date: string): Promise<string> {
  try {
    console.log(`[Tool: Appointment] CHECK_AVAILABILITY iniciado para ${date}`);
    const slots = await getAvailableSlots(lawyerId, date);
    console.log(`[Tool: Appointment] Slots encontrados: ${slots.length}`);

    if (slots.length === 0) {
      console.warn(`[Tool: Appointment] Nenhum slot disponível em ${date}`);
      return `Não há horários disponíveis em ${date}. Sugira outra data ao cliente.`;
    }

    // Retorna apenas 4 opções distribuídas ao longo do dia
    const step = Math.max(1, Math.floor(slots.length / 4));
    const picked = [0, step, step * 2, step * 3].filter(i => i < slots.length);
    const suggestions = picked.map(i => slots[i].time);
    const response = `✅ HORARIOS_DISPONIVEIS: ${suggestions.join(", ")}. Use esses horários na sua resposta ao cliente (exemplo: "Temos 09:00, 11:30, 14:00, 16:30 disponíveis para hoje").`;

    console.log(`[Tool: Appointment] Retornando horários:`, suggestions);
    return response;
  } catch (err: any) {
    console.error(`[Tool: Appointment] ERRO ao consultar disponibilidade:`, err);
    throw new Error(`Falha ao consultar disponibilidade: ${err.message}`);
  }
}

function validateTriageDataForScheduling(triageData: any): { valid: boolean; message: string } {
  if (!triageData) {
    return {
      valid: false,
      message: "AGENDAMENTO_NEGADO: Dados do cliente não encontrados. Você precisa completar a triagem do cliente primeiro (nome, email, CPF, tipo de caso, descrição e disponibilidade) antes de agendar uma consulta.",
    };
  }

  const missingFields: string[] = [];

  if (!triageData.name || triageData.name.trim().length < 2) {
    missingFields.push("nome do cliente");
  }
  if (!triageData.email || !triageData.email.includes("@")) {
    missingFields.push("email do cliente");
  }
  if (!triageData.cpf) {
    missingFields.push("CPF do cliente");
  }
  if (!triageData.caseType) {
    missingFields.push("tipo de caso");
  }
  if (!triageData.caseDescription) {
    missingFields.push("descrição do caso");
  }
  if (!triageData.contactAvailability) {
    missingFields.push("disponibilidade de contato");
  }

  if (missingFields.length > 0) {
    return {
      valid: false,
      message: `AGENDAMENTO_NEGADO: Faltam informações obrigatórias: ${missingFields.join(", ")}. Colete esses dados com o cliente antes de tentar agendar a consulta.`,
    };
  }

  return { valid: true, message: "" };
}

async function handleScheduleAppointment(
  lawyerId: string,
  date: string,
  time: string | undefined,
  title: string,
  description: string | undefined,
  durationMinutes: number,
  triageData: any
): Promise<string> {
  if (!time) {
    return "Para agendar, preciso que o cliente escolha um horário (formato HH:mm). Pergunte qual horário ele prefere.";
  }

  // NOVO: Verificar se cliente já tem reunião aberta
  try {
    const whatsappNumber = triageData?.whatsappNumber;
    if (whatsappNumber) {
      const openAppointments = await getOpenAppointmentsByPhone(whatsappNumber);
      if (openAppointments.hasOpenAppointments) {
        return `⚠️ AGENDAMENTO_BLOQUEADO: Este cliente já possui ${openAppointments.count} reunião(ões) aberta(s) no sistema (status: ${openAppointments.appointments[0]?.status || 'pendente'}).

Não é possível agendar uma nova reunião enquanto houver reuniões abertas.

👤 Como proceder: Faça um HANDOFF para atendimento humano para que o advogado analise a situação com o cliente. Use a ferramenta apropriada de handoff.`;
      }
    }
  } catch (err: any) {
    console.warn("[Tool: Appointment] Erro ao verificar reuniões abertas (continuando):", err.message);
  }

  // Montar datetime com offset de Brasília (-03:00)
  const isoDateTime = `${date}T${time}:00-03:00`;

  try {
    await scheduleAppointment({
      lawyerId,
      clientId: "", // sem vínculo direto — o lead já contém os dados do cliente
      title,
      description: description || "",
      type: "MEETING",
      scheduledAt: isoDateTime,
      durationMinutes,
      createdByAI: true,
      clientName: triageData?.name || null,
      clientWhatsappNumber: triageData?.whatsappNumber || null,
    });

    return `✅ Consulta pré-reservada para ${date} às ${time} (${durationMinutes} min). Informe ao cliente que o advogado revisará e ele receberá confirmação via WhatsApp.`;
  } catch (err: any) {
    const msg = err.response?.data?.message || err.response?.data?.error || err.message;
    if (msg.includes("conflito") || msg.includes("indisponível") || msg.includes("Horário")) {
      return `Esse horário já está ocupado. Peça ao cliente para escolher outro dos horários disponíveis.`;
    }
    throw new Error(`Falha ao agendar: ${msg}`);
  }
}
