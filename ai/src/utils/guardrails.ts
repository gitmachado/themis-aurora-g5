/**
 * TODO: Chamar containsPromptInjection() no webhook quando 
 * T19 (whatsapp.ts) for implementada — ANTES de enviar ao grafo.
 * Se retornar true → responder com DEFAULT_GUARDRAIL_RESPONSE 
 * e logar a tentativa.
 */

/**
 * Padrões de mensagens que indicam tentativa de Prompt Injection.
 */
const INJECTION_PATTERNS = [
  /ignore (all |todas )?(as )?instruc/i,
  /forget (your|all) (rules|instructions)/i,
  /you are now/i,
  /desconsidere/i,
  /novo papel/i,
  /aja como/i,
  /finja (que|ser)/i,
  /system prompt/i,
  /ignore o prompt/i,
];

/**
 * Resposta padrão segura quando um injection é detectado.
 */
export const DEFAULT_GUARDRAIL_RESPONSE = `Desculpe, não entendi sua mensagem. Posso ajudar com:
• Consultar status do seu processo
• Tirar dúvidas jurídicas
• Falar com um advogado`;

/**
 * Verifica se a mensagem contém padrões de Prompt Injection.
 * 
 * @param message - A mensagem enviada pelo usuário.
 * @returns true se for detectada uma tentativa de injection, false caso contrário.
 */
export function containsPromptInjection(message: string): boolean {
  const hasInjection = INJECTION_PATTERNS.some(pattern => pattern.test(message));
  
  if (hasInjection) {
    // Logamos a tentativa para monitoramento de segurança
    console.warn(`[SECURITY][GUARDRAIL] Tentativa de Prompt Injection detectada: "${message}"`);
  }
  
  return hasInjection;
}
