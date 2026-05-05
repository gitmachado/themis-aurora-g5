import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../features/procedures/domain/entities/process_document.dart';
import '../../../../../../features/procedures/presentation/providers/procedure_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/network/api_client.dart';
import '../../../../../../shared/utils/api_formatters.dart';

class LawyerFileListScreen extends ConsumerStatefulWidget {
  const LawyerFileListScreen({super.key});

  @override
  ConsumerState<LawyerFileListScreen> createState() =>
      _LawyerFileListScreenState();
}

class _LawyerFileListScreenState extends ConsumerState<LawyerFileListScreen> {
  String _searchQuery = '';
  int _selectedIndex = 0;
  bool _gridMode = false;

  @override
  Widget build(BuildContext context) {
    final documents = ref.watch(myDocumentsProvider);

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Documentos',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: _gridMode ? 'Ver preview' : 'Visualizar em grade',
            icon: Icon(
              _gridMode ? Icons.view_agenda_rounded : Icons.grid_view_rounded,
            ),
            onPressed: () => setState(() => _gridMode = !_gridMode),
          ),
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(myDocumentsProvider),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: documents.when(
          data: _buildContent,
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.yellow),
          ),
          error: (error, _) => _buildErrorState(error),
        ),
      ),
    );
  }

  Widget _buildContent(List<ProcessDocument> files) {
    final filtered = files.where(_matchesSearch).toList();

    return Column(
      children: [
        _buildSearchField(),
        if (filtered.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'Nenhum documento encontrado.',
                style: AppTextStyles.body.copyWith(color: AppColors.white),
              ),
            ),
          )
        else
          Expanded(
            child: _gridMode
                ? _buildGrid(filtered)
                : _buildPreviewReader(filtered),
          ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
      child: TextField(
        onChanged: (value) => setState(() {
          _searchQuery = value;
          _selectedIndex = 0;
        }),
        style: AppTextStyles.body.copyWith(
          fontSize: 15.5,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        decoration: InputDecoration(
          hintText: 'Pesquisar documento...',
          hintStyle: AppTextStyles.body.copyWith(
            color: AppColors.white.withValues(alpha: 0.54),
            fontSize: 15.5,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.white.withValues(alpha: 0.62),
          ),
          filled: true,
          fillColor: AppColors.white.withValues(alpha: 0.08),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.white.withValues(alpha: 0.08),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.white.withValues(alpha: 0.08),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.yellow, width: 1.4),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewReader(List<ProcessDocument> files) {
    final selectedIndex = _selectedIndex.clamp(0, files.length - 1).toInt();
    final file = files[selectedIndex];

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: _DocumentPreview(
              key: ValueKey(file.id),
              file: file,
              accessUrl: ref
                  .read(apiClientProvider)
                  .getDocumentAccessUrl(file.id),
              onOpen: () => _openDocument(file),
            ),
          ),
        ),
        _buildReaderControls(files.length, selectedIndex),
      ],
    );
  }

  Widget _buildReaderControls(int count, int index) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.06),
        border: Border(
          top: BorderSide(color: AppColors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          _buildRoundControl(
            icon: Icons.chevron_left_rounded,
            onTap: index == 0
                ? null
                : () => setState(() => _selectedIndex = index - 1),
          ),
          Expanded(
            child: Text(
              '${index + 1} de $count',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _buildRoundControl(
            icon: Icons.chevron_right_rounded,
            onTap: index >= count - 1
                ? null
                : () => setState(() => _selectedIndex = index + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundControl({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: enabled
            ? AppColors.yellow
            : AppColors.white.withValues(alpha: 0.08),
        foregroundColor: enabled
            ? AppColors.ink
            : AppColors.white.withValues(alpha: 0.32),
        fixedSize: const Size.square(48),
      ),
    );
  }

  Widget _buildGrid(List<ProcessDocument> files) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return _DocumentGridTile(
          file: file,
          isSelected: index == _selectedIndex,
          onTap: () => setState(() {
            _selectedIndex = index;
            _gridMode = false;
          }),
        );
      },
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          error.toString(),
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: AppColors.errorBackground),
        ),
      ),
    );
  }

  bool _matchesSearch(ProcessDocument file) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return true;

    return [
      file.fileName,
      file.legalProcessId,
      file.mimeType ?? '',
      formatFileSize(file.sizeBytes),
      formatDateLabel(file.createdAt),
    ].join(' ').toLowerCase().contains(query);
  }

  Future<void> _openDocument(ProcessDocument document) async {
    try {
      final url = await ref
          .read(apiClientProvider)
          .getDocumentAccessUrl(document.id);
      final uri = Uri.parse(Uri.encodeFull(url));
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return;
    } catch (_) {
      // fall through to error snackbar
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nao foi possivel abrir o arquivo.')),
    );
  }
}

class _DocumentPreview extends StatelessWidget {
  final ProcessDocument file;
  final Future<String> accessUrl;
  final VoidCallback onOpen;

  const _DocumentPreview({
    super.key,
    required this.file,
    required this.accessUrl,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder<String>(
              future: accessUrl,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.yellow),
                  );
                }

                final url = snapshot.data;
                if (url != null && _isImage(file)) {
                  return InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4,
                    child: Image.network(
                      url,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => _buildDocumentShell(),
                    ),
                  );
                }

                return _buildDocumentShell();
              },
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildDocumentShell() {
    final isPdf = _isPdf(file);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 92,
            height: 116,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: Icon(
              isPdf ? Icons.picture_as_pdf_rounded : Icons.description_rounded,
              size: 44,
              color: isPdf ? AppColors.error : AppColors.ink,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            file.fileName,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            '${formatFileSize(file.sizeBytes)} • ${formatDateLabel(file.createdAt)}',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  file.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Trâmite: ${file.legalProcessId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: const Text('Abrir'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.yellow,
              foregroundColor: AppColors.ink,
              textStyle: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentGridTile extends StatelessWidget {
  final ProcessDocument file;
  final bool isSelected;
  final VoidCallback onTap;

  const _DocumentGridTile({
    required this.file,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPdf = _isPdf(file);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppColors.yellow
                : AppColors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Transform.rotate(
                  angle: isPdf ? -math.pi / 60 : 0,
                  child: Container(
                    width: 72,
                    height: 94,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isPdf
                          ? Icons.picture_as_pdf_rounded
                          : Icons.description_rounded,
                      color: isPdf ? AppColors.error : AppColors.ink,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              file.fileName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatFileSize(file.sizeBytes),
              style: AppTextStyles.tiny.copyWith(
                color: AppColors.white.withValues(alpha: 0.62),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool _isImage(ProcessDocument file) {
  final mimeOrName = (file.mimeType ?? file.fileName).toLowerCase();
  return mimeOrName.contains('image/') ||
      mimeOrName.endsWith('.png') ||
      mimeOrName.endsWith('.jpg') ||
      mimeOrName.endsWith('.jpeg') ||
      mimeOrName.endsWith('.webp');
}

bool _isPdf(ProcessDocument file) {
  return (file.mimeType ?? file.fileName).toLowerCase().contains('pdf');
}
