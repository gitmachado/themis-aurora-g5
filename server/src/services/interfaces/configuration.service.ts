import type { Configuration } from '@models';

export interface IConfigurationService {
  getConfiguration(): Promise<Configuration | null>;
}
