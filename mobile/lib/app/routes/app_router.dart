import 'package:flutter/material.dart';

final class AppRouter {
  static const String initialRoute = '/';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text('OmniConnect - Estrutura Pronta'),
        ),
      ),
      settings: settings,
    );
  }
}
