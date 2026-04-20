import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/widgets/layout/app_screen_header.dart';
import '../widgets/chat_list_tile.dart';

class ClientChatsScreen extends StatefulWidget {
  const ClientChatsScreen({super.key});

  @override
  State<ClientChatsScreen> createState() => _ClientChatsScreenState();
}

class _ClientChatsScreenState extends State<ClientChatsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  ChatListTile(
                    title: 'Assistente Jurídico',
                    subtitle: 'Seu processo está na fase...',
                    time: 'Agora',
                    unreadCount: 1,
                    isAi: true,
                    onTap: () => Navigator.pushNamed(context, '/chat-mirror'),
                  ),
                  const SizedBox(height: 12),
                  ChatListTile(
                    title: 'Equipe OmniConnect',
                    subtitle: 'Documentos recebidos...',
                    time: 'Ontem',
                    unreadCount: 0,
                    isAi: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_comment_outlined, color: AppColors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return AppScreenHeader(
      title: 'Mensagens',
      action: Container(
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.search_outlined, color: AppColors.textPrimary),
          onPressed: () {},
        ),
      ),
    );
  }

}
