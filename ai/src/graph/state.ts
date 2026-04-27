import { Annotation } from "@langchain/langgraph";
import { BaseMessage } from "@langchain/core/messages";
import { BotConfig } from "../tools/config-loader.js";

// Enum de steps da triagem (ordem do fluxo conversacional)
export type TriageStep =
  | "NAME"
  | "CPF"
  | "CASE_TYPE"
  | "DESCRIPTION"
  | "URGENCY"
  | "AVAILABILITY"
  | "DONE";

// Dados coletados sequencialmente durante a triagem
export type TriageData = {
  name: string | null;
  cpf: string | null;
  caseType: string | null;
  caseDescription: string | null;
  urgency: string | null;
  contactAvailability: string | null;
  currentStep: TriageStep;
};

// Valores padrão para inicialização do state
export const INITIAL_TRIAGE: TriageData = {
  name: null,
  cpf: null,
  caseType: null,
  caseDescription: null,
  urgency: null,
  contactAvailability: null,
  currentStep: "NAME",
};

export const INITIAL_CONFIG: BotConfig = {
  toneOfVoice: "formal",
  serviceHoursStart: "09:00",
  serviceHoursEnd: "18:00",
  awayMessage: "Estamos fora do horário de atendimento. Retornaremos em breve.",
};

// State principal do LangGraph — "fonte da verdade" de cada conversa
export const OmniState = Annotation.Root({
  // Identidade da conversa
  whatsappNumber: Annotation<string>,
  userType: Annotation<"UNKNOWN" | "LEAD" | "CLIENT">,
  userId: Annotation<string | null>,   // UUID do users (se já é cliente)
  leadId: Annotation<string | null>,   // UUID do leads (se está em triagem)

  // Histórico de mensagens com reducer de append (nunca sobrescreve)
  messages: Annotation<BaseMessage[]>({
    reducer: (a, b) => a.concat(b),
    default: () => [],
  }),

  // Dados coletados na triagem
  triage: Annotation<TriageData>,

  // Controle de fluxo
  currentNode: Annotation<string>,
  needsHandoff: Annotation<boolean>,
  handoffReason: Annotation<string | null>,

  // Configuração do escritório (carregada 1x via config-loader)
  config: Annotation<BotConfig>,
});

// Tipo inferido — importar nos nós como: import { OmniStateType } from "../state.js"
export type OmniStateType = typeof OmniState.State;
