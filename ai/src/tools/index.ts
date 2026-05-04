import { handoffTool } from "./handoff.js";
import { processStatusTool } from "./process.js";
import { leadTriageTool } from "./triage.js";

export const tools = [
  handoffTool, 
  processStatusTool, 
  leadTriageTool
];

export const toolsByName: Record<string, any> = {
  ativar_atendimento_humano: handoffTool,
  consultar_processos: processStatusTool,
  registrar_triagem: leadTriageTool,
};

export { 
  handoffTool, 
  processStatusTool, 
  leadTriageTool 
};
