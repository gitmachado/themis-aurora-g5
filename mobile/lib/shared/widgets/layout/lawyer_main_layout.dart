import 'package:flutter/material.dart';
import '../../../../features/dashboard/presentation/screens/lawyer_dashboard_screen.dart';
import '../../../../features/lawyer/presentation/screens/lawyer_lead_triage_screen.dart';
import '../../../../features/lawyer/presentation/screens/lawyer_process_list_screen.dart';
import '../../../../features/lawyer/presentation/screens/lawyer_client_list_screen.dart';
import '../../../../features/lawyer/presentation/screens/lawyer_profile_screen.dart';
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
    LawyerDashboardScreen(),
    LawyerLeadTriageScreen(),
    LawyerProcessListScreen(),
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
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onTabTapped,
        items: const [
          NavItem(icon: Icons.dashboard_outlined, label: 'Dash'),
          NavItem(icon: Icons.people_outline_rounded, label: 'Leads'),
          NavItem(icon: Icons.folder_shared_outlined, label: 'Processos'),
          NavItem(icon: Icons.contact_page_outlined, label: 'Clientes'),
          NavItem(icon: Icons.person_outline_rounded, label: 'Perfil'),
        ],
      ),
    );
  }
}
