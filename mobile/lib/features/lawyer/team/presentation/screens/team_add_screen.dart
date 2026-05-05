import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_dimensions.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../../../shared/widgets/cards/app_card.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../domain/entities/team_member_created.dart';
import '../../domain/entities/team_member_draft.dart';
import '../providers/team_providers.dart';

class TeamAddScreen extends ConsumerStatefulWidget {
  const TeamAddScreen({super.key});

  @override
  ConsumerState<TeamAddScreen> createState() => _TeamAddScreenState();
}

class _TeamAddScreenState extends ConsumerState<TeamAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _oabController = TextEditingController();

  TeamSpecialty _specialty = TeamSpecialty.civil;
  bool _isSubmitting = false;
  String? _submitError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
    _oabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Adicionar Advogado',
        showBackButton: true,
        showDivider: false,
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
                Text(
                  'Cadastre um novo advogado para integrar à sua equipe.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textCaption,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _LabeledField(
                        label: 'Nome completo',
                        child: TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: _decoration(hint: 'Ex.: Dra. Ana Souza'),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Informe o nome completo';
                            if (v.length < 3) return 'Nome muito curto';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _LabeledField(
                        label: 'E-mail',
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          decoration: _decoration(hint: 'nome@escritorio.com'),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Informe o e-mail';
                            final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                            if (!regex.hasMatch(v)) return 'E-mail inválido';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _LabeledField(
                        label: 'WhatsApp',
                        child: TextFormField(
                          controller: _whatsappController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(13),
                          ],
                          decoration: _decoration(hint: '5511999999999'),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Informe o WhatsApp';
                            if (v.length < 10) return 'Número incompleto';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _LabeledField(
                        label: 'OAB',
                        child: TextFormField(
                          controller: _oabController,
                          textInputAction: TextInputAction.next,
                          decoration: _decoration(hint: 'Ex.: SP123456'),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Informe o número da OAB';
                            if (v.length < 3) return 'OAB inválida';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _LabeledField(
                        label: 'Especialidade',
                        child: DropdownButtonFormField<TeamSpecialty>(
                          initialValue: _specialty,
                          decoration: _decoration(hint: 'Selecione a área'),
                          items: TeamSpecialty.values
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.label),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _specialty = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (_submitError != null) ...[
                  const SizedBox(height: 16),
                  _ErrorBanner(message: _submitError!),
                ],
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Cadastrar advogado',
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
                SizedBox(height: AppDimensions.spacing32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.body.copyWith(
        color: AppColors.ink4,
        fontSize: 14.5,
      ),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
      final draft = TeamMemberDraft(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        whatsappNumber: _whatsappController.text.trim(),
        oabNumber: _oabController.text.trim(),
        specialty: _specialty,
      );

      final created = await ref
          .read(teamListProvider.notifier)
          .addMember(draft);

      if (!mounted) return;

      await _showTempPasswordDialog(created);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitError = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _showTempPasswordDialog(TeamMemberCreated created) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _TempPasswordDialog(
        memberName: created.member.name,
        memberEmail: created.member.email ?? '',
        tempPassword: created.tempPassword,
      ),
    );
  }
}

class _TempPasswordDialog extends StatelessWidget {
  final String memberName;
  final String memberEmail;
  final String tempPassword;

  const _TempPasswordDialog({
    required this.memberName,
    required this.memberEmail,
    required this.tempPassword,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.yellowSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.vpn_key_rounded,
              color: AppColors.yellowDeep,
              size: 22,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Senha temporária gerada',
            style: AppTextStyles.h2.copyWith(
              fontSize: 18,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Compartilhe com $memberName. Ela será exibida apenas uma vez — '
            'depois disso, só restando reset manual. O advogado deve trocar no '
            'primeiro login.',
            style: AppTextStyles.caption.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (memberEmail.isNotEmpty)
            _CopyableField(
              label: 'E-mail',
              value: memberEmail,
              monospace: false,
            ),
          if (memberEmail.isNotEmpty) const SizedBox(height: 10),
          _CopyableField(
            label: 'Senha temporária',
            value: tempPassword,
            monospace: true,
            highlight: true,
          ),
          const SizedBox(height: 8),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: tempPassword));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Senha copiada para a área de transferência.'),
              ),
            );
          },
          child: const Text(
            'Copiar senha',
            style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Concluir',
            style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _CopyableField extends StatelessWidget {
  final String label;
  final String value;
  final bool monospace;
  final bool highlight;

  const _CopyableField({
    required this.label,
    required this.value,
    this.monospace = false,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.tiny.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
            color: AppColors.textCaption,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: highlight ? AppColors.yellowSoft : AppColors.surface2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: highlight
                  ? AppColors.yellow.withValues(alpha: 0.6)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  value,
                  style: TextStyle(
                    fontFamily: monospace ? AppTextStyles.monoFontFamily : null,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    letterSpacing: monospace ? 0.5 : null,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Copiar',
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: value));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('$label copiado.')));
                },
                icon: const Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: AppColors.ink2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

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
        child,
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
