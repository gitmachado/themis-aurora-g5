import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../features/procedures/domain/entities/legal_process.dart';
import '../../../../../../features/procedures/domain/entities/process_document.dart';
import '../../../../../../features/procedures/domain/entities/timeline_event.dart';
import '../../../../../../features/procedures/presentation/procedure_display.dart';
import '../../../../../../features/procedures/presentation/providers/procedure_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/utils/api_formatters.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../../../shared/widgets/buttons/app_badge.dart';
import '../../../../../../shared/widgets/cards/labeled_field.dart';
import '../../../../../../shared/widgets/cards/file_card.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';
import '../widgets/timeline_summary_card.dart';
import '../widgets/timeline_event_tile.dart';

class ClientProcedureTimelineScreen extends ConsumerStatefulWidget {
  final String? processId;

  const ClientProcedureTimelineScreen({super.key, this.processId});

  @override
  ConsumerState<ClientProcedureTimelineScreen> createState() =>
      _ClientProcedureTimelineScreenState();
}

class _ClientProcedureTimelineScreenState
    extends ConsumerState<ClientProcedureTimelineScreen> {
  @override
  Widget build(BuildContext context) {
    final processId = widget.processId;
    if (processId == null || processId.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(showBackButton: true, title: 'Tramite'),
        body: const Center(child: Text('Tramite nao informado')),
      );
    }

    final process = ref.watch(procedureDetailsProvider(processId));
    final timeline = ref.watch(procedureTimelineProvider(processId));
    final documents = ref.watch(procedureDocumentsProvider(processId));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          showBackButton: true,
          titleWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: process.maybeWhen(
              data: (data) => [
                Text(
                  data.processNumber ?? data.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Text(
                      data.caseTypeLabel,
                      style: AppTextStyles.caption.copyWith(fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Atualizado ${formatRelativeDate(data.updatedAt)}',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              orElse: () => const [
                LoadingSkeleton(width: 180, height: 18),
                SizedBox(height: 6),
                LoadingSkeleton(width: 120, height: 12),
              ],
            ),
          ),
          title: '',
          actions: [
            IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                color: AppColors.textCaption,
              ),
              onPressed: () {
                ref.invalidate(procedureDetailsProvider(processId));
                ref.invalidate(procedureTimelineProvider(processId));
                ref.invalidate(procedureDocumentsProvider(processId));
              },
            ),
          ],
          bottom: _buildDetailTabs(),
        ),
        body: TabBarView(
          children: [
            timeline.when(
              data: _buildTimelineTab,
              loading: () => _buildLoadingTab(),
              error: (error, _) => _buildErrorTab(error),
            ),
            process.when(
              data: _buildAiResumoTab,
              loading: () => _buildLoadingTab(),
              error: (error, _) => _buildErrorTab(error),
            ),
            documents.when(
              data: _buildFilesTab,
              loading: () => _buildLoadingTab(),
              error: (error, _) => _buildErrorTab(error),
            ),
          ],
        ),
        bottomNavigationBar: _buildActionFooter(context),
      ),
    );
  }

  Widget _buildTimelineTab(List<TimelineEvent> events) {
    if (events.isEmpty) {
      return _buildEmptyTab('Nenhum evento de timeline encontrado');
    }

    final sortedEvents = [...events]
      ..sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimelineLegend('Atual'),
          const SizedBox(height: 14),
          for (var index = 0; index < sortedEvents.length; index++)
            TimelineEventTile(
              isFirst: index == 0,
              isLast: index == sortedEvents.length - 1,
              title: _timelineTitle(sortedEvents[index].type),
              date: formatRelativeDate(sortedEvents[index].createdAt),
              description: sortedEvents[index].content,
            ),
          _buildTimelineLegend('Antigo'),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildDetailTabs() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(68),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
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
              SizedBox(height: 36, child: Center(child: Text('Andamentos'))),
              SizedBox(height: 36, child: Center(child: Text('Resumo'))),
              SizedBox(height: 36, child: Center(child: Text('Documentos'))),
            ],
          ),
        ),
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

  Widget _buildAiResumoTab(LegalProcess process) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TimelineSummaryCard(
            status: process.displayStatus,
            lastMovement: formatDateLabel(
              process.lastMovementDate ?? process.updatedAt,
            ),
            onAiAnalysisTap: () {},
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.divider.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DESCRIÇÃO DO CASO',
                        style: AppTextStyles.cap.copyWith(
                          color: AppColors.white.withValues(alpha: 0.72),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        process.description != null &&
                                process.description!.isNotEmpty
                            ? process.description!
                            : 'Descricao ainda nao cadastrada.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.white,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabeledField(
                      label: 'IDENTIFICADOR DO CLIENTE',
                      value: process.clientId,
                      icon: Icons.person_outline,
                      iconColor: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                LabeledField(
                  label: 'STATUS ATUAL',
                  value: process.displayStatus,
                  valueWidget: Row(
                    children: [
                      AppBadge(
                        label: process.displayStatus,
                        type: process.badgeType,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                LabeledField(
                  label: 'TIPO DE CASO',
                  value: process.caseTypeLabel,
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'NUMERO DO TRAMITE',
                  value: process.processNumber ?? '--',
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'CRIADO EM',
                  value: formatDateLabel(process.createdAt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilesTab(List<ProcessDocument> documents) {
    if (documents.isEmpty) {
      return _buildEmptyTab('Nenhum arquivo vinculado a este tramite');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              _buildFilterChip('Todos', isSelected: true),
              const SizedBox(width: 8),
              _buildFilterChip('Petições'),
              const SizedBox(width: 8),
              _buildFilterChip('Provas'),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final document = documents[index];
              final isImage = document.mimeType?.startsWith('image/') ?? false;
              return AppFileCard(
                category: document.mimeType ?? 'arquivo',
                fileName: document.fileName,
                fileSize: formatFileSize(document.sizeBytes),
                dateAdded: formatDateLabel(document.createdAt),
                icon: isImage
                    ? Icons.image_outlined
                    : Icons.description_outlined,
                iconColor: isImage
                    ? const Color(0xFFEA580C)
                    : AppColors.primary,
                iconBackgroundColor: isImage
                    ? const Color(0xFFFFF7ED)
                    : const Color(0xFFEEF2FF),
                actionIcon: Icons.visibility_outlined,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.yellow : AppColors.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.yellow : AppColors.line,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionFooter(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: PrimaryButton(
            label: 'Dúvida? Falar no WhatsApp',
            icon: Icons.chat_bubble_outline_rounded,
            backgroundColor: AppColors.success,
            onPressed: () {},
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) =>
          const LoadingSkeleton(height: 72, borderRadius: 12),
    );
  }

  Widget _buildErrorTab(Object error) {
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

  Widget _buildEmptyTab(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: AppColors.textCaption),
        ),
      ),
    );
  }

  String _timelineTitle(String type) => switch (type) {
    'PROCESS_CREATED' => 'Tramite criado',
    'DOCUMENT_SENT' => 'Documento enviado',
    'LAWYER_NOTE' => 'Nota do advogado',
    'STATUS_UPDATE' => 'Status atualizado',
    _ => 'Atualizacao',
  };
}
