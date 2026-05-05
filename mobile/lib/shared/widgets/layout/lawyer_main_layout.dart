import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/domain/entities/account.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../features/lawyer/overview/presentation/screens/lawyer_overview_screen.dart';
import '../../../../features/lawyer/procedures/presentation/screens/lawyer_procedure_list_screen.dart';
import '../../../../features/lawyer/clients/presentation/screens/lawyer_clients_hub_screen.dart';
import '../../../../features/lawyer/profile/presentation/screens/lawyer_profile_screen.dart';
import '../../../../features/lawyer/team/presentation/screens/team_list_screen.dart';
import 'app_bottom_nav_bar.dart';

class LawyerMainLayout extends ConsumerStatefulWidget {
  final int initialIndex;

  const LawyerMainLayout({super.key, this.initialIndex = 0});

  @override
  ConsumerState<LawyerMainLayout> createState() => LawyerMainLayoutState();
}

class LawyerMainLayoutState extends ConsumerState<LawyerMainLayout> {
  static const int clientsHubIndex = 2;

  /// Returns the profile tab index taking into account whether the
  /// admin-only Equipe tab is being shown.
  int profileIndexFor(bool isAdmin) => isAdmin ? 4 : 3;

  /// Backwards-compat for legacy callers — assumes the user is NOT admin.
  /// Prefer [profileIndexFor].
  static const int profileIndex = 3;

  late int currentIndex;

  final ValueNotifier<int> currentIndexNotifier = ValueNotifier<int>(0);

  final LawyerClientsHubController _clientsHubController =
      LawyerClientsHubController();

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    currentIndexNotifier.value = widget.initialIndex;
  }

  @override
  void dispose() {
    _clientsHubController.dispose();
    currentIndexNotifier.dispose();
    super.dispose();
  }

  void setIndex(int index) {
    setState(() {
      currentIndex = index;
    });
    currentIndexNotifier.value = index;
  }

  /// Navega para a aba Clientes e seleciona o sub-tab Pendentes (Leads).
  void goToClientsHubPending() {
    _clientsHubController.selectTab(1);
    setIndex(clientsHubIndex);
  }

  void goToClientsHub() {
    _clientsHubController.selectTab(0);
    setIndex(clientsHubIndex);
  }

  void _onTabTapped(int index) {
    if (index == clientsHubIndex && currentIndex != clientsHubIndex) {
      _clientsHubController.selectTab(0);
    }
    setIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).valueOrNull;
    final cachedAccount = ref.watch(currentAccountProvider).valueOrNull;
    final role = session?.account?.role ?? cachedAccount?.role ?? UserRole.lawyer;
    final isAdmin = role.isAdmin;

    final screens = <Widget>[
      const LawyerOverviewScreen(),
      const LawyerProcedureListScreen(),
      LawyerClientsHubScreen(controller: _clientsHubController),
      if (isAdmin) const TeamListScreen(),
      const LawyerProfileScreen(),
    ];

    final navItems = <NavItem>[
      const NavItem(icon: Icons.grid_view_rounded, label: 'Painel'),
      const NavItem(icon: Icons.folder_rounded, label: 'Processos'),
      const NavItem(icon: Icons.business_center_rounded, label: 'Clientes'),
      if (isAdmin)
        const NavItem(icon: Icons.groups_2_rounded, label: 'Equipe'),
      const NavItem(icon: Icons.person_rounded, label: 'Perfil'),
    ];

    // Clamp the current index in case the role just flipped (e.g. logout/login).
    final safeIndex = currentIndex.clamp(0, screens.length - 1);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (currentIndex > 0) {
          setState(() {
            currentIndex = 0;
          });
          currentIndexNotifier.value = 0;
        }
      },
      child: Scaffold(
        body: IndexedStack(index: safeIndex, children: screens),
        bottomNavigationBar: SafeArea(
          top: false,
          child: AppBottomNavigationBar(
            currentIndex: safeIndex,
            onTap: _onTabTapped,
            items: navItems,
          ),
        ),
      ),
    );
  }
}
