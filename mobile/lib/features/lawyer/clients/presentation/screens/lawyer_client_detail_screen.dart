import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../app/routes/app_router.dart';
import '../../../../../../features/lawyer/clients/domain/entities/lawyer_client.dart';
import '../../../../../../features/lawyer/clients/presentation/providers/lawyer_client_providers.dart';
import '../../../../../../features/procedures/domain/entities/legal_process.dart';
import '../../../../../../features/procedures/presentation/procedure_display.dart';
import '../../../../../../features/procedures/presentation/providers/procedure_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/buttons/app_badge.dart';
import '../../../../../../shared/widgets/cards/app_card.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';

class LawyerClientDetailScreen extends ConsumerWidget {
  final String? clientId;
  final String name;
  final String cpf;
  final String phone;
  final String? email;

  const LawyerClientDetailScreen({
    super.key,
    this.clientId,
    required this.name,
    required this.cpf,
    this.phone = '',
    this.email,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientAsync = clientId == null || clientId!.isEmpty
        ? null
        : ref.watch(lawyerClientDetailsProvider(clientId!));
    final client = clientAsync?.valueOrNull ?? _fallbackClient();
    final procedures = ref.watch(myProceduresProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Ficha do Cliente',
          showBackButton: true,
          actions: [
            if (clientId != null && clientId!.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () =>
                    _showDeleteConfirmation(context, ref, clientId!),
              ),
            IconButton(
              icon: const Icon(Icons.chat_outlined),
              onPressed: client.whatsappNumber.isEmpty
                  ? null
                  : () => Navigator.pushNamed(
                      context,
                      AppRouter.lawyerChatHandoffRoute,
                      arguments: {
                        'clientName': client.name,
                        'whatsappNumber': client.whatsappNumber,
                      },
                    ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (clientAsync?.isLoading ?? false) ...[
                const LoadingSkeleton(height: 4, borderRadius: 2),
                const SizedBox(height: 16),
              ],
              _buildProfileHeader(client),
              const SizedBox(height: 24),
              _buildInfoCard(client),
              const SizedBox(height: 24),
              procedures.when(
                data: (items) => _buildProcedureHistory(context, items),
                loading: () =>
                    const LoadingSkeleton(height: 180, borderRadius: 16),
                error: (error, _) => Text(
                  error.toString(),
                  style: AppTextStyles.body.copyWith(color: AppColors.error),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          height: MediaQuery.of(context).padding.bottom,
          color: AppColors.white,
        ),
      ),
    );
  }

  LawyerClient _fallbackClient() {
    return LawyerClient(
      id: clientId ?? '',
      name: name.isEmpty ? 'Cliente' : name,
      whatsappNumber: phone,
      cpf: cpf.isEmpty ? null : cpf,
      email: email,
    );
  }

  Widget _buildProfileHeader(LawyerClient client) {
    final initial = client.name.isEmpty ? '?' : client.name[0].toUpperCase();

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.surface2,
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          client.name.isEmpty ? 'Cliente' : client.name,
          style: AppTextStyles.h1,
        ),
        const SizedBox(height: 4),
        Text(
          client.cpf?.isNotEmpty == true
              ? 'CPF: ${client.cpf}'
              : 'CPF nao informado',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Widget _buildInfoCard(LawyerClient client) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações de Contato',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Telefone',
              client.whatsappNumber.isEmpty
                  ? 'Nao informado'
                  : client.whatsappNumber,
            ),
            const Divider(height: 24),
            _buildDetailRow('E-mail', client.email ?? 'Nao informado'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildProcedureHistory(
    BuildContext context,
    List<LegalProcess> procedures,
  ) {
    final linked = clientId == null || clientId!.isEmpty
        ? <LegalProcess>[]
        : procedures.where((process) => process.clientId == clientId).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trâmites Vinculados',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        if (linked.isEmpty)
          AppCard(
            child: Text(
              'Nenhum trâmite vinculado encontrado.',
              style: AppTextStyles.caption,
            ),
          )
        else
          for (final process in linked) _buildProcedureTile(context, process),
      ],
    );
  }

  Widget _buildProcedureTile(BuildContext context, LegalProcess process) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: ListTile(
        title: Text(
          process.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          process.processNumber ?? process.id,
          style: AppTextStyles.caption.copyWith(fontSize: 12),
        ),
        trailing: AppBadge(
          label: process.displayStatus,
          type: process.badgeType,
        ),
        onTap: () => Navigator.pushNamed(
          context,
          AppRouter.lawyerProcedureDetailRoute,
          arguments: {'processId': process.id},
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Cliente?'),
        content: const Text(
          'Esta ação é irreversível. O cliente e todo seu histórico (incluindo processos, documentos, mensagens e a memória da IA) serão permanentemente excluídos do sistema.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.ink),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteClient(context, ref, id);
            },
            child: const Text(
              'Excluir',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteClient(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final useCase = ref.read(deleteLawyerClientUseCaseProvider);
    final result = await useCase(id);

    if (context.mounted) {
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir: ${failure.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cliente excluído com sucesso.'),
              backgroundColor: AppColors.primary,
            ),
          );
          ref.read(myLawyerClientsProvider.notifier).refresh();
          Navigator.of(context).pop();
        },
      );
    }
  }
}
