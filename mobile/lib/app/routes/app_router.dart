import 'package:flutter/material.dart';

import 'package:mobile/features/auth/presentation/screens/login_page.dart';
import 'package:mobile/features/splash/presentation/screens/splash_page.dart';

final class AppRouter {
  static const String splashRoute = '/';
  static const String loginRoute = '/login';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const SplashPage(),
          settings: settings,
        );
      case loginRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
    }
  }
}
