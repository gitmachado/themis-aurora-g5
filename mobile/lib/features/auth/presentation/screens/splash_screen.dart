import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/routes/app_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../domain/entities/account.dart';
import '../providers/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    try {
      final sessionResult = await ref
          .read(restoreSessionUseCaseProvider)
          .call();

      sessionResult.fold(
        (failure) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRouter.loginRoute);
          }
        },
        (session) {
          if (!mounted) return;
          if (session == null) {
            Navigator.pushReplacementNamed(context, AppRouter.loginRoute);
          } else {
            // Persist the session in the global state to trigger WebSocket connection
            ref.read(authControllerProvider.notifier).setSession(session);

            final route = session.role == UserRole.lawyer
                ? AppRouter.lawyerDashboardRoute
                : AppRouter.clientDashboardRoute;
            Navigator.pushReplacementNamed(context, route);
          }
        },
      );
    } catch (_) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.loginRoute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Icon(Icons.gavel_rounded, color: Colors.white, size: 80),
      ),
    );
  }
}
