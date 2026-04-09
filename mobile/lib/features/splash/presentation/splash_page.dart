import 'package:flutter/material.dart';

import '../../../app/router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const _transitionDelay = Duration(milliseconds: 1200);

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(_transitionDelay, _goToLogin);
  }

  void _goToLogin() {
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(AppRouter.loginRoute);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                'OmniConnect',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Atendimento juridico inteligente com uma base Flutter pronta para evoluir.',
                style: theme.textTheme.titleMedium?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 32),
              const LinearProgressIndicator(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
