import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/domain/entities/account.dart';
import 'package:mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/features/client/chat/presentation/screens/client_chat_mirror_screen.dart';
import 'package:mobile/features/client/files/presentation/screens/client_files_screen.dart';
import 'package:mobile/features/client/procedures/presentation/screens/client_procedure_list_screen.dart';
import 'package:mobile/features/client/profile/presentation/screens/client_profile_screen.dart';
import 'package:mobile/features/lawyer/chat/domain/entities/chat_message.dart';
import 'package:mobile/features/lawyer/chat/presentation/providers/chat_providers.dart';
import 'package:mobile/features/procedures/domain/entities/legal_process.dart';
import 'package:mobile/features/procedures/domain/entities/process_document.dart';
import 'package:mobile/features/procedures/presentation/providers/procedure_providers.dart';

void main() {
  testWidgets('client mirrored chat is read-only and route-backed', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentAccountProvider.overrideWith((ref) async => _account),
          liveChatProvider.overrideWith(
            () => _MockChatNotifier(const [
              ChatMessage(
                id: 'message-1',
                sender: 'CLIENT',
                content: 'Mensagem real do WhatsApp',
              ),
            ]),
          ),
        ],
        child: const MaterialApp(home: ClientChatMirrorScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Mensagem real do WhatsApp'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('client files screen renders documents from provider', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentAccountProvider.overrideWith((ref) async => _account),
          myDocumentsProvider.overrideWith(
            (ref) async => const [
              ProcessDocument(
                id: 'doc-1',
                legalProcessId: 'process-1',
                fileName: 'contrato.pdf',
                fileUrl: '/uploads/contrato.pdf',
                sentById: 'client-1',
              ),
            ],
          ),
          myProceduresProvider.overrideWith(
            () => _MockProceduresNotifier(const [
              LegalProcess(
                id: 'process-1',
                clientId: 'client-1',
                title: 'Tramite real',
                currentStatus: 'OPEN',
              ),
            ]),
          ),
        ],
        child: const MaterialApp(home: ClientFilesScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('contrato.pdf'), findsOneWidget);
  });

  testWidgets('client process list hides processes from other clients', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentAccountProvider.overrideWith((ref) async => _account),
          myProceduresProvider.overrideWith(
            () => _MockProceduresNotifier(const [
              LegalProcess(
                id: 'process-1',
                clientId: 'client-1',
                title: 'Processo do cliente',
                currentStatus: 'OPEN',
              ),
              LegalProcess(
                id: 'process-2',
                clientId: 'client-2',
                title: 'Processo de outro cliente',
                currentStatus: 'OPEN',
              ),
            ]),
          ),
        ],
        child: const MaterialApp(home: ClientProcedureListScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Processo do cliente'), findsOneWidget);
    expect(find.text('Processo de outro cliente'), findsNothing);
  });

  testWidgets('client profile renders account data from account route', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentAccountProvider.overrideWith((ref) async => _account),
        ],
        child: const MaterialApp(home: ClientProfileScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Lucas Silva'), findsWidgets);
    expect(find.text('11999999999'), findsOneWidget);
  });
}

const _account = Account(
  id: 'client-1',
  name: 'Lucas Silva',
  whatsappNumber: '11999999999',
  role: UserRole.client,
  cpf: '12345678900',
  email: 'lucas@example.com',
  notificationPreferences: {'documents': true},
);

class _MockChatNotifier extends LiveChatNotifier {
  final List<ChatMessage> data;
  _MockChatNotifier(this.data);

  @override
  Future<List<ChatMessage>> build(String arg) async => data;
}

class _MockProceduresNotifier extends MyProceduresNotifier {
  final List<LegalProcess> data;
  _MockProceduresNotifier(this.data);

  @override
  Future<List<LegalProcess>> build() async => data;
}
