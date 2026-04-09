import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/app/app.dart';

void main() {
  testWidgets('renders splash and navigates to login', (tester) async {
    await tester.pumpWidget(const OmniConnectApp());

    expect(find.text('OmniConnect'), findsOneWidget);
    expect(find.text('Acesso inicial'), findsNothing);

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(find.text('Acesso inicial'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
