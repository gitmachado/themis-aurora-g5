import * as admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    }),
  });
}

export interface SendPushParams {
  token: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}

export class PushNotificationService {
  public async sendPushNotification(params: SendPushParams): Promise<void> {
    try {
      const message = {
        token: params.token,
        notification: {
          title: params.title,
          body: params.body,
        },
        data: params.data,
      };

      await admin.messaging().send(message);
      console.log(`Push notification sent successfully to ${params.token}`);
    } catch (error) {
      console.error('Error sending push notification:', error);
      // Tratamento de erro sem quebrar o fluxo principal (log + fallback)
    }
  }
}
