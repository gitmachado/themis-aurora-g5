import fs from 'fs';
import path from 'path';
import { IStorageProvider, SaveFileOptions, StorageFile } from '../storage.provider';

export class LocalFileStorageProvider implements IStorageProvider {
  private readonly uploadDir: string;

  constructor() {
    this.uploadDir = path.resolve(__dirname, '../../../../uploads');
    if (!fs.existsSync(this.uploadDir)) {
      fs.mkdirSync(this.uploadDir, { recursive: true });
    }
  }

  async saveFile(
    file: StorageFile,
    _options?: SaveFileOptions
  ): Promise<string> {
    const filename = `${Date.now()}-${file.originalname.replace(/\s/g, '_')}`;
    const filePath = path.join(this.uploadDir, filename);

    await fs.promises.rename(file.path, filePath);

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
