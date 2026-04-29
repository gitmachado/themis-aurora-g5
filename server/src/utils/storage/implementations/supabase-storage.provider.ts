import fs from 'fs';
import path from 'path';
import crypto from 'crypto';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import {
  getSupabaseServiceRoleKey,
  getSupabaseStorageBucket,
  getSupabaseStorageSignedUrlExpiresIn,
  getSupabaseUrl,
} from '../../../config/runtime';
import { ValidationError } from '../../../services/implementations/errors';
import { IStorageProvider, SaveFileOptions, StorageFile } from '../storage.provider';

export class SupabaseStorageProvider implements IStorageProvider {
  private readonly bucket = getSupabaseStorageBucket();
  private readonly signedUrlExpiresIn = getSupabaseStorageSignedUrlExpiresIn();
  private readonly client: SupabaseClient;

  constructor() {
    const url = getSupabaseUrl();
    const serviceRoleKey = getSupabaseServiceRoleKey();

    if (!url || !serviceRoleKey) {
      throw new ValidationError(
        'SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY sao obrigatorios para Supabase Storage'
      );
    }

    this.client = createClient(url, serviceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
  }

  async saveFile(
    file: StorageFile,
    options?: SaveFileOptions
  ): Promise<string> {
    const objectPath = this.buildObjectPath(file.originalname, options?.folder);
    const buffer = await fs.promises.readFile(file.path);

    try {
      const { error } = await this.client.storage
        .from(this.bucket)
        .upload(objectPath, buffer, {
          contentType: file.mimetype,
          cacheControl: '3600',
          upsert: false,
        });

      if (error) {
        throw new ValidationError(
          `Nao foi possivel enviar arquivo ao Supabase Storage: ${error.message}`
        );
      }

      return objectPath;
    } finally {
      await fs.promises.unlink(file.path).catch(() => undefined);
    }
  }

  async deleteFile(fileUrl: string): Promise<void> {
    const objectPath = this.normalizeObjectPath(fileUrl);
    if (!objectPath) return;

    const { error } = await this.client.storage
      .from(this.bucket)
      .remove([objectPath]);

    if (error) {
      throw new ValidationError(
        `Nao foi possivel remover arquivo do Supabase Storage: ${error.message}`
      );
    }
  }

  async getAccessUrl(fileUrl: string): Promise<string> {
    const objectPath = this.normalizeObjectPath(fileUrl);
    if (!objectPath) {
      throw new ValidationError('Referencia de arquivo invalida');
    }

    const { data, error } = await this.client.storage
      .from(this.bucket)
      .createSignedUrl(objectPath, this.signedUrlExpiresIn);

    if (error || !data?.signedUrl) {
      throw new ValidationError(
        `Nao foi possivel gerar URL assinada: ${error?.message || 'sem URL'}`
      );
    }

    return data.signedUrl;
  }

  private buildObjectPath(originalName: string, folder?: string): string {
    const safeFolder = this.sanitizeFolder(folder || 'documents');
    const safeName = this.sanitizeFileName(originalName);
    const extension = path.extname(safeName);
    const basename = path.basename(safeName, extension);
    const uniqueSuffix = `${Date.now()}-${crypto.randomUUID()}`;

    return `${safeFolder}/${basename}-${uniqueSuffix}${extension}`.replace(
      /\/+/g,
      '/'
    );
  }

  private sanitizeFolder(folder: string): string {
    return folder
      .split(/[\\/]/)
      .map((part) => this.sanitizePathPart(part))
      .filter(Boolean)
      .join('/');
  }

  private sanitizeFileName(fileName: string): string {
    const parsed = path.parse(fileName);
    const name = this.sanitizePathPart(parsed.name) || 'arquivo';
    const extension = this.sanitizePathPart(parsed.ext.replace(/^\./, ''));
    return extension ? `${name}.${extension}` : name;
  }

  private sanitizePathPart(part: string): string {
    return part
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/[^a-zA-Z0-9._-]/g, '-')
      .replace(/-+/g, '-')
      .replace(/^[-.]+|[-.]+$/g, '')
      .toLowerCase();
  }

  private normalizeObjectPath(fileUrl: string): string | null {
    if (!fileUrl || fileUrl.startsWith('/uploads/')) {
      return null;
    }

    const supabasePrefix = `supabase://${this.bucket}/`;
    if (fileUrl.startsWith(supabasePrefix)) {
      return fileUrl.slice(supabasePrefix.length);
    }

    if (fileUrl.startsWith('http://') || fileUrl.startsWith('https://')) {
      const marker = `/object/sign/${this.bucket}/`;
      const index = fileUrl.indexOf(marker);
      if (index >= 0) {
        return decodeURIComponent(
          fileUrl.slice(index + marker.length).split('?')[0]
        );
      }
    }

    return fileUrl.replace(/^\/+/, '');
  }
}
