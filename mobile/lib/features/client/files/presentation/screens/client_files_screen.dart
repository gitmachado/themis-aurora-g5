import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../features/procedures/domain/entities/legal_process.dart';
import '../../../../../../features/procedures/domain/entities/process_document.dart';
import '../../../../../../features/procedures/presentation/providers/procedure_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_dimensions.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/network/api_client.dart';
import '../../../../../../shared/utils/api_formatters.dart';
import '../../../../../../shared/widgets/app_app_bar_actions.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';

class ClientFilesScreen extends ConsumerStatefulWidget {
  const ClientFilesScreen({super.key});

  @override
  ConsumerState<ClientFilesScreen> createState() => _ClientFilesScreenState();
}

class _ClientFilesScreenState extends ConsumerState<ClientFilesScreen> {
  String _selectedFilter = 'Todos';
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final documents = ref.watch(myDocumentsProvider);
    final procedures = ref.watch(myProceduresProvider).valueOrNull ?? const [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Arquivos',
        showBackButton: false,
        actions: [AppAppBarActions(showChat: false)],
        showDivider: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: AppColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSecurityBanner(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Seus arquivos',
                        style: AppTextStyles.h2.copyWith(fontSize: 18),
                      ),
                      _buildFilterDropdown(),
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  color: AppColors.divider.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
          Expanded(
            child: documents.when(
              data: (items) => _buildFileList(items),
              loading: _buildLoadingList,
              error: (error, _) => _buildErrorState(error),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'client_file_fab',
        onPressed: _isUploading ? null : () => _pickAndUpload(procedures),
        backgroundColor: _isUploading
            ? AppColors.textCaption
            : AppColors.primary,
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
                color: AppColors.white,
                size: 28,
              ),
      ),
    );
  }

  Widget _buildSecurityBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Segurança garantida',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Envios e visualizações passam pelo backend autenticado.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.7)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFilter,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textCaption,
            size: 20,
          ),
          style: AppTextStyles.body.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          onChanged: (value) {
            if (value != null) setState(() => _selectedFilter = value);
          },
          items: const ['Todos', 'PDF', 'Imagem', 'Outros']
              .map(
                (value) =>
                    DropdownMenuItem<String>(value: value, child: Text(value)),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildFileList(List<ProcessDocument> documents) {
    final filtered = documents.where(_matchesFilter).toList();

    if (filtered.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.refresh(myDocumentsProvider.future),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            24,
            64,
            24,
            AppDimensions.bottomPadding(context),
          ),
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
              style: AppTextStyles.h2.copyWith(color: AppColors.textCaption),
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
          18,
          20,
          AppDimensions.bottomPadding(context),
        ),
        itemCount: filtered.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildDocumentTile(filtered[index]),
      ),
    );
  }

  Widget _buildDocumentTile(ProcessDocument document) {
    final isPdf = _documentType(document) == 'PDF';
    final iconColor = isPdf ? AppColors.error : AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.7)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isPdf ? Icons.picture_as_pdf_rounded : Icons.description_outlined,
            color: iconColor,
          ),
        ),
        title: Text(
          document.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          '${formatFileSize(document.sizeBytes)} • ${formatDateLabel(document.createdAt)}',
          style: AppTextStyles.caption.copyWith(fontSize: 12),
        ),
        trailing: const Icon(
          Icons.open_in_new_rounded,
          color: AppColors.textCaption,
        ),
        onTap: () => _openDocument(document),
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

  bool _matchesFilter(ProcessDocument document) {
    if (_selectedFilter == 'Todos') return true;
    return _documentType(document) == _selectedFilter;
  }

  String _documentType(ProcessDocument document) {
    final source = '${document.mimeType ?? ''} ${document.fileName}'
        .toLowerCase();
    if (source.contains('pdf')) return 'PDF';
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
            'Voce precisa ter um trâmite ativo para enviar arquivo.',
          ),
        ),
      );
      return;
    }

    final process = procedures.length == 1
        ? procedures.first
        : await _selectProcess(procedures);
    if (process == null) return;

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

    setState(() => _isUploading = true);
    try {
      await ref
          .read(procedureActionsProvider)
          .uploadDocument(
            processId: process.id,
            filePath: file.path!,
            fileName: file.name,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arquivo enviado com sucesso.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<LegalProcess?> _selectProcess(List<LegalProcess> procedures) {
    return showModalBottomSheet<LegalProcess>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Text('Escolha o trâmite', style: AppTextStyles.h2),
              const SizedBox(height: 12),
              for (final process in procedures)
                ListTile(
                  title: Text(process.title),
                  subtitle: Text(process.processNumber ?? process.id),
                  onTap: () => Navigator.pop(context, process),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openDocument(ProcessDocument document) async {
    final url = await ref
        .read(apiClientProvider)
        .getDocumentAccessUrl(document.id);
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nao foi possivel abrir o arquivo.')),
    );
  }
}
