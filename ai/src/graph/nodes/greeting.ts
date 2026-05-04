import { AIMessage } from "@langchain/core/messages";
import { ThemisStateType } from "../state.js";

export async function greetingNode(
  state: ThemisStateType
): Promise<Partial<ThemisStateType>> {
  const { triage } = state;
  const isDone = triage.currentStep === "DONE";

  const message = isDone 
    ? "Olá! Sou a Themis AI. Que bom ter você de volta! 😊\nPosso te ajudar com alguma dúvida jurídica ou passar novas informações sobre seu caso para o advogado?" 
    : "Olá! Tudo bem? Sou a Themis AI, assistente virtual do Machado & Associados. ⚖️\n\nEstou aqui para agilizar seu atendimento. Para que eu possa encaminhar seu caso ao advogado especialista, preciso apenas de algumas informações básicas. Podemos começar?";

  return {
    currentNode: "sync_node",
    messages: [new AIMessage(message)],
  };
}
