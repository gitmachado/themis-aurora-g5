import type { User } from '@models';
import type { CreateUserDTO, UpdateUserDTO } from '@dtos';

export interface IUserService {
  create(dto: CreateUserDTO): Promise<User>;
  getById(id: string): Promise<User | null>;
  getByEmail(email: string): Promise<User | null>;
  getByWhatsapp(whatsapp: string): Promise<User | null>;
  getClientsByLawyerId(lawyerId: string): Promise<User[]>;
  getClientByLawyerId(lawyerId: string, clientId: string): Promise<User | null>;
  update(id: string, dto: UpdateUserDTO): Promise<User>;
  delete(id: string): Promise<void>;
}
