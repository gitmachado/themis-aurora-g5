import { handoffTool } from "./handoff.js";
import { processStatusTool } from "./process.js";
import { leadTriageTool } from "./triage.js";
import { knowledgeSearchTool } from "./knowledge.js";
import { appointmentTool } from "./appointment.js";
import { StructuredToolInterface } from "@langchain/core/tools";

export const tools: StructuredToolInterface[] = [
  handoffTool,
  processStatusTool,
  leadTriageTool,
  knowledgeSearchTool,
  appointmentTool,
];

export const toolsByName: Record<string, StructuredToolInterface> = {
  ativar_atendimento_humano: handoffTool,
  consultar_processos: processStatusTool,
  registrar_triagem: leadTriageTool,
  pesquisar_conhecimento: knowledgeSearchTool,
  agendar_compromisso: appointmentTool,
};

export { handoffTool, processStatusTool, leadTriageTool, knowledgeSearchTool, appointmentTool };
