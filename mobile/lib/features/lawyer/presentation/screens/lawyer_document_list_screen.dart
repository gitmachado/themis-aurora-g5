import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';

class LawyerDocumentListScreen extends StatefulWidget {
  const LawyerDocumentListScreen({super.key});

  @override
  State<LawyerDocumentListScreen> createState() => _LawyerDocumentListScreenState();
}

class _LawyerDocumentListScreenState extends State<LawyerDocumentListScreen> {
  final List<Map<String, dynamic>> _documents = [
    {
      'id': '1',
      'name': 'Comprovante_Residencia.jpg',
      'client': 'Maria Oliveira',
      'date': '12/05/2024',
      'status': 'Aguardando Revisão',
      'type': 'image',
    },
    {
      'id': '2',
      'name': 'Contrato_Assinado_V2.pdf',
      'client': 'João Silva',
      'date': '10/05/2024',
      'status': 'Aguardando Revisão',
      'type': 'pdf',
    },
    {
      'id': '3',
      'name': 'RG_Frente_Verso.pdf',
      'client': 'Roberto Santos',
      'date': '08/05/2024',
      'status': 'Aguardando Revisão',
      'type': 'pdf',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Revisão de Documentos',
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _buildDocList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _buildFilterChip('Aguardando Revisão', true),
          const SizedBox(width: 8),
          _buildFilterChip('Aprovados', false),
          const SizedBox(width: 8),
          _buildFilterChip('Recusados', false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {},
      backgroundColor: AppColors.white,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.divider),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildDocList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _documents.length,
      itemBuilder: (context, index) {
        final doc = _documents[index];
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
                doc['type'] == 'pdf' ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
                color: AppColors.primary,
              ),
            ),
            title: Text(doc['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Cliente: ${doc['client']}', style: AppTextStyles.caption.copyWith(fontSize: 12)),
                const SizedBox(height: 2),
                Text('Recebido em: ${doc['date']}', style: AppTextStyles.caption.copyWith(fontSize: 11)),
              ],
            ),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textCaption),
            onTap: () => Navigator.pushNamed(context, '/lawyer-document-review'),
          ),
        );
      },
    );
  }
}
