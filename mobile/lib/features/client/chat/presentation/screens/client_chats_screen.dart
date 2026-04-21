import 'package:flutter/material.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_dimensions.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
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
              padding: EdgeInsets.fromLTRB(
                AppDimensions.spacingL,
                AppDimensions.spacingL,
                AppDimensions.spacingL,
                AppDimensions.bottomPadding(context),
              ),


              children: [
                ChatListTile(
                  title: 'Assistente Jurídico',
                  subtitle: 'Olá! Sou seu assistente para o trâmite #1234...',

                  time: '10:30',
                  unreadCount: 2,
                  isAi: true,
                  onTap: () {},
                ),
                ChatListTile(
                  title: 'Dr. Rodrigo Machado',
                  subtitle: 'O novo documento foi anexado ao sistema.',
                  time: 'Ontem',
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
