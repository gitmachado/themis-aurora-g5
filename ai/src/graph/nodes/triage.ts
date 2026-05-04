import { z } from "zod";
import { ChatOpenAI } from "@langchain/openai";
import { AIMessage } from "@langchain/core/messages";
import { OmniStateType, TriageData, TriageStep } from "../state.js";
import { SYSTEM_PROMPT, TRIAGE_PROMPT } from "../../config/prompts.js";
import {
  isValidCPF,
  isValidCaseType,
  isValidUrgency,
  isValidAvailability,
} from "../../utils/validators.js";
import { createLead as createLeadOnBackend, checkUserByCpf } from "../../utils/backend-client.js";

// Mapeamento PT → EN para os enums do backend
const CASE_TYPE_MAP: Record<string, string> = {
  trabalhista: "Labor",
  civel: "Civil",
  civil: "Civil",
  heranca: "Civil",
  inventario: "Civil",
  familia: "Family",
  criminal: "Criminal",
  previdenciario: "SocialSecurity",
};
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

function normalize(s: string | null | undefined): string {
  if (!s) return "";
  return s.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
}

function mapToEnglish(pt: string | null | undefined, map: Record<string, string>): string {
  if (!pt) return "";
  return map[normalize(pt)] ?? pt;
}

function nextStep(step: TriageStep): TriageStep {
  const order: TriageStep[] = [
    "NAME", "CPF", "CASE_TYPE", "DESCRIPTION", "URGENCY", "AVAILABILITY", "DONE",
  ];
  const idx = order.indexOf(step);
  if (idx === -1) return "NAME";
  return order[Math.min(idx + 1, order.length - 1)];
}

async function createLead(triage: TriageData, whatsappNumber: string): Promise<string> {
  const res = await createLeadOnBackend({
    name: triage.name || "Interessado",
    whatsappNumber,
    cpf: triage.cpf?.replace(/\D/g, "") || "",
    caseType: triage.caseType ? mapToEnglish(triage.caseType, CASE_TYPE_MAP) : "Civil",
    caseDescription: triage.caseDescription || "",
    urgency: triage.urgency ? mapToEnglish(triage.urgency, URGENCY_MAP) : "Medium",
    contactAvailability: triage.contactAvailability ? mapToEnglish(triage.contactAvailability, AVAILABILITY_MAP) : "Afternoon",
  });
  return res.id;
}

function isFullName(name: string | null | undefined): boolean {
  if (!name) return false;
  return name.trim().split(/\s+/).length >= 2;
}

export async function triageNode(
  state: OmniStateType
): Promise<Partial<OmniStateType>> {
  const { whatsappNumber, messages, triage } = state;
  const userInput = String(messages.at(-1)?.content ?? "").trim();
  let step: TriageStep = triage.currentStep;

  // Auto-correção: Se já temos o dado deste step, pula para o próximo
  const dataMap: Record<string, any> = {
    NAME: triage.name && isFullName(triage.name) ? triage.name : null,
    CPF: triage.cpf,
    CASE_TYPE: triage.caseType,
    DESCRIPTION: triage.caseDescription,
    URGENCY: triage.urgency,
    AVAILABILITY: triage.contactAvailability,
  };

  if ((step as string) !== "DONE" && (dataMap as any)[step]) {
    const next = nextStep(step);
    console.log(`[Triage Node] Auto-pulo: Step ${step} já preenchido adequadamente, indo para ${next}`);
    if (next !== step) {
      return triageNode({
        ...state,
        triage: { ...triage, currentStep: next }
      });
    }
  }

  // DONE: cria o lead no backend (se ainda não existir)
  if ((step as string) === "DONE") {
    if (state.leadId) {
      console.log(`[Triage Node] Lead ${state.leadId} já existe. Finalizando.`);
      return {
        currentNode: "sync_node",
        messages: [], 
      };
    }

    try {
      const leadId = await createLead(triage, whatsappNumber);
      return {
        leadId,
        currentNode: "sync_node",
        messages: [
          new AIMessage(
            `Suas informações foram registradas! Um advogado especialista entrará em contato no período da ${triage.contactAvailability || "tarde"}. Enquanto isso, se tiver alguma dúvida, pode me perguntar!`
          ),
        ],
      };
    } catch (err) {
      console.error("[Triage Node] Erro ao criar lead (DONE):", err);
      return {
        currentNode: "sync_node",
        messages: [
          new AIMessage("Houve um pequeno erro ao registrar suas informações, mas não se preocupe: um advogado já foi notificado e falará com você em breve! 😊"),
        ],
      };
    }
  }

  const aiMessagesCount = messages.filter((m: any) => {
    const type = typeof m.getType === 'function' ? m.getType() : 
                 (typeof m._getType === 'function' ? m._getType() : m.type);
    return type === 'ai';
  }).length;
  const isFirstContact = aiMessagesCount === 0;

  const model = new ChatOpenAI({
    model: process.env.OPENAI_MODEL || "gpt-4o-mini",
    apiKey: process.env.OPENAI_API_KEY,
    temperature: 0.3,
  });

  const extractionSchema = z.object({
    name: z.string().nullable().describe("Nome completo do usuário, se fornecido."),
    cpf: z.string().nullable().describe("CPF do usuário (11 dígitos), se fornecido."),
    caseType: z.string().nullable().describe('Tipo do caso (Trabalhista, Cível, Família, Criminal ou Previdenciário), se identificável.'),
    caseDescription: z.string().nullable().describe('Resumo TÉCNICO e PROFISSIONAL em TERCEIRA PESSOA do relato do usuário (Ex: "O cliente relata que..."). Este texto é EXCLUSIVO para o banco de dados e NUNCA deve ser repetido para o cliente.'),
    contactAvailability: z.string().nullable().describe('Disponibilidade (Manhã, Tarde ou Noite), se fornecida.'),
    urgencyDetermination: z.string().nullable().describe("Determine a urgência (Alta, Média, Baixa) internamente baseada na descrição do caso. NUNCA pergunte isso ao cliente."),
    replyMessage: z.string().describe("Mensagem amigável para o cliente. IMPORTANTE: NUNCA confirme ou repita o resumo técnico (caseDescription) para o cliente. Apenas agradeça pela descrição e siga para o próximo passo ou informe que um advogado entrará em contato."),
  });

  const structuredModel = model.withStructuredOutput(extractionSchema);

  const history = messages.slice(-10).map((m: any) => ({
    role: (typeof m.getType === 'function' ? m.getType() : (typeof m._getType === 'function' ? m._getType() : m.type)) === 'ai' ? 'assistant' : 'user',
    content: m.content
  }));

  const next = nextStep(step);

  const prompt = TRIAGE_PROMPT
    .replace("{currentStep}", step)
    .replace("{validationError}", "nenhum")
    .replace("{isFirstContact}", String(isFirstContact))
    .replace("{userMessage}", userInput)
    .replace("{triageData}", JSON.stringify({
      nome: triage.name,
      cpf: triage.cpf ? "***" : null,
      tipoCaso: triage.caseType,
      descricao: triage.caseDescription,
      disponibilidade: triage.contactAvailability,
    })) + `\n\nATENÇÃO: Você NUNCA deve perguntar a urgência ao cliente e NUNCA deve repetir o resumo técnico/profissional gerado para ele. Determine a urgência silenciosamente. Se o usuário forneceu o dado da etapa atual (${step}) corretamente, você DEVE pedir o dado da PRÓXIMA etapa (${next}) na sua 'replyMessage'.`;

  let response;
  try {
    response = await structuredModel.invoke([
      { role: "system", content: SYSTEM_PROMPT },
      ...history,
      { role: "user", content: prompt },
    ]);
    console.log(`[Triage Node] Extração:`, {
      step,
      extracted: {
        name: response.name,
        cpf: response.cpf,
        caseType: response.caseType,
        description: !!response.caseDescription,
        availability: response.contactAvailability,
        urgency: response.urgencyDetermination
      }
    });
  } catch (err) {
    console.error("[Triage Node] Erro LLM:", err);
    return {
      currentNode: "sync_node",
      messages: [new AIMessage("Desculpe, tive um probleminha técnico. Pode repetir o que disse?")]
    };
  }

  const updatedTriage: TriageData = { ...triage };
  let finalReplyMessage = response.replyMessage;
  let validationError = "";

  // 1. Extração de múltiplos campos
  if (response.name && !updatedTriage.name) {
    if (isFullName(response.name)) updatedTriage.name = response.name.trim();
  }
  if (response.cpf && !updatedTriage.cpf) {
    const cleanCPF = response.cpf.replace(/\D/g, "");
    if (cleanCPF.length === 11) updatedTriage.cpf = cleanCPF;
  }
  if (response.caseType && !updatedTriage.caseType) {
    if (isValidCaseType(response.caseType)) updatedTriage.caseType = response.caseType;
  }
  if (response.caseDescription && !updatedTriage.caseDescription) {
    updatedTriage.caseDescription = response.caseDescription.trim();
  }
  if (response.contactAvailability && !updatedTriage.contactAvailability) {
    if (isValidAvailability(response.contactAvailability)) {
      updatedTriage.contactAvailability = response.contactAvailability;
    }
  }
  if (response.urgencyDetermination && !updatedTriage.urgency) {
    if (isValidUrgency(response.urgencyDetermination)) {
      updatedTriage.urgency = response.urgencyDetermination;
    }
  }

  // 2. Lógica de Validação e Avanço de Step
  // Se o usuário forneceu o dado do step atual ou ele já estava preenchido, tentamos avançar
  const currentDataMap: Record<string, any> = {
    NAME: updatedTriage.name && isFullName(updatedTriage.name),
    CPF: updatedTriage.cpf,
    CASE_TYPE: updatedTriage.caseType,
    DESCRIPTION: updatedTriage.caseDescription,
    URGENCY: updatedTriage.urgency,
    AVAILABILITY: updatedTriage.contactAvailability,
  };

  if ((step as string) !== "DONE" && (currentDataMap as any)[step]) {
    // Especial para CPF: se acabamos de preencher, verifica no backend
    if (step === "CPF") {
      try {
        const checkCpf = await checkUserByCpf(updatedTriage.cpf!);
        if (checkCpf.exists) {
          return {
            ...state,
            messages: [...state.messages, new AIMessage(`Entendi. Notei aqui no sistema que você já possui um cadastro conosco sob o nome ${checkCpf.name}! ⚖️\n\nComo você já é nosso cliente, vou avisar um de nossos advogados para te atender pessoalmente se necessário. Enquanto isso, posso te ajudar com alguma dúvida?`)],
            triage: { ...updatedTriage, currentStep: "DONE" },
            currentNode: "sync_node"
          };
        }
      } catch (err) { console.error("[Triage Node] Erro check CPF:", err); }
    }

    // Avança para o próximo step que não esteja preenchido
    let nextStepIdx: TriageStep = step;
    while (nextStepIdx !== "DONE" && (currentDataMap as any)[nextStepIdx]) {
      nextStepIdx = nextStep(nextStepIdx);
    }
    updatedTriage.currentStep = nextStepIdx;

    // Se pulamos passos, a resposta da IA deve refletir o novo step
    // Nota: O LLM já foi instruído a gerar o replyMessage correto baseado nos dados que ele extraiu.

    // Se chegamos no DONE agora, cria o lead
    if ((updatedTriage.currentStep as string) === "DONE") {
      try {
        const leadId = await createLead(updatedTriage, whatsappNumber);
        return { 
          triage: updatedTriage, 
          leadId, 
          currentNode: "sync_node", 
          messages: [new AIMessage(finalReplyMessage)] 
        };
      } catch (err) { 
        console.error("[Triage Node] Erro lead auto-complete:", err);
      }
    }
  } else if (step === "NAME" && updatedTriage.name && !isFullName(updatedTriage.name)) {
    // Caso especial: nome incompleto
    finalReplyMessage = "Para que possamos registrar certinho, você poderia me dizer seu sobrenome também?";
  }

  return { triage: updatedTriage, currentNode: "sync_node", messages: [new AIMessage(finalReplyMessage)] };
}
