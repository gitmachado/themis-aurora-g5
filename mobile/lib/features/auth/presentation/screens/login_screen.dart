import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../app/routes/app_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_assets.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../domain/entities/account.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
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
                          const SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SvgPicture.asset(
                              AppAssets.logoFull,
                              height: 140,
                            ),
                          ),
                          const SizedBox(height: 0),
                          Text(
                            'Bem-vindo',
                            style: AppTextStyles.h1.copyWith(fontSize: 34),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Entre para acompanhar seus processos',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textCaption,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 44),
                          _buildLoginForm(),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRouter.privacyPolicyRoute,
                                ),
                                child: Text(
                                  'Política de Privacidade',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text(
                                  '•',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textCaption,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRouter.termsOfUseRoute,
                                ),
                                child: Text(
                                  'Termos de Uso',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
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

  Widget _buildLoginForm() {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Icons.mail_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: _isObscure,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          onSubmitted: (_) => _submitLogin(
            email: _emailController.text,
            password: _passwordController.text,
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
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Entrar',
          isLoading: isLoading,
          onPressed: isLoading
              ? null
              : () => _submitLogin(
                  email: _emailController.text,
                  password: _passwordController.text,
                ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: isLoading ? null : _submitGoogleSignIn,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            side: const BorderSide(color: AppColors.border),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/google-icon.webp', height: 24),
              const SizedBox(width: 12),
              const Text(
                'Entrar com Google',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F1F1F),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OU',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textCaption,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.border)),
          ],
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Receber acesso via Whatsapp',
          icon: Icons.chat_bubble,
          iconColor: const Color(0xFF25D366),
          backgroundColor: AppColors.surface2,
          foregroundColor: AppColors.textPrimary,
          fontSize: 14,
          onPressed: _launchWhatsapp,
        ),
      ],
    );
  }

  Future<void> _launchWhatsapp() async {
    const message = 'Olá! Gostaria de solicitar meu acesso como cliente.';
    final url = Uri.parse(
      'https://wa.me/15551588949?text=${Uri.encodeComponent(message)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _submitLogin({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Informe email e senha.')));
      return;
    }

    try {
      final session = await ref
          .read(authControllerProvider.notifier)
          .login(email: trimmedEmail, password: password);

      if (!mounted) return;

      final route = session.role == UserRole.lawyer
          ? AppRouter.lawyerDashboardRoute
          : AppRouter.clientDashboardRoute;
      Navigator.pushReplacementNamed(context, route);
    } catch (_) {
      // Error state is rendered in the form.
    }
  }

  Future<void> _submitGoogleSignIn() async {
    try {
      final session = await ref
          .read(authControllerProvider.notifier)
          .googleSignIn();

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
