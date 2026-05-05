import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../../../features/procedures/domain/entities/legal_process.dart';
import '../../../../../../features/procedures/domain/entities/process_document.dart';
import '../../../../../../features/procedures/presentation/procedure_display.dart';
import '../../../../../../features/procedures/presentation/providers/procedure_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_dimensions.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/network/api_client.dart';
import '../../../../../../shared/utils/api_formatters.dart';
import '../../../../../../shared/widgets/app_app_bar_actions.dart';
import '../../../../../../shared/widgets/cards/file_card.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/layout/app_file_viewer.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';

class ClientFilesScreen extends ConsumerStatefulWidget {
  const ClientFilesScreen({super.key});

  @override
  ConsumerState<ClientFilesScreen> createState() => _ClientFilesScreenState();
}

class _ClientFilesScreenState extends ConsumerState<ClientFilesScreen> {
  final ScrollController _processScrollController = ScrollController();
  String _selectedFilter = 'Todos';
  String? _selectedProcessId;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _processScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final documents = ref.watch(myDocumentsProvider);
    final account = ref.watch(currentAccountProvider).valueOrNull;
    final allProcedures =
        ref.watch(myProceduresProvider).valueOrNull ?? const <LegalProcess>[];
    final procedures = account == null
        ? const <LegalProcess>[]
        : allProcedures
              .where((process) => process.clientId == account.id)
              .toList();

    // Auto-selecionar o primeiro processo se nada estiver selecionado
    if (_selectedProcessId == null && procedures.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedProcessId == null) {
          setState(() => _selectedProcessId = procedures.first.id);
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Documentos',
        showBackButton: false,
        actions: [AppAppBarActions(showChat: false)],
        showDivider: false,
        backgroundColor: AppColors.white,
      ),
      body: documents.when(
        data: (items) {
          // Calcular categorias dinâmicas presentes nos documentos
          final uniqueCategories = items
              .map((doc) {
                final isImage = doc.mimeType?.startsWith('image/') ?? false;
                final isPdf = doc.mimeType == 'application/pdf';
                if (isImage) return 'Imagem';
                if (isPdf) return 'Pdf';
                return 'Outros';
              })
              .toSet()
              .toList();

          final showFilters = uniqueCategories.length > 1;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(bottom: BorderSide(color: AppColors.divider)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (procedures.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Text(
                          'Selecione o Processo',
                          style: AppTextStyles.tiny.copyWith(
                            color: AppColors.ink3,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        controller: _processScrollController,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            const SizedBox(width: 20),
                            ...procedures.map(
                              (p) => Builder(
                                builder: (context) => Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: _buildProcessTab(
                                    p,
                                    isSelected: _selectedProcessId == p.id,
                                    onTap: () {
                                      setState(() => _selectedProcessId = p.id);
                                      Scrollable.ensureVisible(
                                        context,
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                        alignment: 0.5,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ],
                    if (showFilters) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                        child: Text(
                          'Selecione o Tipo',
                          style: AppTextStyles.tiny.copyWith(
                            color: AppColors.ink3,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            const SizedBox(width: 20),
                            _buildFilterChip(
                              'Todos',
                              isSelected: _selectedFilter == 'Todos',
                              onTap: () =>
                                  setState(() => _selectedFilter = 'Todos'),
                            ),
                            ...uniqueCategories.map(
                              (cat) => Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: _buildFilterChip(
                                  cat,
                                  isSelected: _selectedFilter == cat,
                                  onTap: () =>
                                      setState(() => _selectedFilter = cat),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (_isUploading)
                LinearProgressIndicator(
                  value: _uploadProgress,
                  backgroundColor: AppColors.yellowSoft,
                  color: AppColors.yellow,
                  minHeight: 3,
                ),
              Expanded(child: _buildFileList(items, procedures, showFilters)),
            ],
          );
        },
        loading: _buildLoadingList,
        error: (_, _) => _buildErrorState(),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'client_file_fab',
        onPressed: _isUploading ? null : () => _pickAndUpload(procedures),
        backgroundColor: _isUploading
            ? AppColors.textCaption
            : AppColors.yellow,
        child: _isUploading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : const Icon(
                Icons.upload_file_rounded,
                color: AppColors.ink,
                size: 28,
              ),
      ),
    );
  }

  Widget _buildProcessTab(
    LegalProcess process, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface2,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.divider.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              process.icon,
              size: 18,
              color: isSelected ? AppColors.white : AppColors.ink3,
            ),
            const SizedBox(width: 8),
            Text(
              process.title,
              style: AppTextStyles.body.copyWith(
                color: isSelected ? AppColors.white : AppColors.ink2,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.yellow : AppColors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? AppColors.yellow : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFileList(
    List<ProcessDocument> documents,
    List<LegalProcess> procedures,
    bool hasFilters,
  ) {
    final filtered = documents
        .where(
          (doc) => _matchesFilter(doc, _selectedFilter, _selectedProcessId),
        )
        .toList();

    // Map para busca rapida de processos
    final processMap = {for (var p in procedures) p.id: p};

    if (filtered.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.refresh(myDocumentsProvider.future),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open_rounded,
                        size: 64,
                        color: AppColors.textCaption.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum arquivo encontrado',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.textCaption,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(myDocumentsProvider.future),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          20,
          hasFilters ? 14 : 16,
          20,
          AppDimensions.bottomPadding(context),
        ),
        itemCount: filtered.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final document = filtered[index];
          final isImage = document.mimeType?.startsWith('image/') ?? false;
          final isPdf = document.mimeType == 'application/pdf';

          String displayCategory = 'Arquivo';
          if (isImage) displayCategory = 'Imagem';
          if (isPdf) displayCategory = 'PDF';

          return AppFileCard(
            fileName: document.fileName,
            fileSize: formatFileSize(document.sizeBytes),
            dateAdded: formatDateLabel(document.createdAt),
            category: displayCategory,
            subtitle: processMap[document.legalProcessId] != null
                ? '${processMap[document.legalProcessId]!.title} • ${processMap[document.legalProcessId]!.processNumber ?? 'N/A'}'
                : null,
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
            onTap: () => _openDocument(document),
          );
        },
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) =>
          const LoadingSkeleton(height: 78, borderRadius: 16),
    );
  }

  Widget _buildErrorState() {
    return RefreshIndicator(
      onRefresh: () => ref.refresh(myDocumentsProvider.future),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          24,
          88,
          24,
          AppDimensions.bottomPadding(context),
        ),
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 58,
            color: AppColors.error.withValues(alpha: 0.72),
          ),
          const SizedBox(height: 18),
          Text(
            'Não foi possível carregar seus documentos',
            textAlign: TextAlign.center,
            style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'A conexão com o servidor falhou ou a sessão precisa ser atualizada.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textCaption,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: FilledButton.icon(
              onPressed: () => ref.invalidate(myDocumentsProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
            ),
          ),
        ],
      ),
    );
  }

  bool _matchesFilter(ProcessDocument doc, String category, String? processId) {
    // Filtro de processo
    if (processId != null && doc.legalProcessId != processId) return false;

    // Filtro de categoria
    if (category == 'Todos') return true;

    return _documentType(doc) == category;
  }

  String _documentType(ProcessDocument document) {
    final source = '${document.mimeType ?? ''} ${document.fileName}'
        .toLowerCase();
    if (source.contains('pdf')) return 'Pdf';
    if (source.contains('image') ||
        source.endsWith('.png') ||
        source.endsWith('.jpg') ||
        source.endsWith('.jpeg')) {
      return 'Imagem';
    }
    return 'Outros';
  }

  Future<void> _pickAndUpload(List<LegalProcess> procedures) async {
    if (procedures.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Voce precisa ter um tramite ativo para enviar arquivo.',
          ),
        ),
      );
      return;
    }

    final process = procedures.cast<LegalProcess>().firstWhere(
      (p) => p.id == _selectedProcessId,
      orElse: () => procedures.first,
    );

    // Modal de confirmacao elegante
    final confirmed = await _showUploadConfirmation(process);

    if (confirmed != true) return;

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const [
        'pdf',
        'png',
        'jpg',
        'jpeg',
        'heic',
        'heif',
        'doc',
        'docx',
        'xls',
        'xlsx',
      ],
      withData: false,
    );

    final file = result?.files.single;
    if (file == null || file.path == null) return;

    // Validacao de tamanho (10MB) - PRD 2.2
    const maxBytes = 10 * 1024 * 1024;
    if (file.size > maxBytes) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O arquivo excede o limite de 10MB.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      await ref
          .read(procedureActionsProvider)
          .uploadDocument(
            processId: process.id,
            filePath: file.path!,
            fileName: file.name,
            onSendProgress: (count, total) {
              if (total > 0) {
                setState(() => _uploadProgress = count / total);
              }
            },
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arquivo enviado com sucesso.')),
      );
      // Atualizar lista
      ref.invalidate(myDocumentsProvider);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  Future<bool?> _showUploadConfirmation(LegalProcess process) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.yellowSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.upload_file_rounded,
                    color: AppColors.yellowDeep,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text('Confirmar Envio', style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Text(
                  'Voce esta prestes a adicionar um arquivo ao processo:',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(color: AppColors.ink3),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Icon(process.icon, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              process.title,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.ink,
                              ),
                            ),
                            if (process.processNumber != null)
                              Text(
                                'Nº ${process.processNumber}',
                                style: AppTextStyles.tiny.copyWith(
                                  color: AppColors.ink3,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.ink,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.yellow,
                          foregroundColor: AppColors.ink,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Prosseguir'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openDocument(ProcessDocument document) async {
    try {
      final url = await ref
          .read(apiClientProvider)
          .getDocumentAccessUrl(document.id);

      if (!mounted) return;

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
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nao foi possivel abrir o arquivo: $error')),
      );
    }
  }
}
