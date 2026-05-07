import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../../../shared/widgets/cards/app_card.dart';
import '../../../../../../features/procedures/presentation/providers/procedure_providers.dart';
import '../../../../../../features/lawyer/clients/presentation/providers/lawyer_client_providers.dart';

class LawyerCreateProcedureScreen extends ConsumerStatefulWidget {
  const LawyerCreateProcedureScreen({super.key});

  @override
  ConsumerState<LawyerCreateProcedureScreen> createState() =>
      _LawyerCreateProcedureScreenState();
}

class _LawyerCreateProcedureScreenState
    extends ConsumerState<LawyerCreateProcedureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _processNumberController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedClientId;
  String? _selectedCaseType;
  bool _isLoading = false;

  final List<Map<String, String>> _caseTypes = [
    {'value': 'Labor', 'label': 'Trabalhista'},
    {'value': 'Civil', 'label': 'Cível'},
    {'value': 'Family', 'label': 'Família'},
    {'value': 'Criminal', 'label': 'Criminal'},
    {'value': 'SocialSecurity', 'label': 'Previdenciário'},
    {'value': 'Civil', 'label': 'Outros'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _processNumberController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um cliente')),
      );
      return;
    }
    if (_selectedCaseType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione a área do processo'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(procedureActionsProvider)
          .createProcess(
            clientId: _selectedClientId!,
            title: _titleController.text,
            caseType: _selectedCaseType!,
            processNumber: _processNumberController.text.isEmpty
                ? null
                : _processNumberController.text,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Processo criado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao criar processo: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(myLawyerClientsProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(
          title: 'Novo Processo',
          showBackButton: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Preencha os dados abaixo para cadastrar um novo processo manualmente.',
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
                      // Cliente
                      _LabeledField(
                        label: 'Cliente',
                        child: clientsAsync.when(
                          data: (clients) => DropdownButtonFormField<String>(
                            initialValue: _selectedClientId,
                            decoration: _inputDecoration('Selecione o cliente'),
                            items: clients
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Text(c.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedClientId = val),
                            validator: (val) =>
                                val == null ? 'Obrigatório' : null,
                          ),
                          loading: () => const LinearProgressIndicator(
                            color: AppColors.yellow,
                          ),
                          error: (e, _) =>
                              Text('Erro ao carregar clientes: $e'),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Título
                      _LabeledField(
                        label: 'Título do Processo',
                        child: TextFormField(
                          controller: _titleController,
                          decoration: _inputDecoration(
                            'Ex: Ação de Alimentos - Maria Silva',
                          ),
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Obrigatório' : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Área/Tipo
                      _LabeledField(
                        label: 'Área de Atuação',
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedCaseType,
                          decoration: _inputDecoration('Selecione a área'),
                          items: _caseTypes
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t['value'],
                                  child: Text(t['label']!),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedCaseType = val),
                          validator: (val) =>
                              val == null ? 'Obrigatório' : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Número do Processo (Opcional)
                      _LabeledField(
                        label: 'Número do Processo (Opcional)',
                        child: TextFormField(
                          controller: _processNumberController,
                          decoration: _inputDecoration(
                            '0000000-00.0000.0.00.0000',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Descrição (Opcional)
                      _LabeledField(
                        label: 'Descrição / Observações',
                        child: TextFormField(
                          controller: _descriptionController,
                          decoration: _inputDecoration(
                            'Detalhes adicionais sobre o caso...',
                          ),
                          maxLines: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botão Salvar
                PrimaryButton(
                  label: 'Criar Processo',
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          height: MediaQuery.of(context).padding.bottom,
          color: AppColors.white,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
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
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
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
