import { IConfigurationService } from '../interfaces/configuration.service';
import { IConfigurationRepository } from '../../repositories/interfaces/configuration.repository';
import type { Configuration } from '@models';

export class ConfigurationService implements IConfigurationService {
  constructor(private readonly configurationRepository: IConfigurationRepository) {}

  async getConfiguration(): Promise<Configuration | null> {
    return this.configurationRepository.findFirst();
  }
}
