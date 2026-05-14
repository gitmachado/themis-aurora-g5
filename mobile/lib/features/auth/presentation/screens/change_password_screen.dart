import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/routes/app_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../domain/entities/account.dart';
import '../providers/auth_providers.dart';

/// Tela bloqueante de troca de senha.
///
/// Quando [forceFirstLogin] é true (advogado recém-cadastrado pelo chefe),
/// o campo de senha atual fica oculto e a tela não pode ser fechada com back —
/// só com logout ou após troca bem-sucedida.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  final bool forceFirstLogin;

  const ChangePasswordScreen({super.key, this.forceFirstLogin = false});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;
  String? _submitError;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.forceFirstLogin,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          automaticallyImplyLeading: !widget.forceFirstLogin,
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          iconTheme: const IconThemeData(color: AppColors.ink),
          title: Text(
            widget.forceFirstLogin ? 'Defina sua senha' : 'Trocar senha',
            style: AppTextStyles.h2.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          actions: widget.forceFirstLogin
              ? [
                  TextButton(
                    onPressed: _isSubmitting ? null : _logout,
                    child: const Text(
                      'Sair',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ]
              : null,
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.forceFirstLogin)
                    _FirstLoginBanner()
                  else
                    Text(
                      'Para trocar sua senha, informe a atual e escolha uma nova.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textCaption,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 20),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (!widget.forceFirstLogin) ...[
                          _PasswordField(
                            label: 'Senha atual',
                            controller: _currentController,
                            obscure: _obscureCurrent,
                            onToggleObscure: () => setState(
                              () => _obscureCurrent = !_obscureCurrent,
                            ),
                            validator: (value) {
                              if ((value ?? '').isEmpty) {
                                return 'Informe a senha atual';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        _PasswordField(
                          label: 'Nova senha',
                          controller: _newController,
                          obscure: _obscureNew,
                          onToggleObscure: () =>
                              setState(() => _obscureNew = !_obscureNew),
                          validator: (value) {
                            final v = value ?? '';
                            if (v.isEmpty) return 'Informe a nova senha';
                            if (v.length < 6) {
                              return 'Mínimo de 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _PasswordField(
                          label: 'Confirmar nova senha',
                          controller: _confirmController,
                          obscure: _obscureConfirm,
                          onToggleObscure: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                          validator: (value) {
                            final v = value ?? '';
                            if (v.isEmpty) return 'Confirme a nova senha';
                            if (v != _newController.text) {
                              return 'As senhas não conferem';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  if (_submitError != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _submitError!,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: widget.forceFirstLogin ? 'Continuar' : 'Salvar',
                    isLoading: _isSubmitting,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      final account = await ref
          .read(accountActionsProvider)
          .changePassword(
            newPassword: _newController.text,
            currentPassword: widget.forceFirstLogin
                ? null
                : _currentController.text,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha atualizada com sucesso.')),
      );

      if (widget.forceFirstLogin) {
        _navigateAfterFirstLogin(account);
      } else {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitError = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _navigateAfterFirstLogin(Account account) {
    final route = account.role.isLawyerSide
        ? AppRouter.lawyerDashboardRoute
        : AppRouter.clientDashboardRoute;
    Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
  }

  Future<void> _logout() async {
    await ref.read(authControllerProvider.notifier).logout();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRouter.loginRoute, (_) => false);
  }
}

class _FirstLoginBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.yellowSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.yellow.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_reset_rounded, color: AppColors.yellowDeep),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crie sua senha pessoal',
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 15,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Você entrou com uma senha temporária. '
                  'Defina agora uma senha pessoal para continuar.',
                  style: AppTextStyles.caption.copyWith(fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggleObscure,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.ink2,
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          autocorrect: false,
          enableSuggestions: false,
          validator: validator,
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: AppTextStyles.body.copyWith(
              color: AppColors.ink4,
              fontSize: 14.5,
            ),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.ink2,
                size: 20,
              ),
              onPressed: onToggleObscure,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.ink, width: 1.4),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}
