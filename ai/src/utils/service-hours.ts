/**
 * Verifica se um horário específico (currentTime) está dentro da 
 * janela de atendimento, considerando o fuso horário de São Paulo (UTC-3).
 * 
 * @param currentTime A data e hora atual a ser verificada
 * @param startHour O horário de início do atendimento (ex: "09:00")
 * @param endHour O horário de fim do atendimento (ex: "18:00")
 * @returns boolean indicando se está dentro do horário de atendimento
 */
export function isWithinServiceHours(
  currentTime: Date,
  startHour: string,
  endHour: string
): boolean {
  // Utilizamos a API Intl do JS para garantir que a hora seja 
  // extraída baseada no fuso de São Paulo, indiferente de onde o servidor roda.
  const spTimeFormatter = new Intl.DateTimeFormat('pt-BR', {
    timeZone: 'America/Sao_Paulo',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  });

  // O formato retornado é "HH:MM"
  const spTimeString = spTimeFormatter.format(currentTime);
  const [spHour, spMinute] = spTimeString.split(':').map(Number);
  const nowInMinutes = spHour * 60 + spMinute;

  const [startH, startM] = startHour.split(':').map(Number);
  const [endH, endM] = endHour.split(':').map(Number);

  const startInMinutes = startH * 60 + startM;
  const endInMinutes = endH * 60 + endM;

  return nowInMinutes >= startInMinutes && nowInMinutes <= endInMinutes;
}

// TODO: Chamar isWithinServiceHours() aqui quando T19 
// (whatsapp.ts) for implementada — ANTES de invocar o grafo.
// (Isso atenderá aos Itens 3 e 4 da Task G5-53)
