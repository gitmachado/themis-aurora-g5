import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../app/routes/app_router.dart';
import '../../../../../../features/notifications/domain/entities/app_notification.dart';
import '../../../../../../features/notifications/presentation/notification_display.dart';
import '../../../../../../features/notifications/presentation/providers/notification_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/cards/app_notification_tile.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';

class LawyerNotificationScreen extends ConsumerStatefulWidget {
  const LawyerNotificationScreen({super.key});

  @override
  ConsumerState<LawyerNotificationScreen> createState() =>
      _LawyerNotificationScreenState();
}

class _LawyerNotificationScreenState
    extends ConsumerState<LawyerNotificationScreen>
    with SingleTickerProviderStateMixin {
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          if (_isSelectionMode) {
            _isSelectionMode = false;
            _selectedIds.clear();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(myNotificationsProvider);
    final notifications = notificationsAsync.valueOrNull ?? [];

    return PopScope(
      canPop: !_isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isSelectionMode) {
          setState(() {
            _isSelectionMode = false;
            _selectedIds.clear();
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: _isSelectionMode
              ? '${_selectedIds.length} selecionados'
              : 'Notificações',
          showBackButton: !_isSelectionMode,
          actions: [
            if (_isSelectionMode) ...[
              IconButton(
                icon: const Icon(Icons.select_all_rounded),
                onPressed: () {
                  setState(() {
                    final currentList = _tabController.index == 0
                        ? notifications.where((n) => !n.isRead).toList()
                        : notifications;

                    if (_selectedIds.length == currentList.length) {
                      _selectedIds.clear();
                    } else {
                      _selectedIds.addAll(currentList.map((n) => n.id));
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  setState(() {
                    _isSelectionMode = false;
                    _selectedIds.clear();
                  });
                },
              ),
            ],
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.ink,
            unselectedLabelColor: AppColors.textCaption,
            indicatorColor: AppColors.yellow,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'Não lidas'),
              Tab(text: 'Todas'),
            ],
          ),
        ),
        body: SafeArea(
          top: false,
          child: notificationsAsync.when(
            data: (data) => TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildNotificationList(data, onlyUnread: true),
                _buildNotificationList(data, onlyUnread: false),
              ],
            ),
            loading: _buildLoadingList,
            error: (error, _) => _buildErrorState(error),
          ),
        ),
        floatingActionButton: _isSelectionMode && _selectedIds.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: _deleteSelected,
                backgroundColor: AppColors.error,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                ),
                label: const Text(
                  'Excluir',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildNotificationList(
    List<AppNotification> notifications, {
    required bool onlyUnread,
  }) {
    final list = onlyUnread
        ? notifications.where((n) => !n.isRead).toList()
        : notifications;

    if (list.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final n = list[index];
        return AppNotificationTile(
          id: n.id,
          title: n.title,
          body: n.body,
          time: n.timeLabel,
          type: n.tileType,
          isRead: n.isRead,
          isSelected: _selectedIds.contains(n.id),
          isSelectionMode: _isSelectionMode,
          onToggleRead: _toggleReadStatus,
          onDelete: _deleteNotification,
          onSelected: (id, selected) {
            setState(() {
              if (selected) {
                _selectedIds.add(id);
              } else {
                _selectedIds.remove(id);
              }
            });
          },
          onLongPress: (id) {
            setState(() {
              _isSelectionMode = true;
              _selectedIds.add(id);
            });
          },
          onTap: () => _handleNotificationTap(n),
        );
      },
    );
  }

  Future<void> _deleteSelected() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir notificações'),
        content: Text(
          'Deseja excluir as ${_selectedIds.length} notificações selecionadas?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final count = _selectedIds.length;
        await ref
            .read(notificationActionsProvider)
            .deleteMany(_selectedIds.toList());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$count ${count == 1 ? 'notificação excluída' : 'notificações excluídas'} com sucesso',
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() {
            _isSelectionMode = false;
            _selectedIds.clear();
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Erro ao excluir notificações'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _handleNotificationTap(AppNotification n) {
    if (!n.isRead) {
      _toggleReadStatus(n.id);
    }

    final extra = n.extraData;
    if (extra == null) return;

    if (n.type == 'HUMAN_SUPPORT' && extra.containsKey('whatsappNumber')) {
      Navigator.pushNamed(
        context,
        AppRouter.lawyerLeadDetailRoute,
        arguments: {
          'id': extra['leadId'],
          'name': extra['name'] ?? 'Cliente',
          'caseType': extra['caseType'] ?? '',
          'urgency': extra['urgency'] ?? '',
        },
      );
    } else if (n.type == 'NEW_LEAD' && extra.containsKey('whatsappNumber')) {
      Navigator.pushNamed(
        context,
        AppRouter.lawyerLeadDetailRoute,
        arguments: {
          'id': extra['leadId'],
          'name': extra['name'] ?? 'Novo Lead',
          'caseType': extra['caseType'] ?? '',
          'urgency': extra['urgency'] ?? '',
        },
      );
    }
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
            'Nenhuma notificação',
            style: AppTextStyles.h2.copyWith(color: AppColors.textCaption),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleReadStatus(String id) async {
    await ref.read(notificationActionsProvider).markAsRead(id);
  }

  Future<void> _deleteNotification(String id) async {
    try {
      await ref.read(notificationActionsProvider).delete(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificação excluída'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao excluir notificação'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) =>
          const LoadingSkeleton(height: 72, borderRadius: 12),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          error.toString(),
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: AppColors.error),
        ),
      ),
    );
  }
}
