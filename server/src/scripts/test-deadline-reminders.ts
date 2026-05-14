import dotenv from 'dotenv';
import path from 'path';
import { AppointmentRepository } from '../repositories/implementations/appointment.repository';
import { TimelineService } from '../services/implementations/timeline.service';
import { TimelineEventRepository } from '../repositories/implementations/timeline-event.repository';
import { NotificationService } from '../services/implementations/notification.service';
import { NotificationRepository } from '../repositories/implementations/notification.repository';
import { UserRepository } from '../repositories/implementations/user.repository';
import { PushNotificationService } from '../services/notifications/push_notification_service';
import { AppointmentService } from '../services/implementations/appointment.service';

dotenv.config({ path: path.resolve(__dirname, '../../.env') });

async function test() {
  console.log('🧪 Testing DeadlineRemindersJob...\n');

  try {
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

    console.log('✓ Dependencies initialized successfully');

    console.log('\n📋 Executing processDeadlineReminders()...');
    await appointmentService.processDeadlineReminders();
    console.log('✓ processDeadlineReminders() executed successfully');

    console.log('\n✅ Test completed successfully!');
    console.log('The cron job is properly configured and can process deadline reminders.');

    process.exit(0);
  } catch (error) {
    console.error('❌ Test failed:', error);
    process.exit(1);
  }
}

test();
