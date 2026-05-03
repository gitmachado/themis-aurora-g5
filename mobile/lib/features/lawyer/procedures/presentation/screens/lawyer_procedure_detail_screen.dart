import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../features/procedures/domain/entities/legal_process.dart';
import '../../../../../../features/procedures/domain/entities/process_document.dart';
import '../../../../../../features/procedures/domain/entities/timeline_event.dart';
import '../../../../../../features/procedures/presentation/procedure_display.dart';
import '../../../../../../features/procedures/presentation/providers/procedure_providers.dart';
import '../../../../../../features/lawyer/clients/presentation/providers/lawyer_client_providers.dart';
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
    final clientName = _clientNameFor(process);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: '',
          titleWidget: _buildHeaderTitle(process, clientName),
          showBackButton: true,
          bottom: _buildDetailTabs(),
        ),
        body: SafeArea(
          top: false,
          child: TabBarView(
            children: [
              _buildSummaryTab(process, clientName),
              _buildTimelineTab(process.id),
              _buildFilesTab(process.id),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'lawyer_procedure_detail_fab_${process.id}',
          onPressed: () => _showStatusSheet(process),
          backgroundColor: AppColors.yellow,
          foregroundColor: AppColors.ink,
          icon: const Icon(Icons.edit_note_rounded),
          label: const Text('Status'),
        ),
      ),
    );
  }

  Widget _buildHeaderTitle(LegalProcess process, String clientName) {
    final title = process.processNumber?.isNotEmpty == true
        ? process.processNumber!
        : process.title;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Cliente: $clientName',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textCaption,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildDetailTabs() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Container(
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(14),
          ),
          child: TabBar(
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            labelColor: AppColors.ink,
            unselectedLabelColor: AppColors.ink3,
            labelStyle: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w800,
            ),
            unselectedLabelStyle: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
            ),
            tabs: const [
              SizedBox(height: 36, child: Center(child: Text('Resumo'))),
              SizedBox(height: 36, child: Center(child: Text('Andamento'))),
              SizedBox(height: 36, child: Center(child: Text('Documentos'))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryTab(LegalProcess process, String clientName) {
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
          ('Cliente', clientName),
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

        final sortedEvents = [...events]
          ..sort((a, b) {
            final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bDate.compareTo(aDate);
          });

        return RefreshIndicator(
          onRefresh: () =>
              ref.refresh(procedureTimelineProvider(processId).future),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildTimelineLegend('Atual'),
              const SizedBox(height: 14),
              for (var index = 0; index < sortedEvents.length; index++)
                _buildTimelineItem(
                  sortedEvents[index],
                  isCurrent: index == 0,
                  isLast: index == sortedEvents.length - 1,
                ),
              const SizedBox(height: 2),
              _buildTimelineLegend('Antigo'),
            ],
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
            color: AppColors.yellowSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
            color: isPdf ? AppColors.error : AppColors.ink,
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

  Widget _buildTimelineLegend(String label) {
    return Text(
      label,
      style: AppTextStyles.cap.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildTimelineItem(
    TimelineEvent event, {
    required bool isCurrent,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: isCurrent ? 18 : 15,
              height: isCurrent ? 18 : 15,
              decoration: BoxDecoration(
                color: AppColors.yellow,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrent ? AppColors.ink : AppColors.white,
                  width: isCurrent ? 2.5 : 3,
                ),
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
                    fontSize: 16,
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
                    fontSize: 14,
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

  String _clientNameFor(LegalProcess process) {
    final clients = ref.watch(myLawyerClientsProvider).valueOrNull ?? const [];
    for (final client in clients) {
      if (client.id == process.clientId && client.name.trim().isNotEmpty) {
        return client.name.trim();
      }
    }

    return process.clientId.isEmpty ? 'Cliente' : process.clientId;
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

  Future<void> _showDocumentDetails(ProcessDocument document) async {
    late final String url;
    try {
      url = await ref.read(apiClientProvider).getDocumentAccessUrl(document.id);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
      return;
    }

    if (!mounted) return;

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
