import { tool } from "@langchain/core/tools";
import { z } from "zod";
import { getAvailableSlots, scheduleAppointment, getUserByPhone } from "../utils/backend-client.js";

const DEFAULT_LAWYER_ID = process.env.DEFAULT_LAWYER_ID || "11111111-1111-1111-1111-111111111111";

/**
 * Tool para consultar disponibilidade do advogado e agendar compromissos.
 * Permite que o bot WhatsApp:
 * 1. Verifique horários disponíveis em uma data específica
 * 2. Agende uma reunião com o cliente
 */
export const appointmentTool = tool(
  async ({ action, lawyerId, clientPhone, date, title, description, time, durationMinutes }) => {
    // Usar advogado padrão se não for fornecido um ID
    const effectiveLawyerId = lawyerId || DEFAULT_LAWYER_ID;
    try {
      if (action === "check_availability") {
        return await handleCheckAvailability(effectiveLawyerId, date);
      } else if (action === "schedule") {
        return await handleScheduleAppointment(
          effectiveLawyerId,
          clientPhone,
          date,
          time,
          title,
          description,
          durationMinutes
        );
      }
      return "Ação desconhecida. Use 'check_availability' ou 'schedule'.";
    } catch (err: any) {
      console.error("[Tool: Appointment]", err.message);
      return `Erro ao processar agendamento: ${err.message}`;
    }
  },
  {
    name: "agendar_compromisso",
    description: `Ferramenta para consultar disponibilidade de agenda do advogado e agendar compromissos com clientes.

Ações disponíveis:
1. **check_availability**: Lista horários disponíveis em uma data (use para apresentar opções ao cliente)
2. **schedule**: Cria um novo compromisso/reunião com data e hora específicas

Exemplo de fluxo:
- Cliente: "Gostaria de marcar uma reunião"
- Bot: Usa check_availability para encontrar horários
- Bot: Apresenta opções ao cliente
- Cliente: Escolhe um horário
- Bot: Usa schedule para confirmar o agendamento`,
    schema: z.object({
      action: z.enum(["check_availability", "schedule"])
        .describe("Ação a executar: verificar disponibilidade ou agendar"),
      lawyerId: z.string().describe("ID do advogado (obtém da base de dados)"),
      clientPhone: z.string().optional()
        .describe("Número de WhatsApp do cliente (necessário apenas para 'schedule')"),
      date: z.string().describe("Data no formato YYYY-MM-DD (ex: 2026-05-20)"),
      title: z.string().optional()
        .describe("Título/assunto do compromisso (ex: 'Consulta inicial', 'Reunião de acompanhamento')"),
      description: z.string().optional()
        .describe("Descrição detalhada do compromisso"),
      time: z.string().optional()
        .describe("Horário no formato HH:mm (ex: 14:30) - necessário apenas para 'schedule'"),
      durationMinutes: z.number().optional().default(60)
        .describe("Duração da reunião em minutos (padrão: 60)"),
    }),
  }
);

async function handleCheckAvailability(lawyerId: string, date: string): Promise<string> {
  try {
    const slots = await getAvailableSlots(lawyerId, date);

    if (slots.length === 0) {
      return `Não há horários disponíveis para o advogado em ${date}. Sugira outra data ao cliente.`;
    }

    const formattedSlots = slots
      .map((slot) => {
        const time = new Date(slot.isoTime);
        return time.toLocaleTimeString("pt-BR", { hour: "2-digit", minute: "2-digit" });
      })
      .join(", ");

    return `✓ Horários disponíveis em ${date}: ${formattedSlots}\n\nApresente essas opções ao cliente e use a ação 'schedule' quando ele escolher uma.`;
  } catch (err: any) {
    throw new Error(`Falha ao consultar disponibilidade: ${err.message}`);
  }
}

async function handleScheduleAppointment(
  lawyerId: string,
  clientPhone: string | undefined,
  date: string,
  time: string | undefined,
  title: string | undefined,
  description: string | undefined,
  durationMinutes: number
): Promise<string> {
  if (!clientPhone || !time || !title) {
    throw new Error("Para agendar, forneça: clientPhone, time (HH:mm), e title");
  }

  let clientId: string | undefined;

  const userInfo = await getUserByPhone(clientPhone);
  if (!userInfo.exists || !userInfo.userId) {
    throw new Error(`Cliente com WhatsApp ${clientPhone} não encontrado na base de dados.`);
  }
  clientId = userInfo.userId;

  const isoDateTime = `${date}T${time}:00Z`;

  try {
    const appointment = await scheduleAppointment({
      lawyerId,
      clientId,
      title,
      description: description || "",
      type: "MEETING",
      scheduledAt: isoDateTime,
      durationMinutes,
      createdByAI: true,
    });

    return `✅ Agendamento pré-reservado!\n\nO advogado revisará sua solicitação em breve para confirmação final.\n\nDetalhes:\n- Título: ${title}\n- Data/Hora: ${date} às ${time}\n- Duração: ${durationMinutes} minutos`;
  } catch (err: any) {
    throw new Error(`Falha ao agendar: ${err.response?.data?.message || err.message}`);
  }
}
