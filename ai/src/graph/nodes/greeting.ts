import { AIMessage } from "@langchain/core/messages";
import { ThemisStateType } from "../state.js";

export async function greetingNode(
  state: ThemisStateType
): Promise<Partial<ThemisStateType>> {
  const { triage } = state;
  const isDone = triage.currentStep === "DONE";

  const message = isDone 
    ? "Olá! Que bom ter você de volta! Eu sou a Themis AI, do escritório Themis. Como posso ajudá-lo hoje? Se você tiver alguma dúvida jurídica, estou à disposição!" 
    : "Olá! Eu sou a Themis AI, do escritório Themis. Como posso ajudá-lo hoje? Se você tiver alguma dúvida jurídica, estou à disposição!";

  return {
    currentNode: "sync_node",
    messages: [new AIMessage(message)],
  };
}
