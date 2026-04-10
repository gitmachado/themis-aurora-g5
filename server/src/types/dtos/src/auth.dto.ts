export interface LoginDTO {
  whatsappNumber: string;
  senha: string;
}

export interface RegisterDTO {
  nome: string;
  whatsappNumber: string;
  cpf: string;
  senha: string;
}

export interface AuthResponseDTO {
  token: string;
  userId: string;
  role: string;
}
