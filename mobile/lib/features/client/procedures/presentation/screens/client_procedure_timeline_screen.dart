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
      length: 4,
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
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textCaption,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Timeline'),
              Tab(text: 'IA Resumo'),
              Tab(text: 'Arquivos'),
              Tab(text: 'Chat'),
            ],
          ),
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
            _buildChatTab(),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            for (var index = 0; index < events.length; index++)
              TimelineEventTile(
                isFirst: index == 0,
                isLast: index == events.length - 1,
                title: _timelineTitle(events[index].type),
                date: formatRelativeDate(events[index].createdAt),
                description: events[index].content,
              ),
          ],
        ),
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
            onChatMirrorTap: () =>
                DefaultTabController.of(context).animateTo(3),
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
                const LabeledField(
                  label: 'DESCRIÇÃO DO CASO',
                  isDescription: true,
                  value: '',
                ),
                if (process.description != null &&
                    process.description!.isNotEmpty)
                  Text(
                    process.description!,
                    style: AppTextStyles.body.copyWith(height: 1.5),
                  )
                else
                  Text(
                    'Descricao ainda nao cadastrada.',
                    style: AppTextStyles.caption,
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
        color: isSelected ? AppColors.primary : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF666666),
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildChatTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 48,
            color: AppColors.textCaption,
          ),
          SizedBox(height: 16),
          Text('Histórico de Conversas', style: AppTextStyles.h2),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Aqui você verá o espelhamento das conversas com nosso assistente e advogados.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionFooter(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
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
