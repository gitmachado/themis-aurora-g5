import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/api_client.dart';

class PushNotificationService {
  final ApiClient _apiClient;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  PushNotificationService(this._apiClient);

  Future<void> initializePushNotifications() async {
    // 1. Solicitar permissão
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      log('Push notifications not authorized by user.');
      return;
    }

    // 2 & 3. Pegar o token e enviar ao backend
    await _fetchAndSendToken();

    // 4. Escutar onTokenRefresh
    _firebaseMessaging.onTokenRefresh.listen((token) {
      _sendTokenToBackend(token);
    });

    // Configurar flutter_local_notifications
    await _setupLocalNotifications();

    // 5. Configurar onMessage (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // 6. Configurar onMessageOpenedApp (Background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('User opened app from background notification: ${message.messageId}');
      // Tratar navegação se necessário futuramente
    });
  }

  Future<void> _fetchAndSendToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _sendTokenToBackend(token);
      }
    } catch (e, stack) {
      log('Error fetching or sending FCM token: $e', error: e, stackTrace: stack);
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      await _apiClient.patch('/account/me/fcm-token', data: {'fcmToken': token});
      log('FCM token sent to backend successfully.');
    } catch (e, stack) {
      log('Error sending FCM token to backend: $e', error: e, stackTrace: stack);
    }
  }

  Future<void> _setupLocalNotifications() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotificationsPlugin.initialize(initializationSettings);

    // Criar um canal para Android para notificações high importance
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    final androidPlugin = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(androidChannel);
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            icon: '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    }
  }
}
