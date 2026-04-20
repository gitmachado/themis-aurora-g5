import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_dimensions.dart';
import '../../../../shared/constants/app_text_styles.dart';
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenPadding,
                  vertical: AppDimensions.contentPadding,
                ),
                children: [
                  ChatListTile(
                    title: 'Assistente Jurídico',
                    subtitle: 'Seu processo está na fase...',
                    time: 'Agora',
                    unreadCount: 1,
                    isAi: true,
                    onTap: () => Navigator.pushNamed(context, '/chat-mirror'),
                  ),
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
      floatingActionButton: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: const Icon(Icons.add_comment, color: AppColors.white, size: 24),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const AppScreenHeader(
      title: 'Mensagens',
      padding: EdgeInsets.fromLTRB(
        AppDimensions.screenPadding,
        AppDimensions.spacingM,
        AppDimensions.screenPadding,
        0,
      ),
    );
  }

}
