import { tool } from "@langchain/core/tools";
import { z } from "zod";
import { getProcessesByPhone } from "../utils/backend-client.js";

/**
 * Tool para consultar o status dos processos de um cliente.
 * Retorna uma lista de processos com seus status e últimas movimentações.
 */
export const processStatusTool = tool(
  async ({ whatsappNumber }) => {
    try {
      const processes = await getProcessesByPhone(whatsappNumber);
      if (processes.length === 0) {
        return "Nenhum processo encontrado para este número.";
      }
      return JSON.stringify(processes, null, 2);
    } catch (err: any) {
      console.error("[Tool: ProcessStatus] Erro:", err.message);
      return "Erro ao consultar processos no banco de dados.";
    }
  },
  {
    name: "consultar_processos",
    description: "Busca informações sobre os processos jurídicos do cliente no banco de dados do escritório. O resultado incluirá o 'recentTimeline' (linha do tempo recente), que você deve ler e usar para explicar ao cliente, de forma simples e acolhedora, a história recente e os últimos andamentos do caso.",
    schema: z.object({
      whatsappNumber: z.string().describe("O número do WhatsApp do cliente"),
    }),
  }
);
