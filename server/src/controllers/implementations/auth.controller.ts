import { Response, NextFunction, RequestHandler } from 'express';
import { IAuthService } from '@services';
import { LoginDTO, RegisterDTO, AuthResponseDTO } from '@dtos';
import { AuthRequest } from '../../middlewares/implementations/authMiddleware';

export class AuthController {
  constructor(private readonly authService: IAuthService) {}

  login: RequestHandler<any, AuthResponseDTO, LoginDTO> = async (
    req: AuthRequest<any, AuthResponseDTO, LoginDTO>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const result = await this.authService.login(req.body);
      return res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  };

  register: RequestHandler<any, AuthResponseDTO, RegisterDTO> = async (
    req: AuthRequest<any, AuthResponseDTO, RegisterDTO>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const result = await this.authService.register(req.body);
      return res.status(201).json(result);
    } catch (error) {
      next(error);
    }
  };

  googleSignIn: RequestHandler<any, AuthResponseDTO, { idToken: string }> = async (
    req: AuthRequest<any, AuthResponseDTO, { idToken: string }>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const { idToken } = req.body;
      if (!idToken) {
        return res.status(400).json({ error: 'idToken is required' } as any);
      }
      const result = await this.authService.googleSignIn(idToken);
      return res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  };
}
