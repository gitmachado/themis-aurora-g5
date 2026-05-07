import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/domain/entities/account.dart';
import 'package:mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/features/client/files/presentation/screens/client_files_screen.dart';
import 'package:mobile/features/procedures/domain/entities/legal_process.dart';
import 'package:mobile/features/procedures/domain/entities/process_document.dart';
import 'package:mobile/features/procedures/presentation/providers/procedure_providers.dart';

import '../../../helpers/fakes.dart';

const _account = Account(
  id: 'client-1',
  name: 'Joao Cliente',
  whatsappNumber: '+5511999990000',
  role: UserRole.client,
);

class _MockProceduresNotifier extends MyProceduresNotifier {
  _MockProceduresNotifier(this.data);

  final List<LegalProcess> data;

  @override
  Future<List<LegalProcess>> build() async => data;
}

Widget _wrap({
  List<ProcessDocument> documents = const [],
  List<LegalProcess> procedures = const [],
}) {
  return ProviderScope(
    overrides: [
      currentAccountProvider.overrideWith((ref) async => _account),
      myDocumentsProvider.overrideWith((ref) async => documents),
      myProceduresProvider.overrideWith(
        () => _MockProceduresNotifier(procedures),
      ),
    ],
    child: const MaterialApp(home: ClientFilesScreen()),
  );
}

void main() {
  setUpAll(() async {
    setupFirebaseForTesting();
    await Firebase.initializeApp();
  });

  group('ClientFilesScreen', () {
    testWidgets('renderiza titulo Documentos no AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('Documentos'), findsWidgets);
    });

    testWidgets('exibe nome do arquivo vindo do myDocumentsProvider', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          documents: const [
            ProcessDocument(
              id: 'doc-1',
              legalProcessId: 'process-1',
              fileName: 'contrato.pdf',
              fileUrl: '/uploads/contrato.pdf',
              sentById: 'client-1',
            ),
          ],
          procedures: const [
            LegalProcess(
              id: 'process-1',
              clientId: 'client-1',
              title: 'Tramite real',
              currentStatus: 'OPEN',
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('contrato.pdf'), findsOneWidget);
    });

    testWidgets('mostra multiplos arquivos quando provider retorna varios', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          documents: const [
            ProcessDocument(
              id: 'doc-1',
              legalProcessId: 'process-1',
              fileName: 'rg-frente.jpg',
              fileUrl: '/uploads/rg-frente.jpg',
              sentById: 'client-1',
              mimeType: 'image/jpeg',
            ),
            ProcessDocument(
              id: 'doc-2',
              legalProcessId: 'process-1',
              fileName: 'comprovante.pdf',
              fileUrl: '/uploads/comprovante.pdf',
              sentById: 'client-1',
              mimeType: 'application/pdf',
            ),
          ],
          procedures: const [
            LegalProcess(
              id: 'process-1',
              clientId: 'client-1',
              title: 'Tramite com docs',
              currentStatus: 'OPEN',
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('rg-frente.jpg'), findsOneWidget);
      expect(find.text('comprovante.pdf'), findsOneWidget);
    });

    testWidgets('renderiza estado vazio quando nao ha documentos', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          documents: const [],
          procedures: const [
            LegalProcess(
              id: 'process-1',
              clientId: 'client-1',
              title: 'Tramite sem docs',
              currentStatus: 'OPEN',
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Sem documentos, nao deve haver nomes de arquivo na tela.
      expect(find.text('contrato.pdf'), findsNothing);
      // Mas o titulo da tela continua aparecendo.
      expect(find.text('Documentos'), findsWidgets);
    });
  });
}
