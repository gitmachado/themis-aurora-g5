import { IAppointmentService } from '../services/interfaces/appointment.service';

export class DeadlineRemindersJob {
  private intervalId: NodeJS.Timeout | null = null;

  constructor(private readonly appointmentService: IAppointmentService) {}

  start(): void {
    if (this.intervalId) {
      console.warn('DeadlineRemindersJob is already running');
      return;
    }

    console.log('Starting DeadlineRemindersJob');

    this.executeImmediately();

    const INTERVAL_24_HOURS = 24 * 60 * 60 * 1000;
    this.intervalId = setInterval(() => {
      this.executeReminders();
    }, INTERVAL_24_HOURS);
  }

  stop(): void {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
      console.log('DeadlineRemindersJob stopped');
    }
  }

  private async executeImmediately(): Promise<void> {
    console.log(`[DeadlineRemindersJob] Executing immediately on startup`);
    await this.executeReminders();
  }

  private async executeReminders(): Promise<void> {
    try {
      const now = new Date().toISOString();
      console.log(`[DeadlineRemindersJob] Processing reminders at ${now}`);
      await this.appointmentService.processDeadlineReminders();
      console.log(`[DeadlineRemindersJob] Successfully processed reminders`);
    } catch (error) {
      console.error('[DeadlineRemindersJob] Error processing reminders:', error);
    }
  }
}
