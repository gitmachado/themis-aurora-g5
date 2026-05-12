import { tool } from "@langchain/core/tools";
import { z } from "zod";
import { getProcessesByLawyer, getProcessById } from "../utils/backend-client.js";

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

export const lawyerTools = [consultar_meus_processos, detalhar_processo];
