import * as admin from 'firebase-admin';

// Inicialização defensiva: em CI / docker-smoke / dev sem credenciais
// FIREBASE_*, simplesmente não inicializa. A app sobe normalmente e
// sendPushNotification vira no-op (com aviso). Em produção, todas as três
// variaveis devem estar configuradas.
const projectId = process.env.FIREBASE_PROJECT_ID;
const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n');

const firebaseConfigured = Boolean(projectId && clientEmail && privateKey);

if (firebaseConfigured && !admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId,
      clientEmail,
      privateKey,
    }),
  });
} else if (!firebaseConfigured) {
  console.warn(
    '[PushNotificationService] FIREBASE_PROJECT_ID/CLIENT_EMAIL/PRIVATE_KEY ' +
      'ausentes — envio de push desativado neste ambiente.'
  );
}

export interface SendPushParams {
  token: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}

export class PushNotificationService {
  public async sendPushNotification(params: SendPushParams): Promise<void> {
    if (!firebaseConfigured) {
      console.log(
        `[PushNotificationService] Skipping push to ${params.token} — Firebase not configured.`
      );
      return;
    }

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
