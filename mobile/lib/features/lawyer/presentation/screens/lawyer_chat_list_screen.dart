import 'package:flutter/material.dart';
import '../../../../app/routes/app_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';

class LawyerChatListScreen extends StatefulWidget {
  const LawyerChatListScreen({super.key});

  @override
  State<LawyerChatListScreen> createState() => _LawyerChatListScreenState();
}

class _LawyerChatListScreenState extends State<LawyerChatListScreen> {
  final List<Map<String, dynamic>> _chats = [
    {
      'clientName': 'Roberto Santos',
      'lastMessage': 'Tenho uma dúvida sobre a última petição.',
      'time': 'há 5 min',
      'status': 'HANDOFF_PENDING',
      'initials': 'RS',
    },
    {
      'clientName': 'Maria Oliveira',
      'lastMessage': 'Obrigada pelos esclarecimentos.',
      'time': 'há 1 hora',
      'status': 'ACTIVE',
      'initials': 'MO',
    },
    {
      'clientName': 'João Silva',
      'lastMessage': 'O processo já foi protocolado?',
      'time': 'há 3 horas',
      'status': 'HANDOFF_PENDING',
      'initials': 'JS',
    },
    {
      'clientName': 'Ana Paula',
      'lastMessage': 'Dúvida sobre os documentos enviados.',
      'time': 'há 5 horas',
      'status': 'HANDOFF_PENDING',
      'initials': 'AP',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Mensagens e Handoffs',
        showBackButton: true,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildChatList()),
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
          _buildFilterChip('Aguardando Handoff', true),
          const SizedBox(width: 8),
          _buildFilterChip('Em Atendimento', false),
          const SizedBox(width: 8),
          _buildFilterChip('Finalizados', false),
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

  Widget _buildChatList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _chats.length,
      itemBuilder: (context, index) {
        final chat = _chats[index];
        final bool isHandoff = chat['status'] == 'HANDOFF_PENDING';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isHandoff ? AppColors.warningOverlay : AppColors.divider,
              width: isHandoff ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryOverlay,
                  child: Text(
                    chat['initials'], 
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                if (isHandoff)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(chat['clientName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(chat['time'], style: AppTextStyles.caption.copyWith(fontSize: 12)),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  chat['lastMessage'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(fontSize: 14),
                ),
                if (isHandoff) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.warningOverlay,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'IA SOLICITOU INTERVENÇÃO',
                      style: TextStyle(
                        color: AppColors.warning, 
                        fontSize: 10, 
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRouter.lawyerChatHandoffRoute,
                arguments: {'clientName': chat['clientName']},
              );
            },
          ),
        );
      },
    );
  }
}
