export interface LoginDTO {
  whatsappNumber: string;
  password: string;
}

export interface RegisterDTO {
  name: string;
  whatsappNumber: string;
  cpf: string;
  password: string;
}

export interface AuthResponseDTO {
  token: string;
  userId: string;
  role: string;
}
