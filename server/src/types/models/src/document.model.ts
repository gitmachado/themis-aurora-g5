export interface Document {
  id: string;
  legalProcessId: string;
  fileName: string;
  fileUrl: string;
  sizeBytes: number | null;
  mimeType: string | null;
  sentById: string;
  createdAt: Date;
  updatedAt: Date;
}
