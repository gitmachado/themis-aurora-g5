export interface CreateDocumentoDTO {
  processoId: string;
  nomeArquivo: string;
  urlArquivo: string;
  tamanhoBytes?: number;
  tipoMime?: string;
  enviadoPorId: string;
}
