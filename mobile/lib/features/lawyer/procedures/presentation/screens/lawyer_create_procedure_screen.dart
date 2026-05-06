import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
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
    {'value': 'TRABALHISTA', 'label': 'Trabalhista'},
    {'value': 'CIVEL', 'label': 'Cível'},
    {'value': 'FAMILIA', 'label': 'Família'},
    {'value': 'CRIMINAL', 'label': 'Criminal'},
    {'value': 'PREVIDENCIARIO', 'label': 'Previdenciário'},
    {'value': 'OUTROS', 'label': 'Outros'},
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
      await ref.read(procedureActionsProvider).createProcess(
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
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar:
            const CustomAppBar(title: 'Novo Processo', showBackButton: true),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informações do Processo',
                  style: AppTextStyles.h2.copyWith(color: AppColors.ink),
                ),
                const SizedBox(height: 8),
                Text(
                  'Preencha os dados abaixo para cadastrar um novo processo manualmente.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textCaption,
                  ),
                ),
                const SizedBox(height: 32),

                // Cliente
                Text(
                  'Cliente',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                clientsAsync.when(
                  data: (clients) => DropdownButtonFormField<String>(
                    initialValue: _selectedClientId,
                    decoration: _inputDecoration('Selecione o cliente'),
                    items: clients
                        .map(
                          (c) => DropdownMenuItem(
                              value: c.id, child: Text(c.name)),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedClientId = val),
                    validator: (val) => val == null ? 'Obrigatório' : null,
                  ),
                  loading: () =>
                      const LinearProgressIndicator(color: AppColors.yellow),
                  error: (e, _) => Text('Erro ao carregar clientes: $e'),
                ),
                const SizedBox(height: 20),

                // Título
                Text(
                  'Título do Processo',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: _inputDecoration(
                    'Ex: Ação de Alimentos - Maria Silva',
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 20),

                // Área/Tipo
                Text(
                  'Área de Atuação',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
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
                  onChanged: (val) => setState(() => _selectedCaseType = val),
                  validator: (val) => val == null ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 20),

                // Número do Processo (Opcional)
                Text(
                  'Número do Processo (Opcional)',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _processNumberController,
                  decoration: _inputDecoration('0000000-00.0000.0.00.0000'),
                ),
                const SizedBox(height: 20),

                // Descrição (Opcional)
                Text(
                  'Descrição / Observações',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  decoration: _inputDecoration(
                    'Detalhes adicionais sobre o caso...',
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 40),

                // Botão Salvar
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yellow,
                      foregroundColor: AppColors.ink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.ink,
                            ),
                          )
                        : Text(
                            'Criar Processo',
                            style: AppTextStyles.h2.copyWith(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.surface2,
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
        borderSide: const BorderSide(color: AppColors.yellow, width: 1.5),
      ),
    );
  }
}
