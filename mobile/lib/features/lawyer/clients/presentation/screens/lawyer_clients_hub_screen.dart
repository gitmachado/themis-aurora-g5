import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/widgets/app_app_bar_actions.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../leads/presentation/providers/lead_providers.dart';
import '../../../leads/presentation/screens/lawyer_lead_triage_screen.dart';
import 'lawyer_client_list_screen.dart';

class LawyerClientsHubController extends ChangeNotifier {
  int _index = 0;
  int get index => _index;

  void selectTab(int i) {
    if (i == _index) return;
    _index = i;
    notifyListeners();
  }
}

class LawyerClientsHubScreen extends ConsumerStatefulWidget {
  final LawyerClientsHubController? controller;

  const LawyerClientsHubScreen({super.key, this.controller});

  @override
  ConsumerState<LawyerClientsHubScreen> createState() =>
      _LawyerClientsHubScreenState();
}

class _LawyerClientsHubScreenState
    extends ConsumerState<LawyerClientsHubScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onControllerChanged);
    if (widget.controller != null) {
      _selectedTab = widget.controller!.index;
    }
  }

  @override
  void didUpdateWidget(LawyerClientsHubScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() => _selectedTab = widget.controller!.index);
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = ref
        .watch(pendingLeadsProvider)
        .maybeWhen(data: (l) => l.length, orElse: () => 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Clientes',
        actions: [AppAppBarActions()],
        showDivider: false,
      ),
      body: Column(
        children: [
          _ClientsHubSegmented(
            selectedIndex: _selectedTab,
            pendingCount: pendingCount,
            onChanged: (i) => setState(() => _selectedTab = i),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: const [
                LawyerClientListView(),
                LawyerLeadTriageView(archived: false),
                LawyerLeadTriageView(archived: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientsHubSegmented extends StatelessWidget {
  final int selectedIndex;
  final int pendingCount;
  final ValueChanged<int> onChanged;

  const _ClientsHubSegmented({
    required this.selectedIndex,
    required this.pendingCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
          shape: BoxShape.rectangle,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _Pill(
                label: 'Clientes',
                selected: selectedIndex == 0,
                onTap: () => onChanged(0),
              ),
            ),
            Expanded(
              child: _Pill(
                label: 'Pendentes',
                selected: selectedIndex == 1,
                badgeCount: pendingCount,
                onTap: () => onChanged(1),
              ),
            ),
            Expanded(
              child: _Pill(
                label: 'Arquivados',
                selected: selectedIndex == 2,
                onTap: () => onChanged(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final int? badgeCount;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.ink : AppColors.ink3;
    final hasBadge = badgeCount != null && badgeCount! > 0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: fg,
                  letterSpacing: 0.1,
                ),
              ),
            ),
            if (hasBadge) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.yellow : AppColors.ink3,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeCount! > 99 ? '99+' : '$badgeCount',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: selected ? AppColors.ink : AppColors.surface,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
