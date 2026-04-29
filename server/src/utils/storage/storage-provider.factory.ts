import {
  getSupabaseServiceRoleKey,
  getSupabaseUrl,
  isProduction,
} from '../../config/runtime';
import { LocalFileStorageProvider } from './implementations/local-storage.provider';
import { SupabaseStorageProvider } from './implementations/supabase-storage.provider';
import { IStorageProvider } from './storage.provider';

export function createStorageProvider(): IStorageProvider {
  if (getSupabaseUrl() && getSupabaseServiceRoleKey()) {
    console.log('Storage provider: Supabase Storage');
    return new SupabaseStorageProvider();
  }

  if (isProduction()) {
    throw new Error(
      'SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY sao obrigatorios para storage em producao'
    );
  }

  console.warn(
    'Storage provider: local filesystem. Configure SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY to use Supabase Storage.'
  );
  return new LocalFileStorageProvider();
}
