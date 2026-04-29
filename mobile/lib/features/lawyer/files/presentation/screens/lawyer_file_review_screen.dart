import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../features/procedures/domain/entities/process_document.dart';
import '../../../../../../features/procedures/presentation/providers/procedure_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/network/api_client.dart';
import '../../../../../../shared/utils/api_formatters.dart';
import '../../../../../../shared/widgets/cards/app_card.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';

class LawyerFileReviewScreen extends ConsumerWidget {
  final String? documentId;

  const LawyerFileReviewScreen({super.key, this.documentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final document = documentId == null || documentId!.isEmpty
        ? null
        : ref.watch(documentDetailsProvider(documentId!));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Arquivo', showBackButton: true),
      body: document == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Selecione um arquivo real pela lista de arquivos.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textCaption,
                  ),
                ),
              ),
            )
          : document.when(
              data: (item) => _buildDocumentDetails(context, ref, item),
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: LoadingSkeleton(height: 220, borderRadius: 16),
              ),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(color: AppColors.error),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDocumentDetails(
    BuildContext context,
    WidgetRef ref,
    ProcessDocument document,
  ) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      document.fileName,
                      style: AppTextStyles.h2.copyWith(fontSize: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildMetadataRow('Trâmite', document.legalProcessId),
              _buildMetadataRow('Tamanho', formatFileSize(document.sizeBytes)),
              _buildMetadataRow('Tipo', document.mimeType ?? 'Nao informado'),
              _buildMetadataRow(
                'Enviado em',
                formatDateLabel(document.createdAt),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _openDocument(context, ref, document),
          icon: const Icon(Icons.open_in_new_rounded, color: Colors.white),
          label: const Text(
            'Abrir arquivo',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 92, child: Text(label, style: AppTextStyles.caption)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDocument(
    BuildContext context,
    WidgetRef ref,
    ProcessDocument document,
  ) async {
    final uri = Uri.parse(
      await ref.read(apiClientProvider).getDocumentAccessUrl(document.id),
    );

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
