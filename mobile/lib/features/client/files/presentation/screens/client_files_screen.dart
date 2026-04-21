import 'package:flutter/material.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/constants/app_dimensions.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/cards/file_progress_tile.dart';

class ClientFilesScreen extends StatefulWidget {
  const ClientFilesScreen({super.key});

  @override
  State<ClientFilesScreen> createState() => _ClientFilesScreenState();
}

class _ClientFilesScreenState extends State<ClientFilesScreen> {
  String _selectedFilter = 'Todos';
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Arquivos',
        showBackButton: false,
        showNotificationButton: true,
        notificationCount: 2,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seus arquivos',
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
                Container(
                  height: 1,
                  color: AppColors.divider.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildFileList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'client_file_fab',
        onPressed: () => _showUploadOptions(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: AppColors.white, size: 32),
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
            child: const Icon(Icons.verified_user_outlined, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Segurança garantida',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  'Dica: Os envios são criptografados',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
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
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textCaption, size: 20),
          style: AppTextStyles.body.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => _selectedFilter = newValue);
            }
          },
          items: <String>['Todos', 'Enviado', 'Aprovado', 'Em análise']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text('Filtro: $value'),
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
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.7)),
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
              size: 18,
            ),
            onPressed: () => setState(() => _isGridView = true),
          ),
          Container(width: 1, height: 16, color: AppColors.divider),
          IconButton(
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.format_list_bulleted_rounded,
              color: !_isGridView ? AppColors.primary : AppColors.textCaption,
              size: 18,
            ),
            onPressed: () => setState(() => _isGridView = false),
          ),
        ],
      ),
    );
  }

  Widget _buildFileList() {
    final allFiles = [
      {'title': 'RG_Frente_Verso.pdf', 'status': 'Enviado', 'type': 'pdf', 'size': '1.2 MB'},
      {'title': 'Comprovante_Residencia.jpg', 'status': 'Aprovado', 'type': 'image', 'size': '3.4 MB'},
      {'title': 'Certidao_Nascimento.pdf', 'status': 'Solicitado', 'type': 'pdf', 'size': '2.1 MB'},
    ];

    final filteredFiles = _selectedFilter == 'Todos'
        ? allFiles
        : allFiles.where((doc) => doc['status'] == _selectedFilter).toList();

    if (_isGridView) {
      return GridView.builder(
        padding: EdgeInsets.fromLTRB(20, 18, 20, AppDimensions.bottomPadding(context)),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: filteredFiles.length,
        itemBuilder: (context, index) {
          final file = filteredFiles[index];
          final isPdf = file['type'] == 'pdf';
          final iconColor = isPdf ? Colors.orange : AppColors.primary;
          final bgColor = isPdf ? const Color(0xFFFFF7E6) : const Color(0xFFF0F4FF);
          final statusColor = file['status'] == 'Aprovado' ? AppColors.success : AppColors.primary;

          return Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider.withValues(alpha: 0.7)),
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
                        file['title']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${file['size']} • 08/04/26',
                        style: AppTextStyles.caption.copyWith(fontSize: 10),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        file['status']!,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
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

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20, 18, 20, AppDimensions.bottomPadding(context)),
      itemCount: filteredFiles.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final file = filteredFiles[index];
        final isPdf = file['type'] == 'pdf';
        final iconColor = isPdf ? Colors.orange : AppColors.primary;
        final statusColor = file['status'] == 'Aprovado' ? AppColors.success : AppColors.primary;

        return FileProgressTile(
          title: file['title']!,
          status: '${file['status']!} • ${file['size']} • 08/04/2026',
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
              Text('Enviar arquivo', style: AppTextStyles.h2.copyWith(fontSize: 18)),
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

