import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';

class ClientNotificationsScreen extends StatelessWidget {
  const ClientNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Notificações',
          showBackButton: true,
          actions: [
            TextButton(
              onPressed: () {},
              child: const Text('Limpar', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
        body: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Não lidas'),
                Tab(text: 'Todas'),
              ],
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textCaption,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildNotificationList(onlyUnread: true),
                  _buildNotificationList(onlyUnread: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList({required bool onlyUnread}) {
    final notifications = [
      {
        'title': 'Nova movimentação',
        'body': 'O juiz emitiu um despacho no processo Ação Indenizatória.',
        'time': 'há 5 min',
        'isRead': false,
        'icon': Icons.notifications_none_outlined,
      },
      {
        'title': 'Documento recebido',
        'body': 'Sua folha de pagamento foi anexada com sucesso.',
        'time': 'há 2 horas',
        'isRead': true,
        'icon': Icons.description_outlined,
      },
      {
        'title': 'Audiência marcada',
        'body': 'Sua audiência cível foi agendada para 15/05 as 14:00.',
        'time': 'Ontem',
        'isRead': true,
        'icon': Icons.event_note_outlined,
      },
    ];

    final list = onlyUnread ? notifications.where((n) => !(n['isRead'] as bool)).toList() : notifications;

    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final n = list[index];
        final isRead = n['isRead'] as bool;

        return Container(
          color: isRead ? Colors.transparent : const Color(0xFFE8EAF6),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(n['icon'] as IconData, color: AppColors.primary, size: 20),
                    if (!isRead)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          n['title'] as String,
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          n['time'] as String,
                          style: AppTextStyles.caption.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n['body'] as String,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14,
                        color: AppColors.textCaption,
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
}
