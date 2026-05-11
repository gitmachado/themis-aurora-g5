import { getBotConfig as fetchBotConfig } from '../utils/backend-client.js';

export type BotConfig = {
  toneOfVoice: string;
};

const DEFAULT_CONFIG: BotConfig = {
  toneOfVoice: "Profissional e acolhedor"
};

let cachedConfig: BotConfig | null = null;

export async function getBotConfig(): Promise<BotConfig> {
  if (cachedConfig) {
    return cachedConfig;
  }

  try {
    const data = await fetchBotConfig();
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
