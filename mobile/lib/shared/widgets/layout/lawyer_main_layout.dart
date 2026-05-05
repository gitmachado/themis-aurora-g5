import 'package:flutter/material.dart';
import '../../../../features/lawyer/overview/presentation/screens/lawyer_overview_screen.dart';
import '../../../../features/lawyer/procedures/presentation/screens/lawyer_procedure_list_screen.dart';
import '../../../../features/lawyer/clients/presentation/screens/lawyer_clients_hub_screen.dart';
import '../../../../features/lawyer/profile/presentation/screens/lawyer_profile_screen.dart';
import 'app_bottom_nav_bar.dart';

class LawyerMainLayout extends StatefulWidget {
  final int initialIndex;

  const LawyerMainLayout({super.key, this.initialIndex = 0});

  @override
  State<LawyerMainLayout> createState() => LawyerMainLayoutState();
}

class LawyerMainLayoutState extends State<LawyerMainLayout> {
  static const int clientsHubIndex = 2;
  static const int profileIndex = 3;

  late int currentIndex;

  final ValueNotifier<int> currentIndexNotifier = ValueNotifier<int>(0);

  final LawyerClientsHubController _clientsHubController =
      LawyerClientsHubController();

  late final List<Widget> _screens = [
    const LawyerOverviewScreen(),
    const LawyerProcedureListScreen(),
    LawyerClientsHubScreen(controller: _clientsHubController),
    const LawyerProfileScreen(),
  ];

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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (currentIndex > 0) {
          setState(() {
            currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        body: IndexedStack(index: currentIndex, children: _screens),
        bottomNavigationBar: SafeArea(
          top: false,
          child: AppBottomNavigationBar(
            currentIndex: currentIndex,
            onTap: _onTabTapped,
            items: const [
              NavItem(icon: Icons.grid_view_rounded, label: 'Painel'),
              NavItem(icon: Icons.folder_rounded, label: 'Processos'),
              NavItem(icon: Icons.business_center_rounded, label: 'Clientes'),
              NavItem(icon: Icons.person_rounded, label: 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }
}
