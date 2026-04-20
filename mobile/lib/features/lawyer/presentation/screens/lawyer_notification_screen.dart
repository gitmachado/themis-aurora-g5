import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';

class LawyerNotificationScreen extends StatefulWidget {
  const LawyerNotificationScreen({super.key});

  @override
  State<LawyerNotificationScreen> createState() => _LawyerNotificationScreenState();
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
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            'Notificações',
            style: AppTextStyles.h2.copyWith(color: AppColors.primary),
          ),
          centerTitle: true,
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
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final notification = list[index];
        return _buildDismissibleItem(notification, index, onlyUnread);
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

  Widget _buildDismissibleItem(Map<String, dynamic> notification, int index, bool onlyUnread) {
    final bool isRead = notification['isRead'];

    return Dismissible(
      key: Key('notif_${notification['id']}_$onlyUnread'),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _deleteNotification(notification['id']);
        } else {
          _toggleReadStatus(notification['id']);
        }
      },
      background: _buildSwipeBackground(
        color: isRead ? AppColors.textCaption : AppColors.primary,
        icon: isRead ? Icons.mark_email_unread_rounded : Icons.mark_email_read_rounded,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeBackground(
        color: AppColors.error,
        icon: Icons.delete_outline_rounded,
        alignment: Alignment.centerRight,
      ),
      child: _buildNotificationTile(notification),
    );
  }

  Widget _buildSwipeBackground({required Color color, required IconData icon, required Alignment alignment}) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> n) {
    final bool isRead = n['isRead'];

    return Container(
      decoration: BoxDecoration(
        color: isRead ? Colors.transparent : AppColors.primary.withValues(alpha: 0.05),
        border: const Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getIconColor(n['type']).withValues(alpha: 0.1),
          child: Icon(_getIcon(n['type']), color: _getIconColor(n['type']), size: 20),
        ),
        title: Text(
          n['title'],
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(n['body'], style: AppTextStyles.caption.copyWith(fontSize: 13)),
            const SizedBox(height: 4),
            Text(n['time'], style: AppTextStyles.caption.copyWith(fontSize: 11, color: AppColors.textCaption)),
          ],
        ),
        isThreeLine: true,
        onTap: () => _toggleReadStatus(n['id']),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'lead': return Icons.person_add_rounded;
      case 'doc': return Icons.file_present_rounded;
      case 'process': return Icons.gavel_rounded;
      case 'chat': return Icons.chat_bubble_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'lead': return AppColors.primary;
      case 'doc': return AppColors.warning;
      case 'process': return const Color(0xFF673AB7);
      case 'chat': return AppColors.success;
      default: return AppColors.textCaption;
    }
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
        content: Text('Notificação excluída'),
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
