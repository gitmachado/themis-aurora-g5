import { Request, Response, NextFunction } from 'express';
import { AuthService } from '@services';
import { UserRepository } from '@repositories';
import { z } from 'zod';

export class AuthController {
  private authService: AuthService;

  constructor() {
    // In a real app, use Dependency Injection. Here we instantiate for simplicity.
    const userRepository = new UserRepository();
    this.authService = new AuthService(userRepository);
  }

  login = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await this.authService.login(req.body);
      return res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  };

  register = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await this.authService.register(req.body);
      return res.status(201).json(result);
    } catch (error) {
      next(error);
    }
  };
}
