import { ChatOpenAI } from "@langchain/openai";
import { AIMessage } from "@langchain/core/messages";
import axios from "axios";
import { OmniStateType, TriageData, TriageStep } from "../state.js";
import { SYSTEM_PROMPT, TRIAGE_PROMPT } from "../../config/prompts.js";
import {
  isValidCPF,
  isValidCaseType,
  isValidUrgency,
  isValidAvailability,
} from "../../utils/validators.js";

const BACKEND_API_URL = process.env.BACKEND_API_URL || "http://localhost:3000";
const BOT_API_KEY = process.env.BOT_API_KEY || "";

// Mapeamento PT → EN para os enums do backend
const CASE_TYPE_MAP: Record<string, string> = {
  trabalhista: "Labor",
  civel: "Civil",
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

function normalize(s: string): string {
  return s.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
}

function mapToEnglish(pt: string, map: Record<string, string>): string {
  return map[normalize(pt)] ?? pt;
}

function nextStep(step: TriageStep): TriageStep {
  const order: TriageStep[] = [
    "NAME", "CPF", "CASE_TYPE", "DESCRIPTION", "URGENCY", "AVAILABILITY", "DONE",
  ];
  const idx = order.indexOf(step);
  return order[Math.min(idx + 1, order.length - 1)];
}

async function createLead(triage: TriageData, whatsappNumber: string): Promise<string> {
  const res = await axios.post(
    `${BACKEND_API_URL}/api/v1/leads`,
    {
      name: triage.name,
      whatsappNumber,
      cpf: triage.cpf?.replace(/\D/g, ""),
      caseType: mapToEnglish(triage.caseType!, CASE_TYPE_MAP),
      caseDescription: triage.caseDescription,
      urgency: mapToEnglish(triage.urgency!, URGENCY_MAP),
      contactAvailability: mapToEnglish(triage.contactAvailability!, AVAILABILITY_MAP),
    },
    { headers: { "x-api-key": BOT_API_KEY } }
  );
  return res.data.id;
}

export async function triageNode(
  state: OmniStateType
): Promise<Partial<OmniStateType>> {
  const { whatsappNumber, messages, triage } = state;
  const userInput = String(messages.at(-1)?.content ?? "").trim();
  const step = triage.currentStep;

  // DONE: cria o lead no backend
  if (step === "DONE") {
    try {
      const leadId = await createLead(triage, whatsappNumber);
      return {
        leadId,
        currentNode: "sync",
        messages: [
          new AIMessage(
            `✅ Informações registradas! Um advogado entrará em contato no período da ${triage.contactAvailability}.`
          ),
        ],
      };
    } catch (err) {
      console.error("[Triage Node] Erro ao criar lead:", err);
      return {
        currentNode: "sync",
        messages: [
          new AIMessage("Houve um erro ao registrar suas informações. Por favor, tente novamente."),
        ],
      };
    }
  }

  // Valida o input do step atual e avança se válido
  let errorMsg: string | null = null;
  const updatedTriage: TriageData = { ...triage };

  if (step === "NAME") {
    if (userInput.length >= 3) {
      updatedTriage.name = userInput;
      updatedTriage.currentStep = nextStep(step);
    } else {
      errorMsg = "Preciso do seu nome completo (mínimo 3 caracteres).";
    }
  } else if (step === "CPF") {
    if (isValidCPF(userInput)) {
      updatedTriage.cpf = userInput.replace(/\D/g, "");
      updatedTriage.currentStep = nextStep(step);
    } else {
      errorMsg = "CPF inválido. Por favor, digite novamente (somente números).";
    }
  } else if (step === "CASE_TYPE") {
    if (isValidCaseType(userInput)) {
      updatedTriage.caseType = userInput;
      updatedTriage.currentStep = nextStep(step);
    } else {
      errorMsg = "Tipo inválido. Escolha: Trabalhista, Cível, Família, Criminal ou Previdenciário.";
    }
  } else if (step === "DESCRIPTION") {
    if (userInput.length >= 10) {
      updatedTriage.caseDescription = userInput;
      updatedTriage.currentStep = nextStep(step);
    } else {
      errorMsg = "Descrição muito curta. Por favor, detalhe um pouco mais sua situação.";
    }
  } else if (step === "URGENCY") {
    if (isValidUrgency(userInput)) {
      updatedTriage.urgency = userInput;
      updatedTriage.currentStep = nextStep(step);
    } else {
      errorMsg = "Urgência inválida. Escolha: Alta, Média ou Baixa.";
    }
  } else if (step === "AVAILABILITY") {
    if (isValidAvailability(userInput)) {
      updatedTriage.contactAvailability = userInput;
      updatedTriage.currentStep = "DONE";
    } else {
      errorMsg = "Disponibilidade inválida. Escolha: Manhã, Tarde ou Noite.";
    }
  }

  // Input inválido: retorna erro sem avançar o step
  if (errorMsg) {
    return {
      triage: updatedTriage,
      currentNode: "triage",
      messages: [new AIMessage(errorMsg)],
    };
  }

  // Gera a pergunta do próximo step via LLM
  const model = new ChatOpenAI({
    modelName: process.env.OPENAI_MODEL || "gpt-4o-mini",
    temperature: 0.3,
  });

  const prompt = TRIAGE_PROMPT
    .replace("{currentStep}", updatedTriage.currentStep)
    .replace("{triageData}", JSON.stringify({
      nome: updatedTriage.name,
      cpf: updatedTriage.cpf ? "***" : null,
      tipoCaso: updatedTriage.caseType,
      descricao: updatedTriage.caseDescription,
      urgencia: updatedTriage.urgency,
      disponibilidade: updatedTriage.contactAvailability,
    }));

  const response = await model.invoke([
    { role: "system", content: `${SYSTEM_PROMPT}\n\n${prompt}` },
  ]);

  return {
    triage: updatedTriage,
    currentNode: "triage",
    messages: [new AIMessage(String(response.content))],
  };
}
