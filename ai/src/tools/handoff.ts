import { tool } from "@langchain/core/tools";
import { z } from "zod";
import { notifyLawyer, startHandoff } from "../utils/backend-client.js";

/**
 * Tool para acionar um advogado humano.
 * Deve ser usada quando o cliente pede explicitamente por atendimento humano
 * ou quando a IA detecta que não consegue resolver o problema do cliente.
 */
export const handoffTool = tool(
  async ({ reason, whatsappNumber }) => {
    try {
      // REGRA: Agora a IA apenas notifica. Ela NÃO pausa a si mesma automaticamente.
      // O advogado decide quando assumir o controle no App.
      await notifyLawyer({
        type: "HANDOFF",
        message: `SOLICITAÇÃO DE ATENDIMENTO: ${reason}`,
        whatsappNumber,
      });
      return "Advogado notificado sobre a necessidade de atendimento. A IA continuará ativa até que o advogado assuma o controle.";
    } catch (err: any) {
      console.error("[Tool: Handoff] Erro:", err.message);
      return "Erro técnico ao notificar advogado, mas a solicitação foi registrada nos logs.";
    }
  },
  {
    name: "ativar_atendimento_humano",
    description: "Aciona um advogado humano para assumir a conversa.",
    schema: z.object({
      reason: z.string().describe("O motivo do redirecionamento para o humano"),
      whatsappNumber: z.string().describe("O número do WhatsApp do cliente"),
    }),
  }
);
