import { LocalFileStorageProvider } from './implementations/local-storage.provider';
import { IStorageProvider } from './storage.provider';

export function createStorageProvider(): IStorageProvider {
  return new LocalFileStorageProvider();
}
