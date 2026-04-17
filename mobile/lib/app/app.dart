import 'package:flutter/material.dart';

import 'package:mobile/app/routes/app_router.dart';
import 'package:mobile/app/theme/theme.dart';

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
