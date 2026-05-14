import dotenv from 'dotenv';
import path from 'path';
import http from 'http';
import app from './app';
import { validateRuntimeEnv } from './config/runtime';
import { socketService } from './services/communication/SocketService';
import { DeadlineRemindersJob } from './jobs/deadline-reminders.job';
import { initializeScheduler } from './jobs/scheduler';
import { AppointmentService } from './services/implementations/appointment.service';
import { AppointmentRepository } from './repositories/implementations/appointment.repository';
import { TimelineService } from './services/implementations/timeline.service';
import { TimelineEventRepository } from './repositories/implementations/timeline-event.repository';
import { NotificationService } from './services/implementations/notification.service';
import { NotificationRepository } from './repositories/implementations/notification.repository';
import { UserRepository } from './repositories/implementations/user.repository';
import { PushNotificationService } from './services/notifications/push_notification_service';

// Load .env from root of server
dotenv.config({ path: path.resolve(__dirname, '../.env') });

validateRuntimeEnv();

const PORT = Number(process.env.PORT || 3000);
const HOST = '0.0.0.0';

const server = http.createServer(app);

// Initialize Socket.io
socketService.initialize(server);

// Initialize background jobs
const appointmentRepository = new AppointmentRepository();
const timelineEventRepository = new TimelineEventRepository();
const notificationRepository = new NotificationRepository();
const userRepository = new UserRepository();
const pushNotificationService = new PushNotificationService();

const timelineService = new TimelineService(timelineEventRepository);
const notificationService = new NotificationService(
  notificationRepository,
  userRepository,
  pushNotificationService
);
const appointmentService = new AppointmentService(
  appointmentRepository,
  timelineService,
  notificationService
);

const deadlineRemindersJob = new DeadlineRemindersJob(appointmentService);
deadlineRemindersJob.start();

// Initialize reschedule suggestions scheduler
initializeScheduler();

server.listen(PORT, HOST, () => {
  console.log(`🚀 Server ready at http://localhost:${PORT}`);
});
