import fs from 'fs';
import path from 'path';
import { IStorageProvider, SaveFileOptions, StorageFile } from '../storage.provider';
import { ensureDirectory, getUploadDir } from '../storage-paths';

export class LocalFileStorageProvider implements IStorageProvider {
  private readonly uploadDir: string;

  constructor() {
    this.uploadDir = ensureDirectory(getUploadDir());
  }

  async saveFile(
    file: StorageFile,
    _options?: SaveFileOptions
  ): Promise<string> {
    const filename = `${Date.now()}-${file.originalname.replace(/\s/g, '_')}`;
    const filePath = path.join(this.uploadDir, filename);

    try {
      await fs.promises.rename(file.path, filePath);
    } catch (err: any) {
      if (err.code === 'EXDEV') {
        await fs.promises.copyFile(file.path, filePath);
        await fs.promises.unlink(file.path).catch(() => undefined);
      } else {
        throw err;
      }
    }

    // Returning relative path or URL - in a real app, this would be a URL
    return `/uploads/${filename}`;
  }

  async deleteFile(fileUrl: string): Promise<void> {
    const filename = fileUrl.split('/').pop();
    if (!filename) return;

    const filePath = path.join(this.uploadDir, filename);

    if (fs.existsSync(filePath)) {
      await fs.promises.unlink(filePath);
    }
  }

  async getAccessUrl(fileUrl: string): Promise<string> {
    return fileUrl;
  }
}
