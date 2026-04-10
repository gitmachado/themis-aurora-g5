export interface Configuracao {
  id: string;
  tomDeVozIA: string | null;
  horarioInicioAtendimento: string | null; // ex: "09:00"
  horarioFimAtendimento: string | null;    // ex: "18:00"
  mensagemAusencia: string | null;
  createdAt: Date;
  updatedAt: Date;
}
