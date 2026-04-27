import axios from 'axios';

// Variáveis de ambiente simuladas (deverão vir do process.env no projeto real)
const BACKEND_API_URL = process.env.BACKEND_API_URL || 'http://localhost:3000';
const BOT_API_KEY = process.env.BOT_API_KEY || 'default_bot_key';

export type BotConfig = {
  toneOfVoice: string;
  serviceHoursStart: string;
  serviceHoursEnd: string;
  awayMessage: string;
};

const DEFAULT_CONFIG: BotConfig = {
  toneOfVoice: "Profissional e acolhedor",
  serviceHoursStart: "09:00",
  serviceHoursEnd: "18:00",
  awayMessage: "Nosso horário de atendimento é de seg a sex, 9h às 18h."
};

let cachedConfig: BotConfig | null = null;

export async function getBotConfig(): Promise<BotConfig> {
  if (cachedConfig) {
    return cachedConfig;
  }

  try {
    const response = await axios.get(
      `${BACKEND_API_URL}/api/v1/configurations`,
      { headers: { "x-api-key": BOT_API_KEY } }
    );
    
    const data = response.data;
    cachedConfig = data;
    
    // Limpa o cache após 5 minutos
    setTimeout(() => {
      cachedConfig = null;
    }, 5 * 60 * 1000);

    return data;
  } catch (error) {
    console.error("Erro ao buscar configurações do bot. Usando default:", error);
    return DEFAULT_CONFIG;
  }
}
