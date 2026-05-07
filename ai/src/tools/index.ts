import { handoffTool } from "./handoff.js";
import { processStatusTool } from "./process.js";
import { leadTriageTool } from "./triage.js";
import { StructuredToolInterface } from "@langchain/core/tools";

export const tools: StructuredToolInterface[] = [
  handoffTool, 
  processStatusTool, 
  leadTriageTool,
];

export const toolsByName: Record<string, StructuredToolInterface> = {
  ativar_atendimento_humano: handoffTool,
  consultar_processos: processStatusTool,
  registrar_triagem: leadTriageTool,
};

export { handoffTool, processStatusTool, leadTriageTool };
