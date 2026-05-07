/**
 * Fonte única de verdade para mapeamentos PT → EN usados pelo backend.
 * Importar daqui em vez de duplicar em cada arquivo.
 */

export const CASE_TYPE_MAP: Record<string, string> = {
  trabalhista: "Labor",
  civel: "Civil",
  civil: "Civil",
  heranca: "Civil",
  inventario: "Civil",
  familia: "Family",
  criminal: "Criminal",
  previdenciario: "SocialSecurity",
};

export const URGENCY_MAP: Record<string, string> = {
  alta: "High",
  media: "Medium",
  baixa: "Low",
};

export const AVAILABILITY_MAP: Record<string, string> = {
  manha: "Morning",
  tarde: "Afternoon",
  noite: "Evening",
};

/**
 * Normaliza uma string removendo acentos e convertendo para lowercase.
 */
export function normalize(s: string | null | undefined): string {
  if (!s) return "";
  return s.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
}

/**
 * Mapeia um valor em português para seu equivalente em inglês.
 * Retorna o valor original se não encontrar no mapa.
 */
export function mapToEnglish(
  pt: string | null | undefined,
  map: Record<string, string>
): string {
  if (!pt) return "";
  return map[normalize(pt)] ?? pt;
}
