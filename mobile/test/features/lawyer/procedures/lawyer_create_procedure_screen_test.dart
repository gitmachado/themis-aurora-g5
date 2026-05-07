import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/lawyer/clients/domain/entities/lawyer_client.dart';
import 'package:mobile/features/lawyer/clients/presentation/providers/lawyer_client_providers.dart';
import 'package:mobile/features/lawyer/procedures/presentation/screens/lawyer_create_procedure_screen.dart';

import '../../../helpers/fakes.dart';

class _MockLawyerClientsNotifier extends LawyerClientsNotifier {
  _MockLawyerClientsNotifier(this.data);

  final List<LawyerClient> data;

  @override
  Future<List<LawyerClient>> build() async => data;
}

class _PendingLawyerClientsNotifier extends LawyerClientsNotifier {
  _PendingLawyerClientsNotifier(this.completer);

  final Completer<List<LawyerClient>> completer;

  @override
  Future<List<LawyerClient>> build() => completer.future;
}

Widget _wrap(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: child),
  );
}

void main() {
  setUpAll(() async {
    setupFirebaseForTesting();
    await Firebase.initializeApp();
  });

  group('LawyerCreateProcedureScreen', () {
    testWidgets('renderiza titulo Novo Processo no AppBar', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const LawyerCreateProcedureScreen(),
          overrides: [
            myLawyerClientsProvider.overrideWith(
              () => _MockLawyerClientsNotifier(const []),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Novo Processo'), findsWidgets);
    });

    testWidgets('exibe instrucao para preencher os dados', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const LawyerCreateProcedureScreen(),
          overrides: [
            myLawyerClientsProvider.overrideWith(
              () => _MockLawyerClientsNotifier(const []),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Preencha os dados'), findsOneWidget);
    });

    testWidgets(
      'exibe nome dos clientes vindos do myLawyerClientsProvider no dropdown',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const LawyerCreateProcedureScreen(),
            overrides: [
              myLawyerClientsProvider.overrideWith(
                () => _MockLawyerClientsNotifier(const [
                  LawyerClient(
                    id: 'c-1',
                    name: 'Maria Silva',
                    whatsappNumber: '+5511900000001',
                  ),
                  LawyerClient(
                    id: 'c-2',
                    name: 'Pedro Santos',
                    whatsappNumber: '+5511900000002',
                  ),
                ]),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        // Abre o dropdown de clientes (encontra pelo placeholder).
        await tester.tap(find.text('Selecione o cliente'));
        await tester.pumpAndSettle();

        expect(find.text('Maria Silva'), findsWidgets);
        expect(find.text('Pedro Santos'), findsWidgets);
      },
    );

    testWidgets('mostra LinearProgressIndicator enquanto clientes carregam', (
      tester,
    ) async {
      final completer = Completer<List<LawyerClient>>();

      await tester.pumpWidget(
        _wrap(
          const LawyerCreateProcedureScreen(),
          overrides: [
            myLawyerClientsProvider.overrideWith(
              () => _PendingLawyerClientsNotifier(completer),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Resolve para evitar pendingFuture nos invariants.
      completer.complete(const []);
      await tester.pumpAndSettle();
    });

    testWidgets('exibe campo de Titulo do Processo', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const LawyerCreateProcedureScreen(),
          overrides: [
            myLawyerClientsProvider.overrideWith(
              () => _MockLawyerClientsNotifier(const []),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Título do Processo'), findsOneWidget);
    });
  });
}
