import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/features/auth/domain/entities/account.dart';
import 'package:mobile/features/auth/domain/entities/auth_session.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:mobile/shared/errors/failures.dart';
import 'package:mobile/shared/network/api_client.dart';

import '../../../helpers/fakes.dart';

class _FakeAuthRepository implements AuthRepository {
  /// Controla o resultado do proximo login. Por padrao retorna um sucesso
  /// resolvido imediatamente. Sobrescreva para simular erro ou loading
  /// pendurado em testes especificos.
  Completer<Either<Failure, AuthSession>>? loginCompleter;
  Either<Failure, AuthSession> nextLoginResult = Right(
    const AuthSession(
      token: 'tok',
      userId: 'u-1',
      role: UserRole.client,
      account: Account(
        id: 'u-1',
        name: 'Tester',
        whatsappNumber: '+5500000000000',
        role: UserRole.client,
      ),
    ),
  );

  @override
  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
  }) async {
    if (loginCompleter != null) return loginCompleter!.future;
    return nextLoginResult;
  }

  @override
  Future<Either<Failure, AuthSession>> signInWithGoogle() async =>
      nextLoginResult;

  @override
  Future<Either<Failure, AuthSession?>> restoreSession() async =>
      const Right(null);

  @override
  Future<Either<Failure, Account>> getAccount() async {
    final session = nextLoginResult.toNullable();
    if (session?.account != null) return Right(session!.account!);
    return const Left(ServerFailure('no account'));
  }

  @override
  Future<Either<Failure, Account>> updateNotificationPreferences(
    Map<String, bool> preferences,
  ) async => const Left(ServerFailure('not used in tests'));

  @override
  Future<Either<Failure, Account>> uploadAvatar({
    required String filePath,
    String? fileName,
  }) async => const Left(ServerFailure('not used in tests'));

  @override
  Future<Either<Failure, Account>> changePassword({
    required String newPassword,
    String? currentPassword,
  }) async => const Left(ServerFailure('not used in tests'));

  @override
  Future<Either<Failure, Unit>> logout() async => const Right(unit);
}

Widget _buildSubject({required _FakeAuthRepository repo, FakeApiClient? api}) {
  final apiClient = api ?? FakeApiClient();
  return ProviderScope(
    overrides: [
      apiClientProvider.overrideWithValue(apiClient),
      authRepositoryProvider.overrideWithValue(repo),
      pushNotificationServiceProvider.overrideWithValue(
        FakePushNotificationService(apiClient),
      ),
    ],
    child: MaterialApp(
      home: const LoginScreen(),
      // Rotas stub para evitar MissingRouteException ao tocar nos links.
      routes: {
        '/privacy-policy': (_) =>
            const Scaffold(body: Center(child: Text('privacy-stub'))),
        '/terms-of-use': (_) =>
            const Scaffold(body: Center(child: Text('terms-stub'))),
      },
    ),
  );
}

void main() {
  setUpAll(() async {
    setupFirebaseForTesting();
    await Firebase.initializeApp();
  });

  group('LoginScreen', () {
    testWidgets('renderiza titulo, campos e botoes principais', (tester) async {
      await tester.pumpWidget(_buildSubject(repo: _FakeAuthRepository()));
      await tester.pump();

      expect(find.text('Bem-vindo'), findsOneWidget);
      expect(find.text('Entre para acompanhar seus processos'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Entrar com Google'), findsOneWidget);
    });

    testWidgets('possui icones visuais nos campos email e senha', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(repo: _FakeAuthRepository()));
      await tester.pump();

      expect(find.byIcon(Icons.mail_outline), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('aceita input de texto nos campos email e senha', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(repo: _FakeAuthRepository()));
      await tester.pump();

      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(2));

      await tester.enterText(fields.at(0), 'advogado@themis.com');
      await tester.enterText(fields.at(1), 'segredo123');
      await tester.pump();

      expect(find.text('advogado@themis.com'), findsOneWidget);
      final passField = tester.widget<TextField>(fields.at(1));
      expect(passField.controller?.text, 'segredo123');
    });

    testWidgets(
      'mostra indicador de loading enquanto login esta em andamento',
      (tester) async {
        final repo = _FakeAuthRepository()
          ..loginCompleter = Completer<Either<Failure, AuthSession>>();

        await tester.pumpWidget(_buildSubject(repo: repo));
        await tester.pump();

        final fields = find.byType(TextField);
        await tester.enterText(fields.at(0), 'a@b.com');
        await tester.enterText(fields.at(1), '123');
        await tester.tap(find.text('Entrar'));
        await tester.pump(); // dispara o build apos a chamada async

        expect(find.byType(CircularProgressIndicator), findsWidgets);

        // Resolve o future pendurado para nao deixar o test com pendencias.
        repo.loginCompleter!.complete(repo.nextLoginResult);
        await tester.pumpAndSettle();
      },
    );

    testWidgets('exibe mensagem de erro quando login falha', (tester) async {
      final repo = _FakeAuthRepository()
        ..nextLoginResult = const Left(ServerFailure('Credenciais invalidas'));

      await tester.pumpWidget(_buildSubject(repo: repo));
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'a@b.com');
      await tester.enterText(fields.at(1), 'wrong');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Credenciais invalidas'), findsOneWidget);
    });

    testWidgets('expoe links para Politica de Privacidade e Termos de Uso', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(repo: _FakeAuthRepository()));
      await tester.pump();

      expect(find.text('Política de Privacidade'), findsOneWidget);
      expect(find.text('Termos de Uso'), findsOneWidget);
    });
  });
}
