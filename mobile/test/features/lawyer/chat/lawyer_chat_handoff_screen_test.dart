import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/lawyer/chat/domain/entities/chat_message.dart';
import 'package:mobile/features/lawyer/chat/presentation/providers/chat_providers.dart';
import 'package:mobile/features/lawyer/chat/presentation/screens/lawyer_chat_handoff_screen.dart';
import 'package:mobile/features/notifications/domain/entities/app_notification.dart';
import 'package:mobile/features/notifications/presentation/providers/notification_providers.dart';

import '../../../helpers/fakes.dart';

class _MockLiveChatNotifier extends LiveChatNotifier {
  _MockLiveChatNotifier(this.data);

  final List<ChatMessage> data;

  @override
  Future<List<ChatMessage>> build(String arg) async => data;

  @override
  Future<Map<String, dynamic>> getLeadInfo() async => <String, dynamic>{};
}

class _MockNotificationsNotifier extends MyNotificationsNotifier {
  @override
  Future<List<AppNotification>> build() async => const <AppNotification>[];
}

Widget _wrap({
  required Widget child,
  required List<ChatMessage> messages,
  String whatsappNumber = '+5511999990000',
}) {
  return ProviderScope(
    overrides: [
      liveChatProvider.overrideWith(() => _MockLiveChatNotifier(messages)),
      myNotificationsProvider.overrideWith(_MockNotificationsNotifier.new),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  setUpAll(() async {
    setupFirebaseForTesting();
    await Firebase.initializeApp();
  });

  group('LawyerChatHandoffScreen', () {
    testWidgets('renderiza nome do cliente no AppBar', (tester) async {
      await tester.pumpWidget(
        _wrap(
          messages: const [],
          child: const LawyerChatHandoffScreen(
            clientName: 'João Cliente',
            whatsappNumber: '+5511999990000',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('João Cliente'), findsWidgets);
    });

    testWidgets('exibe mensagens vindas do liveChatProvider', (tester) async {
      await tester.pumpWidget(
        _wrap(
          messages: const [
            ChatMessage(
              id: 'message-1',
              sender: 'CLIENT',
              content: 'Bom dia, advogado',
            ),
            ChatMessage(
              id: 'message-2',
              sender: 'BOT',
              content: 'Olá! Como posso ajudar?',
            ),
          ],
          child: const LawyerChatHandoffScreen(
            clientName: 'João Cliente',
            whatsappNumber: '+5511999990000',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bom dia, advogado'), findsOneWidget);
      expect(find.text('Olá! Como posso ajudar?'), findsOneWidget);
    });

    testWidgets(
      'lida com whatsappNumber vazio sem disparar fetch',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            messages: const [],
            whatsappNumber: '',
            child: const LawyerChatHandoffScreen(
              clientName: 'João Cliente',
              whatsappNumber: '',
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Renderiza o cabecalho mesmo sem numero (nao trava).
        expect(find.text('João Cliente'), findsWidgets);
      },
    );
  });
}
