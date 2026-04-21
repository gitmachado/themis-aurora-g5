import 'package:flutter/material.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/cards/app_notification_tile.dart';

class LawyerNotificationScreen extends StatefulWidget {
  const LawyerNotificationScreen({super.key});

  @override
  State<LawyerNotificationScreen> createState() =>
      _LawyerNotificationScreenState();
}

class _LawyerNotificationScreenState extends State<LawyerNotificationScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Novo Lead Urgente',
      'body': 'Carla Menezes solicitou triagem para caso Trabalhista.',
      'time': 'há 2 min',
      'isRead': false,
      'type': 'lead',
    },
    {
      'id': '2',
      'title': 'Documento Recebido',
      'body': 'Maria Oliveira enviou o comprovante de residência.',
      'time': 'há 1 hora',
      'isRead': false,
      'type': 'doc',
    },
    {
      'id': '3',
      'title': 'Audiência Amanhã',
      'body': 'Lembrete: Audiência do processo 1023456-88 às 14:00.',
      'time': 'há 3 horas',
      'isRead': true,
      'type': 'process',
    },
    {
      'id': '4',
      'title': 'Handoff de Chat',
      'body': 'O bot solicitou sua intervenção no chat com Roberto Santos.',
      'time': 'há 5 horas',
      'isRead': true,
      'type': 'chat',
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
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textCaption,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'Não lidas'),
              Tab(text: 'Todas'),
            ],
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
          Icon(
            Icons.notifications_none_rounded,
            size: 64,
            color: AppColors.textCaption.withValues(alpha: 0.3),
          ),
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
