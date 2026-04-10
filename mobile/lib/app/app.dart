import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class OmniConnectApp extends StatelessWidget {
  const OmniConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmniConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: AppRouter.splashRoute,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
