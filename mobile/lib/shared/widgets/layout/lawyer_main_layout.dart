import 'package:flutter/material.dart';
import '../../../../features/lawyer/overview/presentation/screens/lawyer_overview_screen.dart';
import '../../../../features/lawyer/leads/presentation/screens/lawyer_lead_triage_screen.dart';
import '../../../../features/lawyer/procedures/presentation/screens/lawyer_procedure_list_screen.dart';
import '../../../../features/lawyer/clients/presentation/screens/lawyer_client_list_screen.dart';
import '../../../../features/lawyer/profile/presentation/screens/lawyer_profile_screen.dart';
import 'app_bottom_nav_bar.dart';

class LawyerMainLayout extends StatefulWidget {
  final int initialIndex;

  const LawyerMainLayout({super.key, this.initialIndex = 0});

  @override
  State<LawyerMainLayout> createState() => LawyerMainLayoutState();
}

class LawyerMainLayoutState extends State<LawyerMainLayout> {
  late int currentIndex;

  final List<Widget> _screens = const [
    LawyerOverviewScreen(),
    LawyerLeadTriageScreen(),
    LawyerProcedureListScreen(),
    LawyerClientListScreen(),
    LawyerProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  void setIndex(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
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
              NavItem(icon: Icons.people_alt_rounded, label: 'Leads'),
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
