import 'package:flutter/material.dart';
import '../../../../features/client/home/presentation/screens/client_home_screen.dart';
import '../../../../features/client/processes/presentation/screens/client_process_list_screen.dart';
import '../../../../features/client/documents/presentation/screens/client_documents_screen.dart';
import '../../../../features/client/chat/presentation/screens/client_chats_screen.dart';
import '../../../../features/client/profile/presentation/screens/client_profile_screen.dart';
import 'app_bottom_nav_bar.dart';


class ClientMainLayout extends StatefulWidget {
  final int initialIndex;

  const ClientMainLayout({super.key, this.initialIndex = 0});

  @override
  State<ClientMainLayout> createState() => _ClientMainLayoutState();
}

class _ClientMainLayoutState extends State<ClientMainLayout> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    ClientHomeScreen(),
    ClientProcessListScreen(),
    ClientDocumentsScreen(),
    ClientChatsScreen(),
    ClientProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
