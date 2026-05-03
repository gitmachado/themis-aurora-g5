import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/app/app.dart';

void main() {
  testWidgets('renders login screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: OmniConnectApp()));

    expect(find.text('Bem-vindo'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
