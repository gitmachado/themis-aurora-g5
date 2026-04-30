import fs from 'fs';
import path from 'path';

const serverRoot = path.resolve(__dirname, '../../..');

export function ensureDirectory(directoryPath: string): string {
  if (!fs.existsSync(directoryPath)) {
    fs.mkdirSync(directoryPath, { recursive: true });
  }

  return directoryPath;
}

export function getUploadDir(): string {
  return path.join(serverRoot, 'uploads');
}

export function getTempDir(): string {
  return path.join(serverRoot, 'temp');
}

export function resolveUploadFilePath(filename: string): string {
  return path.join(getUploadDir(), filename);
}
