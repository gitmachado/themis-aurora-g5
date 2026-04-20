import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../shared/widgets/cards/app_notification_tile.dart';

class ClientNotificationsScreen extends StatefulWidget {
  const ClientNotificationsScreen({super.key});

  @override
  State<ClientNotificationsScreen> createState() => _ClientNotificationsScreenState();
}

class _ClientNotificationsScreenState extends State<ClientNotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Nova movimentação',
      'body': 'O juiz emitiu um despacho no processo Ação Indenizatória.',
      'time': 'há 5 min',
      'isRead': false,
      'type': 'process',
    },
    {
      'id': '2',
      'title': 'Documento recebido',
      'body': 'Sua folha de pagamento foi anexada com sucesso.',
      'time': 'há 2 horas',
      'isRead': true,
      'type': 'doc',
    },
    {
      'id': '3',
      'title': 'Audiência marcada',
      'body': 'Sua audiência cível foi agendada para 15/05 as 14:00.',
      'time': 'Ontem',
      'isRead': true,
      'type': 'process',
    },
  ];

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
              onPressed: () {
                setState(() {
                  for (var n in _notifications) {
                    n['isRead'] = true;
                  }
                });
              },
              child: const Text('Lidas', style: TextStyle(color: AppColors.primary)),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Não lidas'),
              Tab(text: 'Todas'),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textCaption,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
          ),
        ),
        body: TabBarView(
          children: [
            _buildNotificationList(onlyUnread: true),
            _buildNotificationList(onlyUnread: false),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList({required bool onlyUnread}) {
    final list = onlyUnread 
        ? _notifications.where((n) => !n['isRead']).toList() 
        : _notifications;

    if (list.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final n = list[index];
        return AppNotificationTile(
          id: n['id'],
          title: n['title'],
          body: n['body'],
          time: n['time'],
          type: n['type'],
          isRead: n['isRead'],
          onToggleRead: _toggleReadStatus,
          onDelete: _deleteNotification,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 64, color: AppColors.textCaption.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'Nenhuma notificação por aqui',
            style: AppTextStyles.h2.copyWith(color: AppColors.textCaption),
          ),
        ],
      ),
    );
  }

  void _toggleReadStatus(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notifications[index]['isRead'] = !_notifications[index]['isRead'];
      }
    });
  }

  void _deleteNotification(String id) {
    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index == -1) return;
    
    final removed = _notifications[index];
    setState(() {
      _notifications.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notificação excluída'),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () {
            setState(() {
              _notifications.insert(index, removed);
            });
          },
        ),
      ),
    );
  }
}
