import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../../app/routes/app_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../domain/entities/account.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _clientIdentifierController = TextEditingController();
  final _clientPasswordController = TextEditingController();
  final _lawyerIdentifierController = TextEditingController();
  final _lawyerPasswordController = TextEditingController();
  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _clientIdentifierController.dispose();
    _clientPasswordController.dispose();
    _lawyerIdentifierController.dispose();
    _lawyerPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,

        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 48),
                          // Logo Placeholder
                          Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.gavel_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Bem-vindo ao\nOmniConnect',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.h1,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Acesse sua conta para continuar',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 40),

                          // Custom Tab Bar
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicator: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelColor: Colors.white,
                              unselectedLabelColor: AppColors.textCaption,
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              dividerColor: Colors.transparent,
                              tabs: const [
                                Tab(text: 'Sou Cliente'),
                                Tab(text: 'Sou Advogado'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Tab View
                          SizedBox(
                            height: 340,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildLoginForm(isLawyer: false),
                                _buildLoginForm(isLawyer: true),
                              ],
                            ),
                          ),

                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm({required bool isLawyer}) {
    final authState = ref.watch(authControllerProvider);
    final identifierController = isLawyer
        ? _lawyerIdentifierController
        : _clientIdentifierController;
    final passwordController = isLawyer
        ? _lawyerPasswordController
        : _clientPasswordController;
    final isLoading = authState.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: identifierController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'CPF ou telefone',
            prefixIcon: Icon(
              isLawyer ? Icons.badge_outlined : Icons.person_outline,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          obscureText: _isObscure,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitLogin(
            identifier: identifierController.text,
            password: passwordController.text,
          ),
          decoration: InputDecoration(
            labelText: 'Senha',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _isObscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: () => setState(() => _isObscure = !_isObscure),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        if (authState.hasError) ...[
          const SizedBox(height: 12),
          Text(
            authState.error.toString(),
            style: AppTextStyles.caption.copyWith(color: AppColors.error),
          ),
        ],
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () => _submitLogin(
                  identifier: identifierController.text,
                  password: passwordController.text,
                ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Entrar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }

  Future<void> _submitLogin({
    required String identifier,
    required String password,
  }) async {
    final trimmedIdentifier = identifier.trim();
    if (trimmedIdentifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe CPF/telefone e senha.')),
      );
      return;
    }

    try {
      final session = await ref
          .read(authControllerProvider.notifier)
          .login(identifier: trimmedIdentifier, password: password);

      if (!mounted) return;

      final route = session.role == UserRole.lawyer
          ? AppRouter.lawyerDashboardRoute
          : AppRouter.clientDashboardRoute;
      Navigator.pushReplacementNamed(context, route);
    } catch (_) {
      // Error state is rendered in the form.
    }
  }
}
