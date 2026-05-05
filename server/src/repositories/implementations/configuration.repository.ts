import { IConfigurationRepository } from '../interfaces/configuration.repository';
import type { Configuration } from '@models';
import { dbGet } from '../../config/database';

export class ConfigurationRepository implements IConfigurationRepository {
  private readonly selectFields = `
    id,
    ai_tone_of_voice as "aiToneOfVoice",
    service_hours_start as "serviceHoursStart",
    service_hours_end as "serviceHoursEnd",
    away_message as "awayMessage",
    created_at as "createdAt",
    updated_at as "updatedAt"
  `;

  async findFirst(): Promise<Configuration | null> {
    return dbGet<Configuration>(`SELECT ${this.selectFields} FROM configurations LIMIT 1`);
  }
}
