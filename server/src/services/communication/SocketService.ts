import { Server as SocketIOServer, Socket } from 'socket.io';
import { Server as HTTPServer } from 'http';
import jwt from 'jsonwebtoken';
import { getJwtSecret } from '../../config/runtime';
import { eventBus } from './InternalEventBus';
import { UserRole } from '@enums';

interface JWTPayload {
  sub: string;
  role: UserRole;
}

// Anexamos identidade do usuario ao Socket sem cast `as any` repetido.
type AuthenticatedSocket = Socket & { userId?: string; userRole?: UserRole };

export class SocketService {
  private static instance: SocketService;
  private io: SocketIOServer | null = null;

  private constructor() {}

  public static getInstance(): SocketService {
    if (!SocketService.instance) {
      SocketService.instance = new SocketService();
    }
    return SocketService.instance;
  }

  public initialize(httpServer: HTTPServer): void {
    this.io = new SocketIOServer(httpServer, {
      cors: {
        origin: '*', // Adjust according to production needs
        methods: ['GET', 'POST'],
      },
    });

    // Authentication Middleware
    this.io.use((socket, next) => {
      const token = socket.handshake.auth?.token;

      if (!token) {
        return next(new Error('Authentication error: Token not provided'));
      }

      try {
        const secret = getJwtSecret();
        const decoded = jwt.verify(token, secret) as JWTPayload;
        
        // Attach user info to socket
        const authSocket = socket as AuthenticatedSocket;
        authSocket.userId = decoded.sub;
        authSocket.userRole = decoded.role;
        
        next();
      } catch (err) {
        next(new Error('Authentication error: Invalid token'));
      }
    });

    this.io.on('connection', (socket: Socket) => {
      const { userId, userRole } = socket as AuthenticatedSocket;

      console.log(`[Socket] User connected: ${userId} (${userRole})`);

      // Join private user room
      socket.join(`user:${userId}`);

      // Join lawyer lobby if applicable
      if (userRole === 'LAWYER') {
        socket.join('lobby:lawyers');
      }

      // Handle joining chat rooms (with isolation check)
      socket.on('join:chat', (whatsappNumber: string) => {
        // Normaliza o número para garantir que o room seja o mesmo independente do sufixo
        const normalized = whatsappNumber.split('@')[0].replace(/\D/g, '');
        socket.join(`chat:${normalized}`);
        console.log(`[Socket] User ${userId} joined chat room: ${normalized} (original: ${whatsappNumber})`);
      });

      socket.on('leave:chat', (whatsappNumber: string) => {
        const normalized = whatsappNumber.split('@')[0].replace(/\D/g, '');
        socket.leave(`chat:${normalized}`);
        console.log(`[Socket] User ${userId} left chat room: ${normalized}`);
      });

      socket.on('disconnect', () => {
        console.log(`[Socket] User disconnected: ${userId}`);
      });
    });

    this.setupEventBusListeners();
  }

  private setupEventBusListeners(): void {
    if (!this.io) return;

    // Listen to InternalEventBus and broadcast to Socket.io rooms
    
    eventBus.on('notification:new', ({ userId, notification }) => {
      this.io?.to(`user:${userId}`).emit('notification:new', notification);
    });

    eventBus.on('message:new', ({ whatsappNumber, message }) => {
      const normalized = whatsappNumber.split('@')[0].replace(/\D/g, '');
      this.io?.to(`chat:${normalized}`).emit('message:new', {
        ...message,
        whatsappNumber: normalized,
      });
    });

    eventBus.on('lead:updated', ({ lead }) => {
      this.io?.to('lobby:lawyers').emit('lead:updated', lead);
    });

    eventBus.on('lead:locked', ({ leadId, whatsappNumber, lawyerId, lawyerName }) => {
      this.io?.to('lobby:lawyers').emit('lead:locked', { leadId, whatsappNumber, lawyerId, lawyerName });
    });

    eventBus.on('lead:unlocked', ({ leadId, whatsappNumber }) => {
      this.io?.to('lobby:lawyers').emit('lead:unlocked', { leadId, whatsappNumber });
    });

    eventBus.on('lead:deleted', ({ leadId }) => {
      this.io?.to('lobby:lawyers').emit('lead:deleted', { leadId });
    });

    eventBus.on('leads:reset', () => {
      this.io?.to('lobby:lawyers').emit('leads:reset', {});
    });

    eventBus.on('procedure:updated', ({ userId, procedure }) => {
      this.io?.to(`user:${userId}`).emit('procedure:updated', procedure);
    });

    // Appointment events
    eventBus.on('appointment:created', ({ userId, appointment }) => {
      this.io?.to(`user:${userId}`).emit('appointment:created', appointment);
    });

    eventBus.on('appointment:updated', ({ userId, appointment }) => {
      this.io?.to(`user:${userId}`).emit('appointment:updated', appointment);
    });

    eventBus.on('appointment:deleted', ({ userId, appointmentId }) => {
      this.io?.to(`user:${userId}`).emit('appointment:deleted', { appointmentId });
    });

    eventBus.on('appointment:approved', ({ lawyerId, appointment }) => {
      this.io?.to(`user:${lawyerId}`).emit('appointment:approved', appointment);
    });

    eventBus.on('appointment:rejected', ({ lawyerId, appointmentId }) => {
      this.io?.to(`user:${lawyerId}`).emit('appointment:rejected', { appointmentId });
    });

    eventBus.on('pending:appointments:updated', ({ lawyerId }) => {
      this.io?.to(`user:${lawyerId}`).emit('pending:appointments:updated', {});
    });

    eventBus.on('deadline:reminder', ({ userId, appointment }) => {
      this.io?.to(`user:${userId}`).emit('deadline:reminder', appointment);
    });

    eventBus.on('reschedule:requested', ({ lawyerId, suggestion }) => {
      this.io?.to(`user:${lawyerId}`).emit('reschedule:requested', suggestion);
    });

    eventBus.on('reschedule:accepted', ({ lawyerId, appointment }) => {
      this.io?.to(`user:${lawyerId}`).emit('reschedule:accepted', appointment);
    });

    eventBus.on('reschedule:rejected', ({ lawyerId, suggestionId }) => {
      this.io?.to(`user:${lawyerId}`).emit('reschedule:rejected', { suggestionId });
    });

    eventBus.on('document:uploaded', ({ userId, document }) => {
      this.io?.to(`user:${userId}`).emit('document:uploaded', document);
    });

    eventBus.on('document:deleted', ({ userId, documentId, processId }) => {
      this.io?.to(`user:${userId}`).emit('document:deleted', { documentId, processId });
    });
  }

  public getIO(): SocketIOServer | null {
    return this.io;
  }
}

export const socketService = SocketService.getInstance();
