import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../features/procedures/domain/entities/legal_process.dart';
import '../../../../../../features/procedures/domain/entities/process_document.dart';
import '../../../../../../features/procedures/domain/entities/timeline_event.dart';
import '../../../../../../features/procedures/presentation/procedure_display.dart';
import '../../../../../../features/procedures/presentation/providers/procedure_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_dimensions.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/utils/api_formatters.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/layout/app_file_viewer.dart';
import '../../../../../../shared/network/api_client.dart';
import '../../../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../../../shared/widgets/buttons/app_badge.dart';
import '../../../../../../shared/widgets/cards/labeled_field.dart';
import '../../../../../../shared/widgets/cards/file_card.dart';
import '../../../../../../shared/widgets/themis/themis_widgets.dart';
import '../../../../../../shared/constants/app_constants.dart';
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
    extends ConsumerState<ClientProcedureTimelineScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
  )..addListener(() => setState(() {}));

  String _selectedFileFilter = 'Todos';

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColors.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          backgroundColor: AppColors.surface,
          showBackButton: true,
          titleWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
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
                      'Atualizado em ${formatFullDateTime(data.updatedAt)}',
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
          bottom: _buildDetailTabs(),
        ),
        body: TabBarView(
          controller: _tabController,
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

    // Agrupar eventos por mês/ano
    final Map<String, List<TimelineEvent>> groupedEvents = {};
    for (var event in sortedEvents) {
      final date = event.createdAt ?? DateTime.now();
      final monthName = _getMonthName(date.month);
      final key = '${monthName.toUpperCase()} ${date.year}';
      groupedEvents.putIfAbsent(key, () => []).add(event);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(procedureTimelineProvider(widget.processId ?? ''));
        return ref.read(
          procedureTimelineProvider(widget.processId ?? '').future,
        );
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: groupedEvents.length,
        itemBuilder: (context, groupIndex) {
          final monthKey = groupedEvents.keys.elementAt(groupIndex);
          final monthEvents = groupedEvents[monthKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  bottom: 16,
                  top: groupIndex == 0 ? 0 : 8,
                ),
                child: Text(
                  monthKey,
                  style: AppTextStyles.cap.copyWith(
                    color: AppColors.ink3,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              ...monthEvents.map((event) {
                final isGlobalFirst = sortedEvents.indexOf(event) == 0;
                final isGlobalLast =
                    sortedEvents.indexOf(event) == sortedEvents.length - 1;

                return TimelineEventTile(
                  isFirst: isGlobalFirst,
                  isLast: isGlobalLast,
                  title: _timelineTitle(event.type),
                  date: formatFullDateTime(event.createdAt),
                  description: formatTimelineContent(event.content),
                  icon: _timelineIcon(event.type),
                  iconBackgroundColor: isGlobalFirst
                      ? AppColors.yellow
                      : AppColors.yellowSoft,
                  iconColor: isGlobalFirst
                      ? AppColors.ink
                      : AppColors.yellowDeep,
                );
              }),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildDetailTabs() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(68),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: ThemisSegmentedControl(
            labels: const ['Andamentos', 'Resumo', 'Documentos'],
            selectedIndex: _tabController.index,
            controller: _tabController,
            onChanged: (index) {
              _tabController.animateTo(index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAiResumoTab(LegalProcess process) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(procedureDetailsProvider(widget.processId ?? ''));
        return ref.read(
          procedureDetailsProvider(widget.processId ?? '').future,
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TimelineSummaryCard(
              status: process.displayStatus,
              lastMovement: formatDateLabel(
                process.lastMovementDate ?? process.updatedAt,
              ),
              onAiAnalysisTap: () {
                final processNumber = process.processNumber ?? process.title;
                final message =
                    'Olá! Gostaria de entender melhor o status do meu processo: $processNumber';
                launchUrl(
                  Uri.parse(
                    'https://wa.me/${AppConstants.officeWhatsApp}?text=${Uri.encodeComponent(message)}',
                  ),
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalhes do Processo',
                    style: AppTextStyles.h2.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  LabeledField(
                    label: 'STATUS ATUAL',
                    value: process.displayStatus,
                    icon: Icons.info_outline,
                    iconColor: AppColors.primary,
                    valueWidget: Row(
                      children: [
                        AppBadge(
                          label: process.displayStatus,
                          type: process.badgeType,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  LabeledField(
                    label: 'TIPO DE CASO',
                    value: process.caseTypeLabel,
                    icon: Icons.category_outlined,
                    iconColor: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  LabeledField(
                    label: 'NÚMERO DO TRAMITE',
                    value: process.processNumber ?? '--',
                    icon: Icons.tag,
                    iconColor: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  LabeledField(
                    label: 'ÚLTIMA MOVIMENTAÇÃO',
                    value: formatDateLabel(process.lastMovementDate),
                    icon: Icons.calendar_today_outlined,
                    iconColor: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  LabeledField(
                    label: 'CRIADO EM',
                    value: formatDateLabel(process.createdAt),
                    icon: Icons.calendar_today_outlined,
                    iconColor: AppColors.primary,
                  ),
                  if (process.description != null &&
                      process.description!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 24),
                    Text(
                      'Sobre este processo',
                      style: AppTextStyles.h2.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      process.description!,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textCaption,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (process.lastNote != null &&
                      process.lastNote!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Última nota do advogado',
                                style: AppTextStyles.h2.copyWith(
                                  fontSize: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            process.lastNote!,
                            style: AppTextStyles.body.copyWith(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilesTab(List<ProcessDocument> documents) {
    // Calcular categorias dinâmicas
    final uniqueCategories = documents
        .map((doc) {
          final isImage = doc.mimeType?.startsWith('image/') ?? false;
          final isPdf = doc.mimeType == 'application/pdf';
          if (isImage) return 'Imagem';
          if (isPdf) return 'PDF';
          return 'Outros';
        })
        .toSet()
        .toList();

    // Se houver apenas uma categoria, não mostramos filtros (além do 'Todos')
    final showFilters = uniqueCategories.length > 1;

    final filteredDocuments = _selectedFileFilter == 'Todos'
        ? documents
        : documents.where((doc) {
            final isImage = doc.mimeType?.startsWith('image/') ?? false;
            final isPdf = doc.mimeType == 'application/pdf';
            if (_selectedFileFilter == 'Imagem') return isImage;
            if (_selectedFileFilter == 'PDF') return isPdf;
            return !isImage && !isPdf;
          }).toList();

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(procedureDocumentsProvider(widget.processId ?? ''));
        return ref.read(
          procedureDocumentsProvider(widget.processId ?? '').future,
        );
      },
      child: documents.isEmpty
          ? _buildEmptyTabScrollable('Nenhum arquivo vinculado.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showFilters)
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      border: Border(
                        bottom: BorderSide(color: AppColors.divider),
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildFilterChip(
                              'Todos',
                              isSelected: _selectedFileFilter == 'Todos',
                              onTap: () =>
                                  setState(() => _selectedFileFilter = 'Todos'),
                            ),
                            ...uniqueCategories.map(
                              (cat) => Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: _buildFilterChip(
                                  cat,
                                  isSelected: _selectedFileFilter == cat,
                                  onTap: () =>
                                      setState(() => _selectedFileFilter = cat),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      20,
                      showFilters ? 14 : 16,
                      20,
                      16,
                    ),
                    itemCount: filteredDocuments.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final document = filteredDocuments[index];
                      final isImage =
                          document.mimeType?.startsWith('image/') ?? false;
                      final isPdf = document.mimeType == 'application/pdf';

                      String displayCategory = 'Arquivo';
                      if (isImage) displayCategory = 'Imagem';
                      if (isPdf) displayCategory = 'PDF';

                      return AppFileCard(
                        category: displayCategory,
                        fileName: document.fileName,
                        fileSize: formatFileSize(document.sizeBytes),
                        dateAdded: formatDateLabel(document.createdAt),
                        onTap: () async {
                          try {
                            final url = await ref
                                .read(apiClientProvider)
                                .getDocumentAccessUrl(document.id);
                            if (!context.mounted) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AppFileViewer(
                                  fileUrl: url,
                                  fileName: document.fileName,
                                  mimeType: document.mimeType,
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erro ao abrir arquivo: $e'),
                              ),
                            );
                          }
                        },
                        icon: isImage
                            ? Icons.image_outlined
                            : isPdf
                            ? Icons.picture_as_pdf_outlined
                            : Icons.description_outlined,
                        iconColor: isImage
                            ? const Color(0xFFEA580C)
                            : isPdf
                            ? const Color(0xFFDC2626)
                            : AppColors.primary,
                        iconBackgroundColor: isImage
                            ? const Color(0xFFFFF7ED)
                            : isPdf
                            ? const Color(0xFFFEF2F2)
                            : const Color(0xFFEEF2FF),
                        actionIcon: Icons.visibility_outlined,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyTabScrollable(String message) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _buildEmptyTab(message),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }

  Widget _buildActionFooter(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: PrimaryButton(
            label: 'Dúvidas? Falar no WhatsApp',
            icon: Icons.chat_bubble_outline_rounded,
            backgroundColor: AppColors.success,
            onPressed: () => launchUrl(
              Uri.parse('https://wa.me/${AppConstants.officeWhatsApp}'),
              mode: LaunchMode.externalApplication,
            ),
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

  IconData _timelineIcon(String type) => switch (type) {
    'PROCESS_CREATED' => Icons.rocket_launch_outlined,
    'DOCUMENT_SENT' => Icons.description_outlined,
    'LAWYER_NOTE' => Icons.chat_bubble_outline_rounded,
    'STATUS_UPDATE' => Icons.sync_outlined,
    _ => Icons.circle_outlined,
  };

  String _getMonthName(int month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return months[month - 1];
  }
}
