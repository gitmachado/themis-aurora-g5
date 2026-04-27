import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../features/procedures/domain/entities/legal_process.dart';
import '../../../../../../features/procedures/domain/entities/process_document.dart';
import '../../../../../../features/procedures/domain/entities/timeline_event.dart';
import '../../../../../../features/procedures/presentation/procedure_display.dart';
import '../../../../../../features/procedures/presentation/providers/procedure_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/network/api_client.dart';
import '../../../../../../shared/utils/api_formatters.dart';
import '../../../../../../shared/widgets/buttons/app_badge.dart';
import '../../../../../../shared/widgets/cards/app_card.dart';
import '../../../../../../shared/widgets/cards/app_list_tile.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';

class LawyerProcedureDetailScreen extends ConsumerStatefulWidget {
  final String? processId;

  const LawyerProcedureDetailScreen({super.key, this.processId});

  @override
  ConsumerState<LawyerProcedureDetailScreen> createState() =>
      _LawyerProcedureDetailScreenState();
}

class _LawyerProcedureDetailScreenState
    extends ConsumerState<LawyerProcedureDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final processId = widget.processId;

    if (processId == null || processId.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(title: 'Trâmite', showBackButton: true),
        body: Center(child: Text('Trâmite sem ID real.')),
      );
    }

    final process = ref.watch(procedureDetailsProvider(processId));

    return process.when(
      data: (data) => _buildContent(data),
      loading: _buildLoading,
      error: (error, _) => _buildError(error),
    );
  }

  Widget _buildContent(LegalProcess process) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: process.processNumber?.isNotEmpty == true
              ? process.processNumber!
              : process.title,
          showBackButton: true,
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textCaption,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            tabs: const [
              Tab(text: 'Resumo'),
              Tab(text: 'Timeline'),
              Tab(text: 'Arquivos'),
            ],
          ),
        ),
        body: SafeArea(
          top: false,
          child: TabBarView(
            children: [
              _buildSummaryTab(process),
              _buildTimelineTab(process.id),
              _buildFilesTab(process.id),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'lawyer_procedure_detail_fab_${process.id}',
          onPressed: () => _showStatusSheet(process),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.edit_note_rounded),
          label: const Text('Status'),
        ),
      ),
    );
  }

  Widget _buildSummaryTab(LegalProcess process) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(process.title, style: AppTextStyles.h2)),
                  AppBadge(
                    label: process.displayStatus,
                    type: process.badgeType,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                process.description?.isNotEmpty == true
                    ? process.description!
                    : 'Sem descrição cadastrada.',
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildInfoSection('Dados do trâmite', [
          ('Número', process.processNumber ?? '--'),
          ('Área', process.caseTypeLabel),
          ('Cliente', process.clientId),
          ('Última nota', process.lastNote ?? '--'),
          ('Última movimentação', formatDateLabel(process.lastMovementDate)),
          ('Atualizado em', formatRelativeDate(process.updatedAt)),
        ]),
      ],
    );
  }

  Widget _buildTimelineTab(String processId) {
    final timeline = ref.watch(procedureTimelineProvider(processId));

    return timeline.when(
      data: (events) {
        if (events.isEmpty) {
          return _buildEmptyState(
            icon: Icons.timeline_rounded,
            text: 'Nenhuma movimentação registrada.',
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.refresh(procedureTimelineProvider(processId).future),
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _buildTimelineItem(
                event,
                isLast: index == events.length - 1,
              );
            },
          ),
        );
      },
      loading: () => ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (_, _) =>
            const LoadingSkeleton(height: 72, borderRadius: 12),
      ),
      error: (error, _) => _buildErrorBody(error),
    );
  }

  Widget _buildFilesTab(String processId) {
    final documents = ref.watch(procedureDocumentsProvider(processId));

    return documents.when(
      data: (items) {
        if (items.isEmpty) {
          return _buildEmptyState(
            icon: Icons.folder_open_rounded,
            text: 'Nenhum arquivo vinculado a este trâmite.',
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.refresh(procedureDocumentsProvider(processId).future),
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: items.length,
            itemBuilder: (context, index) => _buildDocumentTile(
              processId: processId,
              document: items[index],
            ),
          ),
        );
      },
      loading: () => ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) =>
            const LoadingSkeleton(height: 76, borderRadius: 12),
      ),
      error: (error, _) => _buildErrorBody(error),
    );
  }

  Widget _buildDocumentTile({
    required String processId,
    required ProcessDocument document,
  }) {
    final isPdf = (document.mimeType ?? document.fileName)
        .toLowerCase()
        .contains('pdf');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppListTile(
        title: document.fileName,
        subtitle:
            '${formatFileSize(document.sizeBytes)} • ${formatDateLabel(document.createdAt)}',
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
            color: isPdf ? AppColors.error : AppColors.primary,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'view') {
              _showDocumentDetails(document);
            }
            if (value == 'delete') {
              _confirmDeleteDocument(processId, document);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'view', child: Text('Visualizar')),
            PopupMenuItem(value: 'delete', child: Text('Remover')),
          ],
        ),
        onTap: () => _showDocumentDetails(document),
      ),
    );
  }

  Widget _buildTimelineItem(TimelineEvent event, {required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 72, color: AppColors.divider),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _timelineTitle(event.type),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatRelativeDate(event.createdAt),
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 8),
                Text(
                  event.content,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<(String, String)> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h2.copyWith(fontSize: 16)),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: [
              for (final item in items) ...[
                _buildDetailRow(item.$1, item.$2),
                if (item != items.last) const Divider(height: 24),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 128, child: Text(label, style: AppTextStyles.caption)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({required IconData icon, required String text}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textCaption),
          const SizedBox(height: 16),
          Text(text, style: AppTextStyles.body),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: 'Trâmite', showBackButton: true),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: LoadingSkeleton(height: 220, borderRadius: 16),
      ),
    );
  }

  Widget _buildError(Object error) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Trâmite', showBackButton: true),
      body: _buildErrorBody(error),
    );
  }

  Widget _buildErrorBody(Object error) {
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

  void _showStatusSheet(LegalProcess process) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Atualizar status', style: AppTextStyles.h2),
                const SizedBox(height: 16),
                for (final option in _statusOptions)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(option.label),
                    trailing: process.currentStatus == option.value
                        ? const Icon(Icons.check, color: AppColors.success)
                        : null,
                    onTap: () async {
                      Navigator.pop(context);
                      await _updateStatus(process.id, option.value);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateStatus(String processId, String status) async {
    try {
      await ref
          .read(procedureActionsProvider)
          .updateStatus(processId: processId, status: status);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Status atualizado.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  void _showDocumentDetails(ProcessDocument document) {
    final url = document.fileUrl.isNotEmpty
        ? document.fileUrl
        : ref.read(apiClientProvider).buildDocumentUrl(document.fileName);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(document.fileName, style: AppTextStyles.h2),
                const SizedBox(height: 12),
                Text(
                  'Arquivo real carregado do backend.',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 16),
                SelectableText(url, style: AppTextStyles.caption),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteDocument(String processId, ProcessDocument document) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover arquivo'),
        content: Text('Deseja remover "${document.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteDocument(processId, document.id);
            },
            child: const Text(
              'Remover',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDocument(String processId, String documentId) async {
    try {
      await ref
          .read(procedureActionsProvider)
          .deleteDocument(processId: processId, documentId: documentId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Arquivo removido.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  String _timelineTitle(String type) => switch (type) {
    'PROCESS_CREATED' => 'Trâmite criado',
    'DOCUMENT_SENT' => 'Documento enviado',
    'LAWYER_NOTE' => 'Nota do advogado',
    'STATUS_UPDATE' => 'Status atualizado',
    _ => 'Movimentação',
  };
}

const _statusOptions = [
  _StatusOption('OPEN', 'Aberto'),
  _StatusOption('UNDER_ANALYSIS', 'Em análise'),
  _StatusOption('AWAITING_DOCUMENT', 'Aguardando documento'),
  _StatusOption('COMPLETED', 'Concluído'),
  _StatusOption('ARCHIVED', 'Arquivado'),
];

final class _StatusOption {
  final String value;
  final String label;

  const _StatusOption(this.value, this.label);
}
