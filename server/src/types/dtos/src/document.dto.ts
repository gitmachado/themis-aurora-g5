export interface CreateDocumentDTO {
  legalProcessId: string;
  fileName: string;
  fileUrl: string;
  sizeBytes?: number;
  mimeType?: string;
  sentById: string;
}
