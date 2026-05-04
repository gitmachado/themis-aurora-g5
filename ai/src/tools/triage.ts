import { tool } from "@langchain/core/tools";
import { z } from "zod";
import { createLead, checkUserByCpf, notifyLawyer } from "../utils/backend-client.js";

// Mapeamento PT → EN para os enums do backend
const URGENCY_MAP: Record<string, string> = {
  alta: "High",
  media: "Medium",
  baixa: "Low",
};

const AVAILABILITY_MAP: Record<string, string> = {
  manha: "Morning",
  tarde: "Afternoon",
  noite: "Evening",
};

const CASE_TYPE_MAP: Record<string, string> = {
  trabalhista: "Labor",
  civil: "Civil",
  civel: "Civil",
  familia: "Family",
  criminal: "Criminal",
  previdenciario: "SocialSecurity",
};

function normalize(s: string | null | undefined): string {
  if (!s) return "";
  return s.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
}

/**
 * Tool para registrar os dados de um novo lead (triagem).
 */
export const leadTriageTool = tool(
  async (args) => {
    try {
      // 1. GATE DE QUALIDADE: Dados Mínimos Reais (CPF é o único técnico obrigatório)
      if (!args.name || args.name.length < 2) {
        return "REGISTRO_NEGADO: O nome fornecido é muito curto. Peça o nome completo do usuário.";
      }
      
      const isValidCPF = args.cpf && args.cpf.replace(/\D/g, "").length === 11;
      if (!isValidCPF) {
        return "REGISTRO_NEGADO: CPF inválido ou ausente. O CPF deve ter 11 dígitos.";
      }

      const hasAllData = args.caseType && 
                         args.caseDescription && 
                         args.urgency && 
                         args.contactAvailability;

      if (!hasAllData) {
        return "REGISTRO_NEGADO: Ainda faltam informações da ficha técnica (Tipo de Caso, Descrição, Urgência ou Disponibilidade).";
      }

      const cleanCPF = args.cpf!.replace(/\D/g, "");
      const finalName = args.name!;

      // 2. Mapeamento de Tradução (PT -> EN) para o Backend
      const urgencyEN = URGENCY_MAP[normalize(args.urgency)] || "Medium";
      const availabilityEN = AVAILABILITY_MAP[normalize(args.contactAvailability)] || "Afternoon";
      const caseTypeEN = CASE_TYPE_MAP[normalize(args.caseType)] || "Civil";

      // 3. Verifica se o CPF já existe
      const check = await checkUserByCpf(cleanCPF);
      if (check.exists) {
        return `REGISTRO_NEGADO: O CPF ${cleanCPF} já pertence ao usuário cadastrado '${check.name}'. Avise o cliente que ele já é reconhecido pelo sistema e que um advogado será notificado.`;
      }

      // 4. Registro Oficial no Backend
      const res = await createLead({
        name: finalName,
        whatsappNumber: args.whatsappNumber,
        cpf: cleanCPF,
        caseType: caseTypeEN,
        caseDescription: args.caseDescription!,
        urgency: urgencyEN,
        contactAvailability: availabilityEN,
      });

      // 5. Dispara Notificação Técnica
      await notifyLawyer({
        type: "NEW_LEAD",
        message: `NOVO LEAD QUALIFICADO: ${finalName} (${cleanCPF})\nCaso: ${args.caseType}\nUrgência: ${args.urgency}`,
        whatsappNumber: args.whatsappNumber
      }).catch(() => {});

      return `REGISTRO_SUCESSO: Lead '${finalName}' criado com ID ${res.id}. O advogado foi notificado no sistema.`;
    } catch (err: any) {
      console.error("[Tool: LeadTriage] Erro:", err.message);
      return "ERRO_TECNICO: Falha ao acessar o banco de dados de leads.";
    }
  },
  {
    name: "registrar_triagem",
    description: "Salva os dados coletados durante a triagem (nome, cpf, tipo de caso, etc) no banco de dados.",
    schema: z.object({
      whatsappNumber: z.string(),
      name: z.string().nullable().describe("Nome completo do interessado"),
      cpf: z.string().nullable().describe("CPF com 11 dígitos"),
      caseType: z.string().nullable().describe("Área do direito (ex: Trabalhista, Civil)"),
      caseDescription: z.string().nullable().describe("Resumo TÉCNICO e PROFISSIONAL em TERCEIRA PESSOA do problema (Ex: 'O cliente relata que...'). Este texto NUNCA deve ser visto pelo cliente."),
      urgency: z.string().nullable().describe("Nível de urgência determinado INTERNAMENTE (Alta, Média, Baixa) baseado na gravidade do relato. NUNCA pergunte ao cliente."),
      contactAvailability: z.string().nullable().describe("Melhor turno para contato (Manhã, Tarde, Noite)"),
    }),
  }
);
