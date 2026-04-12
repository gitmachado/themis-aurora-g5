export interface IStorageProvider {
  /**
   * Saves a file and returns its public URL or local path
   */
  saveFile(file: Express.Multer.File): Promise<string>;
  
  /**
   * Deletes a file by its URL or path
   */
  deleteFile(fileUrl: string): Promise<void>;
}
