import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../constants/app_constants.dart';
import 'token_storage.dart';
import 'api_client.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

final webSocketClientProvider = Provider<WebSocketClient>((ref) {
  final client = WebSocketClient(tokenStorage: ref.watch(tokenStorageProvider));

  // Connect immediately if already authenticated
  final authState = ref.read(authControllerProvider);
  if (authState.valueOrNull != null) {
    client.connect();
  }

  // Listen for future auth status changes
  ref.listen(authControllerProvider, (previous, next) {
    if (next.valueOrNull != null) {
      client.connect();
    } else {
      client.disconnect();
    }
  });

  return client;
});

class WebSocketClient {
  final TokenStorage _tokenStorage;
  io.Socket? _socket;
  final _eventController = StreamController<WebSocketEvent>.broadcast();

  WebSocketClient({required TokenStorage tokenStorage})
    : _tokenStorage = tokenStorage;

  Stream<WebSocketEvent> get events => _eventController.stream;

  bool get isConnected => _socket?.connected ?? false;

  void connect() async {
    final token = await _tokenStorage.readToken();
    if (token == null) return;

    final baseUrl = AppConstants.apiBaseUrl.replaceFirst('/api/v1', '');

    _socket?.dispose();
    if (kDebugMode) {
      print(
        '[WebSocket] Connecting to $baseUrl with token length: ${token.length}',
      );
    }

    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports([
            'websocket',
          ]) // Use 'websocket' for better stability if supported
          .setAuth({'token': token})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(2000)
          .setReconnectionAttempts(15)
          .build(),
    );

    _socket!.onConnect((_) {
      if (kDebugMode) print('[WebSocket] Connected successfully to $baseUrl');
      _eventController.add(const WebSocketEvent(type: 'connected'));
    });

    _socket!.onDisconnect((reason) {
      if (kDebugMode) print('[WebSocket] Disconnected: $reason');
      _eventController.add(const WebSocketEvent(type: 'disconnected'));
    });

    _socket!.onConnectError((err) {
      if (kDebugMode) print('[WebSocket] Connection Error: $err');
      _eventController.add(WebSocketEvent(type: 'error', data: err));

      // If websocket fails, we could try to fallback to polling here if needed,
      // but the user wants it "blindada" based on the stable branch.
    });

    _socket!.onReconnect((_) {
      if (kDebugMode) print('[WebSocket] Reconnected');
    });
    _socket!.onReconnectAttempt((_) {
      if (kDebugMode) print('[WebSocket] Reconnect Attempt');
    });
    _socket!.onReconnectError((err) {
      if (kDebugMode) print('[WebSocket] Reconnect Error: $err');
    });
    _socket!.onReconnectFailed((_) {
      if (kDebugMode) print('[WebSocket] Reconnect Failed');
    });

    // Global event listeners
    _socket!.on('notification:new', (data) {
      if (kDebugMode) print('[WebSocket] Event received: notification:new');
      _eventController.add(
        WebSocketEvent(type: 'notification:new', data: data),
      );
    });

    _socket!.on('message:new', (data) {
      if (kDebugMode) {
        print('[WebSocket] Event received: message:new for ${data['whatsappNumber']}');
      }
      _eventController.add(WebSocketEvent(type: 'message:new', data: data));
    });

    _socket!.on('lead:updated', (data) {
      if (kDebugMode) print('[WebSocket] Event received: lead:updated');
      _eventController.add(WebSocketEvent(type: 'lead:updated', data: data));
    });

    _socket!.on('lead:locked', (data) {
      _eventController.add(WebSocketEvent(type: 'lead:locked', data: data));
    });

    _socket!.on('lead:unlocked', (data) {
      _eventController.add(WebSocketEvent(type: 'lead:unlocked', data: data));
    });

    _socket!.on('procedure:updated', (data) {
      _eventController.add(
        WebSocketEvent(type: 'procedure:updated', data: data),
      );
    });
  }

  void joinChat(String whatsappNumber) {
    if (kDebugMode) print('[WebSocket] Emitting join:chat for $whatsappNumber');
    _socket?.emit('join:chat', whatsappNumber);
  }

  void leaveChat(String whatsappNumber) {
    if (kDebugMode) print('[WebSocket] Emitting leave:chat for $whatsappNumber');
    _socket?.emit('leave:chat', whatsappNumber);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}

class WebSocketEvent {
  final String type;
  final dynamic data;

  const WebSocketEvent({required this.type, this.data});
}
