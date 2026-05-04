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
  serviceHoursEnd: "23:59",
  awayMessage: "Estamos fora do horário de atendimento. Retornaremos em breve.",
};

// State principal do LangGraph — "fonte da verdade" de cada conversa
export const ThemisState = Annotation.Root({
  // Identidade da conversa
  whatsappNumber: Annotation<string>,
  userType: Annotation<"UNKNOWN" | "LEAD" | "CLIENT">,
  userId: Annotation<string | null>,   // UUID do users (se já é cliente)
  leadId: Annotation<string | null>,   // UUID do leads (se está em triagem)

  // Histórico de mensagens com reducer de append inteligente
  messages: Annotation<BaseMessage[]>({
    reducer: (a, b) => {
      // Se b for uma única mensagem que já existe no fim de a, ignora
      if (b.length === 1 && a.length > 0) {
        const lastA = a[a.length - 1];
        const newB = b[0];
        if (lastA.content === newB.content && (lastA as any)._getType?.() === (newB as any)._getType?.()) {
          return a;
        }
      }
      return a.concat(b);
    },
    default: () => [],
  }),

  // Dados coletados na triagem
  triage: Annotation<TriageData>,

  // Controle de fluxo
  currentNode: Annotation<string>,
  needsHandoff: Annotation<boolean>({
    reducer: (a, b) => (b !== undefined ? b : a),
    default: () => false,
  }),
  handoffReason: Annotation<string | null>({
    reducer: (a, b) => b,
    default: () => null,
  }),
  interactionContext: Annotation<string | null>({
    reducer: (a, b) => b,
    default: () => null,
  }),

  // Configuração do escritório (carregada 1x via config-loader)
  config: Annotation<BotConfig>({
    reducer: (a, b) => b,
    default: () => INITIAL_CONFIG,
  }),
});

// Tipo inferido — importar nos nós como: import { ThemisStateType } from "../state.js"
export type ThemisStateType = typeof ThemisState.State;
