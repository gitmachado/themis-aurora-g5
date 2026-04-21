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
        extendBody: true,
        body: LayoutBuilder(
          builder: (context, constraints) {
              final double height = constraints.maxHeight;
              final double stopStart = (height - 180) / height;
              final double stopEnd = (height - 60) / height;
  
              return ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: const [Colors.black, Colors.transparent],
                    stops: [stopStart, stopEnd],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: IndexedStack(
                  index: currentIndex,
                  children: _screens,
                ),
              );
            },
          ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.0),
                Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.95),
                Theme.of(context).scaffoldBackgroundColor,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
          child: SafeArea(
            child: AppBottomNavigationBar(
              currentIndex: currentIndex,
              onTap: _onTabTapped,
              items: const [
                NavItem(icon: Icons.grid_view_rounded, label: 'Início'),
                NavItem(icon: Icons.people_alt_rounded, label: 'Leads'),
                NavItem(icon: Icons.business_center_rounded, label: 'Trâmites'),
                NavItem(icon: Icons.person_search_rounded, label: 'Clientes'),
                NavItem(icon: Icons.person_rounded, label: 'Perfil'),
              ],
            ),
          ),
        ),
      ),
    );

  }
}

