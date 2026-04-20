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
        centerTitle: true,
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
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isHandoff ? AppColors.warning.withValues(alpha: 0.3) : AppColors.divider),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(chat['initials'], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
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
                Text(chat['clientName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(chat['time'], style: AppTextStyles.caption.copyWith(fontSize: 11)),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  chat['lastMessage'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(fontSize: 13),
                ),
                if (isHandoff) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'IA SOLICITOU INTERVENÇÃO',
                      style: TextStyle(color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.bold),
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
