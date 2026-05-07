/**
 * Guardrails de segurança contra Prompt Injection.
 * Integrado no webhook (whatsapp.ts) ANTES de enviar ao grafo.
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
 */
export function containsPromptInjection(message: string): boolean {
  const hasInjection = INJECTION_PATTERNS.some(pattern => pattern.test(message));
  
  if (hasInjection) {
    console.warn(`[SECURITY][GUARDRAIL] Tentativa de Prompt Injection detectada: "${message}"`);
  }
  
  return hasInjection;
}
