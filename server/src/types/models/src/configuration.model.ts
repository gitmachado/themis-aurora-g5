export interface Configuration {
  id: string;
  aiToneOfVoice: string | null;
  serviceHoursStart: string | null; // ex: "09:00"
  serviceHoursEnd: string | null;   // ex: "18:00"
  awayMessage: string | null;
  createdAt: Date;
  updatedAt: Date;
}
