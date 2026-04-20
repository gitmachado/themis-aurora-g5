import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
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
      appBar: const CustomAppBar(
        title: 'Mensagens',
        showBackButton: false,
        showNotificationButton: true,
        notificationCount: 2,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'client_chat_fab',
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_comment_outlined, color: AppColors.white),
      ),
    );
  }



}
