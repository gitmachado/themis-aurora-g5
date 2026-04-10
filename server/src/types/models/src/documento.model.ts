export interface Documento {
  id: string;
  processoId: string;
  nomeArquivo: string;
  urlArquivo: string;
  tamanhoBytes: number | null;
  tipoMime: string | null;
  enviadoPorId: string;
  createdAt: Date;
  updatedAt: Date;
}
