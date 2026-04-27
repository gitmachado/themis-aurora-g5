import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../app/routes/app_router.dart';
import '../../../../../../features/lawyer/clients/domain/entities/lawyer_client.dart';
import '../../../../../../features/lawyer/clients/presentation/providers/lawyer_client_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/constants/app_dimensions.dart';
import '../../../../../../shared/widgets/app_app_bar_actions.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';

class LawyerClientListScreen extends ConsumerStatefulWidget {
  const LawyerClientListScreen({super.key});

  @override
  ConsumerState<LawyerClientListScreen> createState() =>
      _LawyerClientListScreenState();
}

class _LawyerClientListScreenState
    extends ConsumerState<LawyerClientListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(myLawyerClientsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Clientes',
        actions: [AppAppBarActions()],
        showDivider: false,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou CPF...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textCaption,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          Container(height: 1, color: AppColors.divider.withValues(alpha: 0.7)),
          const SizedBox(height: 16),
          Expanded(
            child: clients.when(
              data: _buildClientList,
              loading: _buildLoadingList,
              error: (error, _) => _buildErrorState(error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientList(List<LawyerClient> clients) {
    final query = _searchQuery.toLowerCase();
    final filtered = clients.where((client) {
      return client.name.toLowerCase().contains(query) ||
          (client.cpf ?? '').contains(_searchQuery) ||
          client.whatsappNumber.contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'Nenhum cliente encontrado',
          style: AppTextStyles.h2.copyWith(color: AppColors.textCaption),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(myLawyerClientsProvider.future),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          AppDimensions.bottomPadding(context),
        ),
        itemCount: filtered.length,
        itemBuilder: (context, index) => _buildClientCard(filtered[index]),
      ),
    );
  }

  Widget _buildClientCard(LawyerClient client) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            client.name[0].toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        title: Text(
          client.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              client.cpf == null || client.cpf!.isEmpty
                  ? 'WhatsApp: ${client.whatsappNumber}'
                  : 'CPF: ${client.cpf}',
              style: AppTextStyles.caption.copyWith(fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionIcon(
              Icons.phone_rounded,
              AppColors.primary,
              client.whatsappNumber.isEmpty
                  ? null
                  : () => _callClient(client.whatsappNumber),
            ),
            const SizedBox(width: 8),
            _buildActionIcon(
              Icons.chat_bubble_rounded,
              AppColors.success,
              () => Navigator.pushNamed(
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
        onTap: () => Navigator.pushNamed(
          context,
          '/lawyer-client-detail',
          arguments: {
            'id': client.id,
            'name': client.name,
            'cpf': client.cpf ?? '',
            'phone': client.whatsappNumber,
            'email': client.email,
          },
        ),
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        AppDimensions.bottomPadding(context),
      ),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) =>
          const LoadingSkeleton(height: 82, borderRadius: 16),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          error.toString(),
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: SizedBox.square(
        dimension: 48,
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }

  Future<void> _callClient(String whatsappNumber) async {
    final uri = Uri.parse('tel:$whatsappNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
