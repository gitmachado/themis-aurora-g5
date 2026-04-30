import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../features/procedures/domain/entities/process_document.dart';
import '../../../../../../features/procedures/presentation/providers/procedure_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/network/api_client.dart';
import '../../../../../../shared/utils/api_formatters.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';

class LawyerFileListScreen extends ConsumerWidget {
  const LawyerFileListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documents = ref.watch(myDocumentsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Arquivos', showBackButton: true),
      body: documents.when(
        data: (items) => _buildFileList(context, ref, items),
        loading: _buildLoadingList,
        error: (error, _) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildFileList(
    BuildContext context,
    WidgetRef ref,
    List<ProcessDocument> files,
  ) {
    if (files.isEmpty) {
      return Center(
        child: Text('Nenhum arquivo encontrado.', style: AppTextStyles.body),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(myDocumentsProvider.future),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          return _buildFileTile(context, ref, file);
        },
      ),
    );
  }

  Widget _buildFileTile(
    BuildContext context,
    WidgetRef ref,
    ProcessDocument file,
  ) {
    final isPdf = (file.mimeType ?? file.fileName).toLowerCase().contains(
      'pdf',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
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
        title: Text(
          file.fileName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Trâmite: ${file.legalProcessId}',
              style: AppTextStyles.caption.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              '${formatFileSize(file.sizeBytes)} • ${formatDateLabel(file.createdAt)}',
              style: AppTextStyles.caption.copyWith(fontSize: 11),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textCaption,
        ),
        onTap: () => _openDocument(context, ref, file),
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
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

  Future<void> _openDocument(
    BuildContext context,
    WidgetRef ref,
    ProcessDocument document,
  ) async {
    final url = await ref
        .read(apiClientProvider)
        .getDocumentAccessUrl(document.id);
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nao foi possivel abrir o arquivo.')),
    );
  }
}
