import { tool } from "@langchain/core/tools";
import { z } from "zod";
import {
  getProcessesByLawyer,
  getProcessById,
  updateProcessStatus,
  addProcessNote,
  requestProcessDocument,
  scheduleProcessEvent,
  getMyAppointments,
  getAppointmentById,
  createAppointment,
  updateAppointment,
  cancelAppointment,
} from "../utils/backend-client.js";

const LEGAL_PROCESS_STATUSES = [
  "OPEN",
  "UNDER_ANALYSIS",
  "AWAITING_DOCUMENT",
  "COMPLETED",
  "ARCHIVED",
] as const;

/**
 * Tool para consultar todos os processos associados a um determinado advogado.
 */
export const consultar_meus_processos = tool(
  async ({ lawyerId }) => {
    try {
      const processes = await getProcessesByLawyer(lawyerId);
      if (!processes || processes.length === 0) {
        return "Nenhum processo encontrado para este advogado.";
      }
      return JSON.stringify(processes);
    } catch (err: any) {
      const status = err.status || 500;
      const message = err.message || "Erro desconhecido";
      console.error(`[Tool: ConsultarMeusProcessos] Erro HTTP ${status}: ${message}`);
      return "Não foi possível consultar os processos no momento.";
    }
  },
  {
    name: "consultar_meus_processos",
    description: "Consulta todos os processos de um determinado advogado no banco de dados.",
    schema: z.object({
      lawyerId: z.string().describe("O ID do advogado para consultar os processos"),
    }),
  }
);

/**
 * Tool para obter os detalhes completos de um processo específico pelo seu ID.
 */
export const detalhar_processo = tool(
  async ({ processId }) => {
    try {
      const process = await getProcessById(processId);
      return JSON.stringify(process);
    } catch (err: any) {
      const status = err.status || 500;
      const message = err.message || "Erro desconhecido";
      if (status === 404) {
        return "Processo não encontrado.";
      }
      console.error(`[Tool: DetalharProcesso] Erro HTTP ${status}: ${message}`);
      return "Não foi possível obter os detalhes do processo no momento.";
    }
  },
  {
    name: "detalhar_processo",
    description: "Obtém os detalhes de um processo específico pelo seu ID.",
    schema: z.object({
      processId: z.string().describe("O ID do processo que se deseja detalhar"),
    }),
  }
);

/**
 * Tool para atualizar o status de um processo do advogado.
 */
export const atualizar_status_processo = tool(
  async ({ processId, lawyerId, newStatus, lawyerNote }) => {
    try {
      await updateProcessStatus(processId, lawyerId, newStatus, lawyerNote);
      return `Status do processo ${processId} atualizado para ${newStatus} com sucesso.`;
    } catch (err: any) {
      const status = err.status || 500;
      const message = err.message || "Erro desconhecido";
      if (status === 404) {
        return "Processo não encontrado ou não pertence ao advogado.";
      }
      console.error(`[Tool: AtualizarStatusProcesso] Erro HTTP ${status}: ${message}`);
      return "Não foi possível atualizar o status do processo no momento.";
    }
  },
  {
    name: "atualizar_status_processo",
    description:
      "Atualiza o status de um processo do advogado. Use somente quando o advogado pedir explicitamente para mudar o status. Status válidos: OPEN, UNDER_ANALYSIS, AWAITING_DOCUMENT, COMPLETED, ARCHIVED.",
    schema: z.object({
      processId: z.string().describe("O ID do processo a ser atualizado"),
      lawyerId: z
        .string()
        .describe("O ID do advogado atual (do system prompt)"),
      newStatus: z
        .enum(LEGAL_PROCESS_STATUSES)
        .describe("O novo status do processo"),
      lawyerNote: z
        .string()
        .nullable()
        .optional()
        .describe("Nota opcional do advogado descrevendo a mudança"),
    }),
  }
);

/**
 * Tool para adicionar uma nota a um processo do advogado.
 */
export const adicionar_nota_processo = tool(
  async ({ processId, lawyerId, note }) => {
    try {
      await addProcessNote(processId, lawyerId, note);
      return `Nota adicionada ao processo ${processId} com sucesso.`;
    } catch (err: any) {
      const status = err.status || 500;
      const message = err.message || "Erro desconhecido";
      if (status === 404) {
        return "Processo não encontrado ou não pertence ao advogado.";
      }
      console.error(`[Tool: AdicionarNotaProcesso] Erro HTTP ${status}: ${message}`);
      return "Não foi possível adicionar a nota no momento.";
    }
  },
  {
    name: "adicionar_nota_processo",
    description:
      "Adiciona uma nota interna a um processo do advogado. A nota fica visível na timeline do processo.",
    schema: z.object({
      processId: z.string().describe("O ID do processo"),
      lawyerId: z
        .string()
        .describe("O ID do advogado atual (do system prompt)"),
      note: z.string().describe("Conteúdo da nota a ser adicionada"),
    }),
  }
);

/**
 * Tool para solicitar um documento ao cliente de um processo.
 */
export const solicitar_documento_processo = tool(
  async ({ processId, lawyerId, documentName }) => {
    try {
      await requestProcessDocument(processId, lawyerId, documentName);
      return `Solicitação do documento "${documentName}" enviada ao cliente.`;
    } catch (err: any) {
      const status = err.status || 500;
      const message = err.message || "Erro desconhecido";
      if (status === 404) {
        return "Processo não encontrado ou não pertence ao advogado.";
      }
      console.error(`[Tool: SolicitarDocumento] Erro HTTP ${status}: ${message}`);
      return "Não foi possível solicitar o documento no momento.";
    }
  },
  {
    name: "solicitar_documento_processo",
    description:
      "Solicita um documento ao cliente do processo. O cliente recebe uma notificação push pedindo o documento.",
    schema: z.object({
      processId: z.string().describe("O ID do processo"),
      lawyerId: z
        .string()
        .describe("O ID do advogado atual (do system prompt)"),
      documentName: z
        .string()
        .describe("Nome do documento a ser solicitado (ex: RG, CPF, Comprovante de residência)"),
    }),
  }
);

/**
 * Tool para agendar um evento na timeline do processo.
 */
export const agendar_evento_processo = tool(
  async ({ processId, lawyerId, eventTitle, dateIso }) => {
    try {
      await scheduleProcessEvent(processId, lawyerId, eventTitle, dateIso);
      return `Evento "${eventTitle}" agendado no processo ${processId} para ${dateIso}.`;
    } catch (err: any) {
      const status = err.status || 500;
      const message = err.message || "Erro desconhecido";
      if (status === 404) {
        return "Processo não encontrado ou não pertence ao advogado.";
      }
      if (status === 400 && /date/i.test(message)) {
        return "A data informada é inválida. Use o formato ISO (ex: 2026-08-15T14:30:00Z).";
      }
      console.error(`[Tool: AgendarEvento] Erro HTTP ${status}: ${message}`);
      return "Não foi possível agendar o evento no momento.";
    }
  },
  {
    name: "agendar_evento_processo",
    description:
      "Agenda um evento (audiência, reunião, prazo) no processo. O cliente recebe notificação. SEMPRE confirme data e hora antes de chamar.",
    schema: z.object({
      processId: z.string().describe("O ID do processo"),
      lawyerId: z
        .string()
        .describe("O ID do advogado atual (do system prompt)"),
      eventTitle: z.string().describe("Título do evento"),
      dateIso: z
        .string()
        .describe("Data e hora do evento em formato ISO 8601 (ex: 2026-08-15T14:30:00Z)"),
    }),
  }
);

// ── Agenda/Compromissos ──

const APPOINTMENT_TYPES = ["MEETING", "DEADLINE", "HEARING", "OTHER"] as const;
const APPOINTMENT_STATUSES = ["SCHEDULED", "COMPLETED", "CANCELED", "PENDING_APPROVAL"] as const;

/**
 * Tool para consultar compromissos da agenda do advogado.
 */
export const consultar_minha_agenda = tool(
  async ({ lawyerId, startDate, endDate, type, status }) => {
    try {
      const appointments = await getMyAppointments(lawyerId, {
        startDate,
        endDate,
        type,
        status,
      });
      if (!appointments || appointments.length === 0) {
        return "Nenhum compromisso encontrado para o período especificado.";
      }
      const formatted = appointments.map((a) => ({
        id: a.id,
        titulo: a.title,
        tipo: a.type,
        data_hora: a.scheduledAt,
        duracao_minutos: a.durationMinutes,
        status: a.status,
        cliente: a.clientName || "N/A",
        descricao: a.description || "",
      }));
      return JSON.stringify(formatted, null, 2);
    } catch (err: any) {
      const status = err.status || 500;
      const message = err.message || "Erro desconhecido";
      console.error(`[Tool: ConsultarMinhaAgenda] Erro HTTP ${status}: ${message}`);
      return "Não foi possível consultar a agenda no momento.";
    }
  },
  {
    name: "consultar_minha_agenda",
    description:
      "Consulta os compromissos da agenda do advogado com filtros opcionais por período, tipo (MEETING/DEADLINE/HEARING/OTHER) e status (SCHEDULED/COMPLETED/CANCELED/PENDING_APPROVAL).",
    schema: z.object({
      lawyerId: z.string().describe("O ID do advogado atual (do system prompt)"),
      startDate: z
        .string()
        .nullable()
        .optional()
        .describe("Data inicial em ISO 8601 (ex: 2026-05-14T00:00:00Z)"),
      endDate: z
        .string()
        .nullable()
        .optional()
        .describe("Data final em ISO 8601 (ex: 2026-05-21T23:59:59Z)"),
      type: z
        .enum(APPOINTMENT_TYPES)
        .nullable()
        .optional()
        .describe("Tipo de compromisso para filtrar"),
      status: z
        .enum(APPOINTMENT_STATUSES)
        .nullable()
        .optional()
        .describe("Status para filtrar"),
    }),
  }
);

/**
 * Tool para detalhar um compromisso específico.
 */
export const detalhar_compromisso = tool(
  async ({ appointmentId }) => {
    try {
      const appointment = await getAppointmentById(appointmentId);
      const formatted = {
        id: appointment.id,
        titulo: appointment.title,
        descricao: appointment.description,
        tipo: appointment.type,
        status: appointment.status,
        data_hora: appointment.scheduledAt,
        duracao_minutos: appointment.durationMinutes,
        cliente_id: appointment.clientId,
        cliente_nome: appointment.clientName,
        cliente_whatsapp: appointment.clientWhatsappNumber,
        processo_id: appointment.processId,
        criada_por_ia: appointment.createdByAI,
        criada_em: appointment.createdAt,
        atualizada_em: appointment.updatedAt,
      };
      return JSON.stringify(formatted, null, 2);
    } catch (err: any) {
      const status = err.status || 500;
      const message = err.message || "Erro desconhecido";
      if (status === 404) {
        return "Compromisso não encontrado.";
      }
      console.error(`[Tool: DetalharCompromisso] Erro HTTP ${status}: ${message}`);
      return "Não foi possível obter os detalhes do compromisso no momento.";
    }
  },
  {
    name: "detalhar_compromisso",
    description: "Obtém todos os detalhes de um compromisso específico pelo seu ID.",
    schema: z.object({
      appointmentId: z.string().describe("O ID do compromisso a detalhar"),
    }),
  }
);

/**
 * Tool para criar um novo compromisso.
 */
export const criar_compromisso = tool(
  async ({ lawyerId, title, type, scheduledAt, durationMinutes, description, clientId, processId }) => {
    try {
      const result = await createAppointment(lawyerId, {
        title,
        type,
        scheduledAt,
        durationMinutes: durationMinutes || 30,
        description,
        clientId,
        processId,
        createdByAI: true,
      });
      return `✅ Compromisso criado com sucesso! ID: ${result.id} | Data: ${result.scheduledAt}`;
    } catch (err: any) {
      const status = err.status || 500;
      const message = err.message || "Erro desconhecido";
      if (status === 400) {
        return `Erro ao criar compromisso: ${message}. Verifique se a data está em formato ISO 8601 e se há conflito de horário.`;
      }
      console.error(`[Tool: CriarCompromisso] Erro HTTP ${status}: ${message}`);
      return "Não foi possível criar o compromisso no momento.";
    }
  },
  {
    name: "criar_compromisso",
    description:
      "Cria um novo compromisso na agenda. Sempre confirmar título, tipo, data/hora e duração com o advogado ANTES de executar. Data deve estar em ISO 8601.",
    schema: z.object({
      lawyerId: z.string().describe("O ID do advogado atual (do system prompt)"),
      title: z.string().min(3).describe("Título/assunto do compromisso"),
      type: z
        .enum(APPOINTMENT_TYPES)
        .describe("Tipo: MEETING (reunião), DEADLINE (prazo), HEARING (audiência) ou OTHER"),
      scheduledAt: z
        .string()
        .describe("Data e hora em ISO 8601 (ex: 2026-05-20T14:30:00Z)"),
      durationMinutes: z
        .number()
        .int()
        .nullable()
        .optional()
        .describe("Duração em minutos (padrão: 30)"),
      description: z
        .string()
        .nullable()
        .optional()
        .describe("Descrição adicional do compromisso"),
      clientId: z
        .string()
        .nullable()
        .optional()
        .describe("ID do cliente relacionado (opcional)"),
      processId: z
        .string()
        .nullable()
        .optional()
        .describe("ID do processo relacionado (opcional)"),
    }),
  }
);

/**
 * Tool para atualizar um compromisso.
 */
export const atualizar_compromisso = tool(
  async ({ appointmentId, title, description, scheduledAt, durationMinutes, status }) => {
    try {
      const updated = await updateAppointment(appointmentId, {
        title,
        description,
        scheduledAt,
        durationMinutes,
        status,
      });
      let changes = [];
      if (title) changes.push(`Título: ${title}`);
      if (scheduledAt) changes.push(`Data/hora: ${scheduledAt}`);
      if (durationMinutes) changes.push(`Duração: ${durationMinutes}min`);
      if (status) changes.push(`Status: ${status}`);
      if (description) changes.push(`Descrição atualizada`);

      return `✅ Compromisso atualizado com sucesso!\nAlterações: ${changes.join(" | ")}`;
    } catch (err: any) {
      const status = err.status || 500;
      const message = err.message || "Erro desconhecido";
      if (status === 404) {
        return "Compromisso não encontrado.";
      }
      console.error(`[Tool: AtualizarCompromisso] Erro HTTP ${status}: ${message}`);
      return "Não foi possível atualizar o compromisso no momento.";
    }
  },
  {
    name: "atualizar_compromisso",
    description:
      "Atualiza campos de um compromisso existente. Confirmar quais campos serão alterados ANTES de executar.",
    schema: z.object({
      appointmentId: z.string().describe("O ID do compromisso a atualizar"),
      title: z
        .string()
        .nullable()
        .optional()
        .describe("Novo título"),
      description: z
        .string()
        .nullable()
        .optional()
        .describe("Nova descrição"),
      scheduledAt: z
        .string()
        .nullable()
        .optional()
        .describe("Nova data/hora em ISO 8601"),
      durationMinutes: z
        .number()
        .int()
        .nullable()
        .optional()
        .describe("Nova duração em minutos"),
      status: z
        .enum(APPOINTMENT_STATUSES)
        .nullable()
        .optional()
        .describe("Novo status"),
    }),
  }
);

/**
 * Tool para cancelar um compromisso.
 */
export const cancelar_compromisso = tool(
  async ({ appointmentId, appointmentTitle, appointmentDate }) => {
    try {
      await cancelAppointment(appointmentId);
      return `✅ Compromisso "${appointmentTitle}" (${appointmentDate}) cancelado com sucesso.`;
    } catch (err: any) {
      const status = err.status || 500;
      const message = err.message || "Erro desconhecido";
      if (status === 404) {
        return "Compromisso não encontrado.";
      }
      console.error(`[Tool: CancelarCompromisso] Erro HTTP ${status}: ${message}`);
      return "Não foi possível cancelar o compromisso no momento.";
    }
  },
  {
    name: "cancelar_compromisso",
    description:
      "Cancela um compromisso na agenda. Sempre informar título e data do compromisso e pedir confirmação ANTES de executar.",
    schema: z.object({
      appointmentId: z.string().describe("O ID do compromisso a cancelar"),
      appointmentTitle: z
        .string()
        .describe("Título do compromisso (para confirmação)"),
      appointmentDate: z
        .string()
        .describe("Data/hora do compromisso (para confirmação)"),
    }),
  }
);

export const lawyerTools = [
  consultar_meus_processos,
  detalhar_processo,
  atualizar_status_processo,
  adicionar_nota_processo,
  solicitar_documento_processo,
  agendar_evento_processo,
  consultar_minha_agenda,
  detalhar_compromisso,
  criar_compromisso,
  atualizar_compromisso,
  cancelar_compromisso,
];
