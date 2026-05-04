import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/api_client.dart';
import '../../app/navigation_service.dart';
import '../../app/routes/app_router.dart';

// ---------------------------------------------------------------------------
// Background message handler — DEVE ser uma função top-level (fora de classe).
//
// Restrição do Dart isolate: quando o app está fechado ou em background,
// o Firebase cria um isolate separado para processar a mensagem. Nesse
// contexto NÃO é possível:
//   • usar closures que capturam instâncias de objetos
//   • acessar providers Riverpod
//   • chamar Navigator (o widget tree não existe ainda)
//
// O que SIM é possível: exibir a notificação via FlutterLocalNotifications,
// pois ele usa um canal Android nativo independente do widget tree.
// ---------------------------------------------------------------------------
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  // flutter_local_notifications precisa ser re-inicializado neste isolate.
  // A v21 usa parâmetros nomeados em initialize() e show().
  final plugin = FlutterLocalNotificationsPlugin();

  await plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  final notification = message.notification;
  if (notification == null) return;

  await plugin.show(
    id: notification.hashCode,
    title: notification.title,
    body: notification.body,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        icon: '@mipmap/ic_launcher',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tipos de notificação — mapeiam o campo "type" enviado pelo backend.
// Contratos definidos nos eventos do servidor:
//   • 'procedure_update' → atualização de TimelineEvento
//   • 'new_lead'         → novo Lead recebido (advogado)
//   • 'handoff'          → handoff humano confirmado (advogado)
//
// TODO(backend): confirmar valores reais com o time de backend — pendência
// registrada no PR da task G5-66.
// ---------------------------------------------------------------------------
const _kProcedureUpdate = 'procedure_update';
const _kNewLead = 'new_lead';
const _kHandoff = 'handoff';

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

    // 5. Foreground — exibe notificação local enquanto o app está aberto
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // 6. Background tap — usuário tocou na notificação com o app em background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('User tapped background notification: ${message.messageId}');
      _handleNotificationNavigation(message);
    });

    // 7. App fechado tap — verifica se o app foi aberto por tap em notificação
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      log('App opened from terminated state via notification: ${initialMessage.messageId}');
      // Adia a navegação para garantir que o widget tree já foi montado.
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleNotificationNavigation(initialMessage);
      });
    }
  }

  // -------------------------------------------------------------------------
  // Navegação baseada no tipo da notificação.
  //
  // O backend inclui o campo "type" em message.data.
  // Usa navigatorKey (GlobalKey<NavigatorState>) para navegar sem BuildContext.
  // -------------------------------------------------------------------------
  void _handleNotificationNavigation(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;
    final navigator = navigatorKey.currentState;

    if (navigator == null) {
      log('Navigator not ready for notification navigation. type=$type');
      return;
    }

    switch (type) {
      case _kProcedureUpdate:
        // Atualização de TimelineEvento → abre a timeline do processo.
        // O backend envia o processId em data['processId'].
        final processId = data['processId'] as String?;
        navigator.pushNamed(
          AppRouter.procedureTimelineRoute,
          arguments: processId != null ? {'processId': processId} : null,
        );

      case _kNewLead:
      case _kHandoff:
        // Novo lead ou handoff → abre o dashboard do advogado (aba leads).
        navigator.pushNamed(AppRouter.lawyerDashboardRoute);

      default:
        // Tipo desconhecido ou ausente → não navega, apenas loga.
        log('Unknown notification type, skipping navigation. type=$type');
    }
  }

  Future<void> _fetchAndSendToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _sendTokenToBackend(token);
      }
    } catch (e, stack) {
      log(
        'Error fetching or sending FCM token: $e',
        error: e,
        stackTrace: stack,
      );
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      await _apiClient.patchJson(
        '/account/me/fcm-token',
        data: {'fcmToken': token},
      );
      log('FCM token sent to backend successfully.');
    } catch (e, stack) {
      log(
        'Error sending FCM token to backend: $e',
        error: e,
        stackTrace: stack,
      );
    }
  }

  Future<void> _setupLocalNotifications() async {
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // v21: initialize() usa parâmetros nomeados
    await _localNotificationsPlugin.initialize(
      settings: const InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      ),
    );

    // Criar um canal para Android para notificações high importance
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    final androidPlugin = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(androidChannel);
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      // v21: show() usa parâmetros nomeados
      _localNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
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
