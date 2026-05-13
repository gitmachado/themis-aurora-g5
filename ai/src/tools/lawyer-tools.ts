import { tool } from "@langchain/core/tools";
import { z } from "zod";
import {
  getProcessesByLawyer,
  getProcessById,
  updateProcessStatus,
  addProcessNote,
  requestProcessDocument,
  scheduleProcessEvent,
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

export const lawyerTools = [
  consultar_meus_processos,
  detalhar_processo,
  atualizar_status_processo,
  adicionar_nota_processo,
  solicitar_documento_processo,
  agendar_evento_processo,
];
