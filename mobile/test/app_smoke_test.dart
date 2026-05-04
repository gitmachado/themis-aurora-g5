import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/app/app.dart';
import 'package:mobile/shared/network/websocket_client.dart';
import 'package:mobile/shared/network/api_client.dart';
import 'helpers/fakes.dart';

void main() {
  testWidgets('renders login screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          webSocketClientProvider.overrideWithValue(FakeWebSocketClient()),
          tokenStorageProvider.overrideWithValue(FakeTokenStorage()),
        ],
        child: const ThemisApp(),
      ),
    );
    // Aguarda o delay da SplashScreen (1.5s) e as transies
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
