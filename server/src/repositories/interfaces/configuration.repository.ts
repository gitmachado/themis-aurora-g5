import type { Configuration } from '@models';

export interface IConfigurationRepository {
  findFirst(): Promise<Configuration | null>;
}
