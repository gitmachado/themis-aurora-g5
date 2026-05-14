import { z } from "zod";
import { DynamicStructuredTool } from "@langchain/core/tools";
import { searchKnowledge } from "../utils/vector-store.js";

/**
 * Tool para pesquisa na base de conhecimento do escritório (RAG).
 * Permite que a IA busque informações em manuais, FAQs e jurisprudências internas.
 */
export const knowledgeSearchTool = new DynamicStructuredTool({
  name: "pesquisar_conhecimento",
  description: "Busca informações detalhadas nos manuais, FAQs e jurisprudências do escritório Themis. Use sempre que o usuário tiver dúvidas sobre procedimentos, documentos necessários ou leis específicas.",
  schema: z.object({
    query: z.string().describe("A dúvida do usuário convertida em uma busca eficiente."),
  }),
  func: async ({ query }) => {
    try {
      console.log(`[Tool: Knowledge] Buscando por: ${query}`);
      // Aumentamos o topK para 5 para uma busca mais profunda via Tool
      const result = await searchKnowledge(query, 5);
      return result;
    } catch (error) {
      console.error("[Tool: Knowledge] Erro:", error);
      return "Erro ao acessar a base de conhecimento. Tente novamente mais tarde.";
    }
  },
});
