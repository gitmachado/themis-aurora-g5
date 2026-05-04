import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mobile/app/routes/app_router.dart';
import 'package:mobile/app/theme/theme.dart';

class ThemisApp extends StatelessWidget {
  const ThemisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF8F9FA),
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: MaterialApp(
        title: 'Themis',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        initialRoute: AppRouter.initialRoute,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
