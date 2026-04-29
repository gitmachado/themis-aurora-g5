/**
 * Utilitário para validar se o tipo da mensagem recebida é suportado pelo sistema.
 * Atualmente, apenas mensagens de texto são processadas pelo grafo LangGraph.
 */

export interface ValidationResult {
  isValid: boolean;
  errorMessage?: string;
}

/**
 * Verifica se o tipo da mensagem é "TEXT".
 * @param type O tipo da mensagem (ex: "TEXT", "audio", "image")
 * @returns Um objeto contendo se é válido e a mensagem de erro se necessário.
 */
export function validateMessageType(type: string): ValidationResult {
  if (type.toUpperCase() !== "TEXT") {
    return {
      isValid: false,
      errorMessage: "Desculpe, no momento só consigo processar mensagens de texto. 📝\nPoderia descrever sua situação por escrito?",
    };
  }
  return { isValid: true };
}
