import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../constants/app_colors.dart';
import 'custom_app_bar.dart';

class AppFileViewer extends ConsumerStatefulWidget {
  final String fileUrl;
  final String fileName;
  final String? mimeType;

  const AppFileViewer({
    super.key,
    required this.fileUrl,
    required this.fileName,
    this.mimeType,
  });

  @override
  ConsumerState<AppFileViewer> createState() => _AppFileViewerState();
}

class _AppFileViewerState extends ConsumerState<AppFileViewer> {
  String? _localPath;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeViewer();
  }

  Future<void> _initializeViewer() async {
    await _downloadFile();
  }

  Future<void> _downloadFile() async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${widget.fileName}');
      
      if (await file.exists()) {
        setState(() {
          _localPath = file.path;
          _isLoading = false;
        });
        return;
      }

      final dio = ref.read(apiClientProvider);
      await dio.downloadFile(widget.fileUrl, file.path);

      if (mounted) {
        setState(() {
          _localPath = file.path;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erro ao baixar o arquivo: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isImage = widget.mimeType?.startsWith('image/') ?? 
                    (widget.fileName.toLowerCase().endsWith('.jpg') || 
                     widget.fileName.toLowerCase().endsWith('.png') || 
                     widget.fileName.toLowerCase().endsWith('.jpeg'));
    
    final isPdf = widget.mimeType == 'application/pdf' || widget.fileName.toLowerCase().endsWith('.pdf');

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: CustomAppBar(
          title: widget.fileName,
          backgroundColor: AppColors.surface,
          showBackButton: true,
        ),
        body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.yellow))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : isImage && _localPath != null
                  ? Center(
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Image.file(
                          File(_localPath!),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.error_outline, color: Colors.white, size: 48),
                          ),
                        ),
                      ),
                    )
                  : isPdf && _localPath != null
                      ? PDFView(
                          filePath: _localPath,
                          enableSwipe: true,
                          swipeHorizontal: false,
                          autoSpacing: true,
                          pageFling: true,
                          onRender: (pages) {
                            debugPrint('PDF Renderizado com $pages páginas');
                          },
                          onError: (error) {
                            setState(() {
                              _errorMessage = 'Erro ao carregar PDF: $error';
                            });
                          },
                          onPageError: (page, error) {
                            debugPrint('Erro na página $page: $error');
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.insert_drive_file_outlined, color: Colors.white, size: 64),
                              const SizedBox(height: 16),
                              const Text(
                                'Tipo de arquivo não suportado para visualização direta.',
                                style: TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.yellow,
                                  foregroundColor: AppColors.ink,
                                ),
                                child: const Text('Voltar'),
                              ),
                            ],
                          ),
                        ),
      ),
    );
  }
}
