import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/lawyer/leads/domain/entities/lead.dart';
import 'package:mobile/features/lawyer/leads/presentation/providers/lead_providers.dart';
import 'package:mobile/features/lawyer/leads/presentation/screens/lawyer_lead_detail_screen.dart';

import '../../../helpers/fakes.dart';

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

  group('LawyerLeadDetailScreen', () {
    testWidgets('renderiza nome do lead vindo do construtor (leadId nulo)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const LawyerLeadDetailScreen(
            leadId: null,
            name: 'Maria Lead',
            caseType: 'Trabalhista',
            urgency: 'Alta',
          ),
        ),
      );
      await tester.pump();

      // Nome aparece tanto no AppBar quanto na seccao de dados.
      expect(find.text('Maria Lead'), findsWidgets);
    });

    testWidgets('exibe seccoes Dados do Lead e Relato do Caso', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const LawyerLeadDetailScreen(
            leadId: null,
            name: 'Maria Lead',
            caseType: 'Trabalhista',
            urgency: 'Alta',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Dados do Lead'), findsOneWidget);
      expect(find.text('Relato do Caso'), findsOneWidget);
      expect(find.text('Nome Completo'), findsOneWidget);
      expect(find.text('Disponibilidade'), findsOneWidget);
      expect(find.text('Tipo de Caso'), findsOneWidget);
    });

    testWidgets('mostra botao de Acoes', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const LawyerLeadDetailScreen(
            leadId: null,
            name: 'Maria Lead',
            caseType: 'Trabalhista',
            urgency: 'Alta',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Ações'), findsOneWidget);
    });

    testWidgets(
      'sobrescreve nome do construtor com lead carregado pelo provider',
      (tester) async {
        const fakeLead = Lead(
          id: 'lead-1',
          whatsappNumber: '+5511999990000',
          name: 'Pedro Investidor',
          status: 'PENDING',
        );

        await tester.pumpWidget(
          _wrap(
            const LawyerLeadDetailScreen(
              leadId: 'lead-1',
              name: 'Maria Lead',
              caseType: 'Trabalhista',
              urgency: 'Alta',
            ),
            overrides: [
              leadDetailsProvider(
                'lead-1',
              ).overrideWith((ref) async => fakeLead),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Pedro Investidor'), findsWidgets);
      },
    );

    testWidgets(
      'usa nome do construtor enquanto provider de detalhes esta pendurado',
      (tester) async {
        // Completer permite controlar a resolucao sem deixar timers pendurados.
        final completer = Completer<Lead>();

        await tester.pumpWidget(
          _wrap(
            const LawyerLeadDetailScreen(
              leadId: 'lead-1',
              name: 'Maria Lead',
              caseType: 'Trabalhista',
              urgency: 'Alta',
            ),
            overrides: [
              leadDetailsProvider(
                'lead-1',
              ).overrideWith((ref) => completer.future),
            ],
          ),
        );
        await tester.pump();

        expect(find.text('Maria Lead'), findsWidgets);

        // Resolve o future antes de encerrar o teste para nao deixar
        // pendingFuture estourando o invariants do flutter_test.
        completer.complete(
          const Lead(
            id: 'lead-1',
            whatsappNumber: '+5511999990000',
            name: 'Maria Lead',
            status: 'PENDING',
          ),
        );
        await tester.pumpAndSettle();
      },
    );
  });
}
