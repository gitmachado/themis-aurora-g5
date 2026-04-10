import type { User } from '@models';

export interface IUserRepository {
  findById(id: string): Promise<User | null>;
  findByWhatsapp(whatsappNumber: string): Promise<User | null>;
  findByCpf(cpf: string): Promise<User | null>;
  create(user: Omit<User, 'id' | 'createdAt' | 'updatedAt'>): Promise<User>;
  update(id: string, data: Partial<User>): Promise<User>;
  delete(id: string): Promise<void>;
}
