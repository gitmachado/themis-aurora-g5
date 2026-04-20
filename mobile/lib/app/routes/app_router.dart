import 'package:flutter/material.dart';
import '../../features/design_system/presentation/screens/design_system_screen.dart';
import '../../features/client/presentation/screens/client_process_timeline_screen.dart';

import '../../features/client/presentation/screens/client_profile_screen.dart';
import '../../features/client/presentation/screens/client_notifications_screen.dart';
import '../../features/client/presentation/screens/client_chat_mirror_screen.dart';
import '../../features/dashboard/presentation/screens/lawyer_dashboard_screen.dart';
import '../../features/lawyer/presentation/screens/lawyer_client_list_screen.dart';
import '../../features/lawyer/presentation/screens/lawyer_process_detail_screen.dart';
import '../../features/lawyer/presentation/screens/lawyer_profile_screen.dart';

import '../../shared/widgets/layout/client_main_layout.dart';

final class AppRouter {
  static const String initialRoute = '/';
  static const String lawyerDashboardRoute = '/lawyer-dashboard';
  static const String lawyerClientsRoute = '/lawyer-clients';
  static const String lawyerProcessDetailRoute = '/lawyer-process-detail';
  static const String lawyerProfileRoute = '/lawyer-profile';
  static const String processListRoute = '/process-list';
  static const String processTimelineRoute = '/process-timeline';
  static const String documentsRoute = '/documents';
  static const String profileRoute = '/profile';
  static const String notificationsRoute = '/notifications';
  static const String chatMirrorRoute = '/chat-mirror';
  static const String chatsRoute = '/chats';
  static const String designSystemRoute = '/design-system';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initialRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const ClientMainLayout(initialIndex: 0),
          settings: settings,
        );
      case processListRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const ClientMainLayout(initialIndex: 1),
          settings: settings,
        );
      case processTimelineRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const ClientProcessTimelineScreen(),
          settings: settings,
        );
      case documentsRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const ClientMainLayout(initialIndex: 2),
          settings: settings,
        );
      case profileRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const ClientProfileScreen(),
          settings: settings,
        );
      case notificationsRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const ClientNotificationsScreen(),
          settings: settings,
        );
      case chatMirrorRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const ClientChatMirrorScreen(),
          settings: settings,
        );
      case chatsRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const ClientMainLayout(initialIndex: 3),
          settings: settings,
        );
      case lawyerDashboardRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const LawyerDashboardScreen(),
          settings: settings,
        );
      case lawyerClientsRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const LawyerClientListScreen(),
          settings: settings,
        );
      case lawyerProcessDetailRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const LawyerProcessDetailScreen(),
          settings: settings,
        );
      case lawyerProfileRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const LawyerProfileScreen(),
          settings: settings,
        );
      case designSystemRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const DesignSystemScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Rota não encontrada'),
            ),
          ),
          settings: settings,
        );
    }
  }
}
