export interface SaveFileOptions {
  folder?: string;
}

export interface StorageFile {
  originalname: string;
  mimetype: string;
  path: string;
  size: number;
}

export interface IStorageProvider {
  /**
   * Saves a file and returns a retrievable storage reference.
   */
  saveFile(
    file: StorageFile,
    options?: SaveFileOptions
  ): Promise<string>;

  /**
   * Deletes a file by its storage reference.
   */
  deleteFile(fileUrl: string): Promise<void>;

  /**
   * Returns a temporary URL that can be opened outside the mobile app.
   */
  getAccessUrl(fileUrl: string): Promise<string>;
}
