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
                LawyerLeadTriageView(),
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
        height: 52,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: _Pill(
                label: 'Clientes',
                icon: Icons.people_alt_rounded,
                selected: selectedIndex == 0,
                onTap: () => onChanged(0),
              ),
            ),
            Expanded(
              child: _Pill(
                label: 'Pendentes',
                icon: Icons.hourglass_top_rounded,
                selected: selectedIndex == 1,
                badgeCount: pendingCount,
                onTap: () => onChanged(1),
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
  final IconData icon;
  final bool selected;
  final int? badgeCount;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.ink : AppColors.ink3;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: fg),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: fg,
                  letterSpacing: 0.1,
                ),
              ),
              if (badgeCount != null && badgeCount! > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.yellow : AppColors.ink3,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeCount! > 99 ? '99+' : '$badgeCount',
                    style: TextStyle(
                      fontSize: 11,
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
      ),
    );
  }
}
