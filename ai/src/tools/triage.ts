import { tool } from "@langchain/core/tools";
import { z } from "zod";
import { createLead, checkUserByCpf, notifyLawyer } from "../utils/backend-client.js";
import { isValidCPF } from "../utils/validators.js";
import {
  URGENCY_MAP,
  AVAILABILITY_MAP,
  CASE_TYPE_MAP,
  normalize,
} from "../utils/translations.js";

/**
 * Tool para registrar os dados de um novo lead (triagem).
 * Chamada pelo Agente Unificado quando todos os dados foram coletados.
 */
export const leadTriageTool = tool(
  async (args) => {
    try {
      // 1. GATE DE QUALIDADE: Dados Mínimos Reais
      if (!args.name || args.name.trim().length < 2) {
        return "REGISTRO_NEGADO: O nome fornecido é muito curto. Peça o nome completo do usuário.";
      }

      if (!args.email || !args.email.includes("@")) {
        return "REGISTRO_NEGADO: E-mail ausente ou inválido. Peça o e-mail ao usuário — será usado como login no aplicativo.";
      }

      if (!args.cpf) {
        return "REGISTRO_NEGADO: CPF ausente. Peça o CPF ao usuário.";
      }

      const cleanCPF = args.cpf.replace(/\D/g, "");
      
      // Usa o validador real com verificação de dígito verificador
      if (!isValidCPF(cleanCPF)) {
        return "REGISTRO_NEGADO: CPF inválido. Peça ao usuário que verifique e envie o CPF correto.";
      }

      const hasAllData = args.caseType && 
                         args.caseDescription && 
                         args.urgency && 
                         args.contactAvailability;

      if (!hasAllData) {
        return "REGISTRO_NEGADO: Ainda faltam informações da ficha técnica (Tipo de Caso, Descrição, Urgência ou Disponibilidade).";
      }

      const finalName = args.name!.trim();

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
        email: args.email!.trim().toLowerCase(),
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
      }).catch((err) => {
        console.error("[Tool: LeadTriage] Erro ao notificar advogado:", err);
      });

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
      name: z.string().nullable().describe("Nome COMPLETO do interessado (nome e sobrenome, ex: 'Maria Silva')"),
      email: z.string().nullable().describe("E-mail do interessado — será usado como login no aplicativo"),
      cpf: z.string().nullable().describe("CPF com 11 dígitos"),
      caseType: z.string().nullable().describe("Área do direito (ex: Trabalhista, Civil, Família, Criminal, Previdenciário, Herança, Inventário)"),
      caseDescription: z.string().nullable().describe("Resumo TÉCNICO e PROFISSIONAL em TERCEIRA PESSOA do problema (Ex: 'O cliente relata que...'). Este texto NUNCA deve ser visto pelo cliente."),
      urgency: z.string().nullable().describe("Nível de urgência determinado INTERNAMENTE (Alta, Média, Baixa) baseado na gravidade do relato. NUNCA pergunte ao cliente."),
      contactAvailability: z.string().nullable().describe("Melhor turno para contato (Manhã, Tarde, Noite)"),
    }),
  }
);
