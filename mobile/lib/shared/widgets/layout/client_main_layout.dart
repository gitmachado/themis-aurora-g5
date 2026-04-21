import 'package:flutter/material.dart';
import '../../../../features/client/home/presentation/screens/client_home_screen.dart';
import '../../../../features/client/procedures/presentation/screens/client_procedure_list_screen.dart';
import '../../../../features/client/files/presentation/screens/client_files_screen.dart';
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
    ClientProcedureListScreen(),
    ClientFilesScreen(),
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex > 0) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double height = constraints.maxHeight;
              // Meio termo: começa aos 180px e termina aos 60px
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
                  index: _currentIndex,
                  children: _screens,
                ),
              );
            },
          ),
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
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
            ),
          ),
        ),
      ),
    );

  }
}

