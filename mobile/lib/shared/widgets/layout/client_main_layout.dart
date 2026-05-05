import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/client/home/presentation/providers/client_navigation_provider.dart';
import '../../../../features/client/home/presentation/screens/client_home_screen.dart';
import '../../../../features/client/procedures/presentation/screens/client_procedure_list_screen.dart';
import '../../../../features/client/files/presentation/screens/client_files_screen.dart';
import '../../../../features/client/chat/presentation/screens/client_chat_mirror_screen.dart';
import '../../../../features/client/profile/presentation/screens/client_profile_screen.dart';
import 'app_bottom_nav_bar.dart';

class ClientMainLayout extends ConsumerStatefulWidget {
  final int initialIndex;

  const ClientMainLayout({super.key, this.initialIndex = 0});

  @override
  ConsumerState<ClientMainLayout> createState() => _ClientMainLayoutState();
}

class _ClientMainLayoutState extends ConsumerState<ClientMainLayout> {
  final List<Widget> _screens = const [
    ClientHomeScreen(),
    ClientProcedureListScreen(),
    ClientFilesScreen(),
    ClientChatMirrorScreen(showBackButton: false),
    ClientProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(clientNavigationIndexProvider.notifier).state = widget.initialIndex;
      }
    });
  }

  void _onTabTapped(int index) {
    ref.read(clientNavigationIndexProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(clientNavigationIndexProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (currentIndex > 0) {
          ref.read(clientNavigationIndexProvider.notifier).state = 0;
        }
      },
      child: Scaffold(
        body: IndexedStack(index: currentIndex, children: _screens),
        bottomNavigationBar: SafeArea(
          top: false,
          child: AppBottomNavigationBar(
            currentIndex: currentIndex,
            onTap: _onTabTapped,
          ),
        ),
      ),
    );
  }
}
