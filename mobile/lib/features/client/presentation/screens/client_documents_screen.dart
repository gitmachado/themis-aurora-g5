import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/layout/app_screen_header.dart';
import '../../../../shared/widgets/cards/document_progress_tile.dart';

class ClientDocumentsScreen extends StatefulWidget {
  const ClientDocumentsScreen({super.key});

  @override
  State<ClientDocumentsScreen> createState() => _ClientDocumentsScreenState();
}

class _ClientDocumentsScreenState extends State<ClientDocumentsScreen> {
  String _selectedFilter = 'Todos';
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSecurityBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seus envios',
                  style: AppTextStyles.h2.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFilterDropdown(),
                    _buildViewToggleOptions(),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildDocumentList(),
          ),
        ],
      ),
    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUploadOptions(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: AppColors.white, size: 32),
      ),
    );
  }

  Widget _buildHeader() {
    return const AppScreenHeader(title: 'Documentos');
  }

  Widget _buildSecurityBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
            child: const Icon(Icons.verified_user_outlined, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Segurança garantida',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Dica: Os envios são criptografados',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
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
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFilter,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textCaption),
          style: AppTextStyles.body.copyWith(fontSize: 14),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => _selectedFilter = newValue);
            }
          },
          items: <String>['Todos', 'Enviado', 'Aprovado', 'Em análise']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                'Visualizar: $value',
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildViewToggleOptions() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.grid_view_outlined,
              color: _isGridView ? AppColors.primary : AppColors.textCaption,
              size: 20,
            ),
            onPressed: () => setState(() => _isGridView = true),
          ),
          Container(width: 1, height: 20, color: AppColors.divider),
          IconButton(
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.format_list_bulleted_rounded,
              color: !_isGridView ? AppColors.primary : AppColors.textCaption,
              size: 20,
            ),
            onPressed: () => setState(() => _isGridView = false),
          ),
        ],
      ),
    );
  }
  Widget _buildDocumentList() {
    // Mock data filtering
    final allDocs = [
      {'title': 'RG_Frente_Verso.pdf', 'status': 'Enviado', 'type': 'pdf', 'size': '1.2 MB'},
      {'title': 'Comprovante_Residencia.jpg', 'status': 'Aprovado', 'type': 'image', 'size': '3.4 MB'},
      {'title': 'Certidao_Nascimento.pdf', 'status': 'Solicitado', 'type': 'pdf', 'size': '2.1 MB'},
    ];

    final filteredDocs = _selectedFilter == 'Todos'
        ? allDocs
        : allDocs.where((doc) => doc['status'] == _selectedFilter).toList();

    if (_isGridView) {
      return _buildGridView(filteredDocs);
    }
    return _buildListView(filteredDocs);
  }

  Widget _buildGridView(List<Map<String, String>> docs) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final isPdf = doc['type'] == 'pdf';
        
        final iconColor = isPdf ? Colors.orange : AppColors.primary;
        final bgColor = isPdf ? const Color(0xFFFFF7E6) : const Color(0xFFF0F4FF);
        final statusColor = doc['status'] == 'Aprovado' ? AppColors.success : AppColors.primary;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Center(
                    child: Icon(
                      isPdf ? Icons.description_outlined : Icons.image_outlined,
                      color: iconColor,
                      size: 32,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc['title']!,
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          doc['size']!,
                          style: AppTextStyles.caption.copyWith(fontSize: 11),
                        ),
                        Text(
                          '08/04/26', // Mock date string to match layout
                          style: AppTextStyles.caption.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      doc['status']!,
                      style: AppTextStyles.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListView(List<Map<String, String>> docs) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      itemCount: docs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final doc = docs[index];
        final isPdf = doc['type'] == 'pdf';
        
        final iconColor = isPdf ? Colors.orange : AppColors.primary;
        final statusColor = doc['status'] == 'Aprovado' ? AppColors.success : AppColors.primary;

        return DocumentProgressTile(
          title: doc['title']!,
          status: '${doc['status']!} • ${doc['size']} • 08/04/2026',
          statusColor: statusColor,
          iconColor: iconColor,
          icon: isPdf ? Icons.description_outlined : Icons.image_outlined,
        );
      },
    );
  }

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Enviar documento', style: AppTextStyles.h2.copyWith(fontSize: 18)),
              const SizedBox(height: 24),
              _buildUploadOption(Icons.camera_alt_outlined, 'Tirar Foto'),
              const SizedBox(height: 12),
              _buildUploadOption(Icons.image_outlined, 'Galeria de Fotos'),
              const SizedBox(height: 12),
              _buildUploadOption(Icons.description_outlined, 'Arquivos do Dispositivo'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
                    ),
                  ),
                  child: Text(
                    'Cancelar',
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUploadOption(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
      onTap: () => Navigator.pop(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
    );
  }
}
