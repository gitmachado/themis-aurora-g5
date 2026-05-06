import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/widgets/app_app_bar_actions.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/themis/themis_widgets.dart';
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

class _LawyerClientsHubScreenState extends ConsumerState<LawyerClientsHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
  )..addListener(() {
    if (mounted) setState(() {});
  });

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onControllerChanged);
    if (widget.controller != null) {
      _tabController.index = widget.controller!.index;
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
    _tabController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    if (_tabController.index != widget.controller!.index) {
      _tabController.animateTo(widget.controller!.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount =
        ref.watch(pendingLeadsProvider).maybeWhen(
          data: (l) => l.length,
          orElse: () => 0,
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Clientes',
        backgroundColor: AppColors.surface,
        actions: [AppAppBarActions()],
        showDivider: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(68),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: ThemisSegmentedControl(
                labels: const ['Leads', 'Clientes', 'Arquivados'],
                selectedIndex: _tabController.index,
                controller: _tabController,
                badges: {0: pendingCount},
                onChanged: (i) {
                  widget.controller?.selectTab(i);
                  _tabController.animateTo(i);
                },
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(), // Mantém o pedido de não deslizar arrastando
              children: const [
                LawyerLeadTriageView(archived: false),
                LawyerClientListView(),
                LawyerLeadTriageView(archived: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
