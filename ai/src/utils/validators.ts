export const CASE_TYPES = [
  "Trabalhista",
  "Cível",
  "Civil",
  "Família",
  "Criminal",
  "Previdenciário",
  "Herança",
  "Inventário",
] as const;

export const URGENCY_LEVELS = ["Alta", "Média", "Baixa"] as const;

export const AVAILABILITY = ["Manhã", "Tarde", "Noite"] as const;

export function isValidCPF(cpf: string): boolean {
  const cleaned = cpf.replace(/[.\-]/g, "");

  if (cleaned.length !== 11) return false;
  if (/^(\d)\1{10}$/.test(cleaned)) return false;

  const calcDigit = (slice: string, factor: number): number => {
    const sum = slice
      .split("")
      .reduce((acc, digit, i) => acc + parseInt(digit) * (factor - i), 0);
    const remainder = sum % 11;
    return remainder < 2 ? 0 : 11 - remainder;
  };

  const first = calcDigit(cleaned.slice(0, 9), 10);
  if (first !== parseInt(cleaned[9])) return false;

  const second = calcDigit(cleaned.slice(0, 10), 11);
  return second === parseInt(cleaned[10]);
}

function normalizeText(text: string): string {
  return text
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .trim();
}

export function isValidCaseType(input: string): boolean {
  const normalized = normalizeText(input);
  return CASE_TYPES.some((type) => normalizeText(type) === normalized);
}

export function isValidUrgency(input: string): boolean {
  const normalized = normalizeText(input);
  return URGENCY_LEVELS.some((level) => normalizeText(level) === normalized);
}

export function isValidAvailability(input: string): boolean {
  const normalized = normalizeText(input);
  return AVAILABILITY.some((slot) => normalizeText(slot) === normalized);
}
