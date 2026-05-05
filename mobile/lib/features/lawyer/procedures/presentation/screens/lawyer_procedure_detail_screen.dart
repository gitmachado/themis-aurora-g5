import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

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
import '../../../../../../shared/constants/app_dimensions.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';
import '../../../../../../shared/widgets/themis/themis_widgets.dart';
import '../../../../../../shared/widgets/cards/labeled_field.dart';
import '../../../../../../shared/widgets/cards/file_card.dart';
import '../../../../client/procedures/presentation/widgets/timeline_event_tile.dart';

import '../../../../../../shared/widgets/layout/app_file_viewer.dart';

class LawyerProcedureDetailScreen extends ConsumerStatefulWidget {
  final String? processId;

  const LawyerProcedureDetailScreen({super.key, this.processId});

  @override
  ConsumerState<LawyerProcedureDetailScreen> createState() =>
      _LawyerProcedureDetailScreenState();
}

class _LawyerProcedureDetailScreenState
    extends ConsumerState<LawyerProcedureDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 3, vsync: this)
    ..addListener(() => setState(() {}));

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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        backgroundColor: AppColors.surface,
        showBackButton: true,
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              process.processNumber ?? process.title,
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
                  process.caseTypeLabel,
                  style: AppTextStyles.caption.copyWith(fontSize: 12),
                ),
                const SizedBox(width: 8),
                Text(
                  'Atualizado em ${formatFullDateTime(process.updatedAt)}',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        title: '',
        bottom: _buildDetailTabs(),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTimelineTab(process.id),
          _buildSummaryTab(process, clientName),
          _buildFilesTab(process.id),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'lawyer_procedure_detail_fab_${process.id}',
        onPressed: () => _showActionsSheet(process),
        backgroundColor: AppColors.yellow,
        foregroundColor: AppColors.ink,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ações'),
      ),
    );
  }

  PreferredSizeWidget _buildDetailTabs() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(68),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.divider),
          ),
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

  Widget _buildSummaryTab(LegalProcess process, String clientName) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(procedureDetailsProvider(widget.processId ?? ''));
        return ref.read(procedureDetailsProvider(widget.processId ?? '').future);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
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
                    label: 'CLIENTE',
                    value: clientName,
                    icon: Icons.person_outline_rounded,
                    iconColor: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
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
                  if (process.description != null && process.description!.isNotEmpty) ...[
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
                  if (process.lastNote != null && process.lastNote!.isNotEmpty) ...[
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
                                'Última Nota do Caso',
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
            ref.invalidate(procedureTimelineProvider(processId));
            return ref.read(procedureTimelineProvider(processId).future);
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
                    padding: EdgeInsets.only(bottom: 16, top: groupIndex == 0 ? 0 : 8),
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
                    final isGlobalLast = sortedEvents.indexOf(event) == sortedEvents.length - 1;

                    return TimelineEventTile(
                      isFirst: isGlobalFirst,
                      isLast: isGlobalLast,
                      title: _timelineTitle(event.type),
                      date: formatFullDateTime(event.createdAt),
                      description: formatTimelineContent(event.content),
                      icon: _timelineIcon(event.type),
                      iconBackgroundColor: isGlobalFirst ? AppColors.yellow : AppColors.yellowSoft,
                      iconColor: isGlobalFirst ? AppColors.ink : AppColors.yellowDeep,
                    );
                  }),
                ],
              );
            },
          ),
        );
      },
      loading: () => ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) =>
            const LoadingSkeleton(height: 72, borderRadius: 12),
      ),
      error: (error, _) => _buildErrorBody(error),
    );
  }

  Widget _buildFilesTab(String processId) {
    final documentsAsync = ref.watch(procedureDocumentsProvider(processId));

    return documentsAsync.when(
      data: (documents) {
        if (documents.isEmpty) {
          return _buildEmptyState(
            icon: Icons.folder_open_rounded,
            text: 'Nenhum arquivo vinculado a este trâmite.',
          );
        }

        // Calcular categorias dinâmicas (igual ao cliente)
        final uniqueCategories = documents.map((doc) {
          final isImage = doc.mimeType?.startsWith('image/') ?? false;
          final isPdf = doc.mimeType == 'application/pdf';
          if (isImage) return 'Imagem';
          if (isPdf) return 'PDF';
          return 'Outros';
        }).toSet().toList();

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
            ref.invalidate(procedureDocumentsProvider(processId));
            return ref.read(procedureDocumentsProvider(processId).future);
          },
          child: Column(
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildFilterChip(
                            'Todos',
                            isSelected: _selectedFileFilter == 'Todos',
                            onTap: () => setState(() => _selectedFileFilter = 'Todos'),
                          ),
                          ...uniqueCategories.map((cat) => Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: _buildFilterChip(
                                  cat,
                                  isSelected: _selectedFileFilter == cat,
                                  onTap: () => setState(() => _selectedFileFilter = cat),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredDocuments.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final document = filteredDocuments[index];
                    final isImage = document.mimeType?.startsWith('image/') ?? false;
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
                          final url = await ref.read(apiClientProvider).getDocumentAccessUrl(document.id);
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
                            SnackBar(content: Text('Erro ao abrir arquivo: $e')),
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
                      onActionTap: () => _showFileActions(processId, document),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) =>
            const LoadingSkeleton(height: 76, borderRadius: 12),
      ),
      error: (error, _) => _buildErrorBody(error),
    );
  }

  Widget _buildFilterChip(String label, {required bool isSelected, required VoidCallback onTap}) {
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

  void _showFileActions(String processId, ProcessDocument document) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility_outlined),
              title: const Text('Visualizar'),
              onTap: () {
                Navigator.pop(context);
                _showDocumentDetails(document);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              title: const Text('Remover', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteDocument(processId, document);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[month - 1];
  }

  IconData _timelineIcon(String type) => switch (type) {
    'PROCESS_CREATED' => Icons.rocket_launch_outlined,
    'DOCUMENT_SENT' => Icons.description_outlined,
    'LAWYER_NOTE' => Icons.chat_bubble_outline_rounded,
    'STATUS_UPDATE' => Icons.sync_outlined,
    'DOCUMENT_REQUESTED' => Icons.assignment_late_outlined,
    'EVENT_SCHEDULED' => Icons.event_available_outlined,
    _ => Icons.circle_outlined,
  };

  String _clientNameFor(LegalProcess process) {
    final clients = ref.watch(myLawyerClientsProvider).valueOrNull ?? const [];
    for (final client in clients) {
      if (client.id == process.clientId && client.name.trim().isNotEmpty) {
        return client.name.trim();
      }
    }

    return process.clientId.isEmpty ? 'Cliente' : process.clientId;
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Text(
        error.toString(),
        textAlign: TextAlign.center,
        style: AppTextStyles.body.copyWith(color: AppColors.error),
      ),
    );
  }

  void _showActionsSheet(LegalProcess process) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            systemNavigationBarColor: AppColors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Row(
                    children: [
                      Text('Ações do Processo', style: AppTextStyles.h2),
                    ],
                  ),
                ),
                ThemisActionRow(
                  icon: Icons.sync_outlined,
                  label: 'Atualizar Status',
                  iconBackground: AppColors.yellowSoft,
                  iconColor: AppColors.yellowDeep,
                  onTap: () {
                    Navigator.pop(context);
                    _showStatusSheet(process);
                  },
                ),
                ThemisActionRow(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Adicionar Nota do Caso',
                  iconBackground: AppColors.primary.withValues(alpha: 0.1),
                  iconColor: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    _showNoteDialog(process.id);
                  },
                ),
                ThemisActionRow(
                  icon: Icons.assignment_late_outlined,
                  label: 'Solicitar Documento',
                  iconBackground: const Color(0xFFFEF3C7),
                  iconColor: const Color(0xFFD97706),
                  onTap: () {
                    Navigator.pop(context);
                    _showRequestDocumentDialog(process.id);
                  },
                ),
                ThemisActionRow(
                  icon: Icons.attach_file_rounded,
                  label: 'Anexar Arquivo',
                  iconBackground: const Color(0xFFECFDF5),
                  iconColor: const Color(0xFF059669),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadFile(process.id);
                  },
                ),
                ThemisActionRow(
                  icon: Icons.event_available_outlined,
                  label: 'Agendar Evento',
                  iconBackground: const Color(0xFFF5F3FF),
                  iconColor: const Color(0xFF7C3AED),
                  onTap: () {
                    Navigator.pop(context);
                    _showScheduleEventDialog(process.id);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
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

  void _showNoteDialog(String processId) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Adicionar Nota', style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text(
                'Esta nota ficará visível na linha do tempo do processo.',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                maxLines: 4,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Digite sua observação aqui...',
                  hintStyle: AppTextStyles.caption,
                  filled: true,
                  fillColor: AppColors.surface2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ink,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (controller.text.trim().isEmpty) return;
                        Navigator.pop(context);
                        await _addNote(processId, controller.text.trim());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.yellow,
                        foregroundColor: AppColors.ink,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Adicionar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRequestDocumentDialog(String processId) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Solicitar Documento', style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text(
                'O cliente receberá uma notificação solicitando este arquivo.',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Ex: Comprovante de residência',
                  hintStyle: AppTextStyles.caption,
                  filled: true,
                  fillColor: AppColors.surface2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ink,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (controller.text.trim().isEmpty) return;
                        Navigator.pop(context);
                        await _requestDocument(processId, controller.text.trim());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.yellow,
                        foregroundColor: AppColors.ink,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Adicionar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showScheduleEventDialog(String processId) {
    final controller = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Agendar Evento', style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Text(
                  'O evento será registrado na linha do tempo do processo.',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Ex: Audiência de conciliação',
                    hintStyle: AppTextStyles.caption,
                    filled: true,
                    fillColor: AppColors.surface2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('DATA DO EVENTO', style: AppTextStyles.cap),
                              Text(formatDateLabel(selectedDate), style: AppTextStyles.body),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down_rounded, color: AppColors.ink4),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.ink,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (controller.text.trim().isEmpty) return;
                          Navigator.pop(context);
                          await _scheduleEvent(processId, controller.text.trim(), selectedDate);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.yellow,
                          foregroundColor: AppColors.ink,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text('Adicionar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadFile(String processId) async {
    try {
      final result = await FilePicker.pickFiles();
      if (result == null || result.files.single.path == null) return;

      final file = result.files.single;

      if (!mounted) return;

      // Modal de confirmação antes de enviar
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => ThemisAlertDialog(
          title: 'Anexar Arquivo?',
          message: 'Deseja anexar o arquivo "${file.name}" a este trâmite? Esta ação notificará o cliente.',
          confirmLabel: 'Anexar',
          onCancel: () => Navigator.pop(context, false),
          onConfirm: () => Navigator.pop(context, true),
        ),
      );

      if (confirm != true) return;
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enviando ${file.name}...')),
      );

      await ref.read(procedureActionsProvider).uploadDocument(
        processId: processId,
        filePath: file.path!,
        fileName: file.name,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arquivo enviado com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar arquivo: $e')),
      );
    }
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

  Future<void> _addNote(String processId, String note) async {
    try {
      await ref.read(procedureActionsProvider).addNote(processId: processId, note: note);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nota adicionada.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _requestDocument(String processId, String documentName) async {
    try {
      await ref.read(procedureActionsProvider).requestDocument(
        processId: processId,
        documentName: documentName,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação enviada.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _scheduleEvent(String processId, String title, DateTime date) async {
    try {
      await ref.read(procedureActionsProvider).scheduleEvent(
        processId: processId,
        title: title,
        date: date,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento agendado.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
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
    'DOCUMENT_REQUESTED' => 'Documento solicitado',
    'EVENT_SCHEDULED' => 'Evento agendado',
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
