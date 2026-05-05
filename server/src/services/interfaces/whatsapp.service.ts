export interface IWhatsAppService {
  sendText(to: string, text: string): Promise<string>; // Returns whatsapp message id
}
