import 'package:flutter/material.dart';
import '../../features/design_system/presentation/screens/design_system_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
// Client
import '../../features/client/procedures/presentation/screens/client_procedure_timeline_screen.dart';
import '../../features/client/profile/presentation/screens/client_profile_screen.dart';
import '../../features/client/notifications/presentation/screens/client_notifications_screen.dart';
import '../../features/client/chat/presentation/screens/client_chat_mirror_screen.dart';
// Lawyer
import '../../features/lawyer/procedures/presentation/screens/lawyer_procedure_detail_screen.dart';
import '../../features/lawyer/profile/presentation/screens/lawyer_profile_screen.dart';
import '../../features/lawyer/leads/presentation/screens/lawyer_lead_detail_screen.dart';
import '../../features/lawyer/notifications/presentation/screens/lawyer_notification_screen.dart';
import '../../features/lawyer/files/presentation/screens/lawyer_file_review_screen.dart';
import '../../features/lawyer/files/presentation/screens/lawyer_file_list_screen.dart';
import '../../features/lawyer/chat/presentation/screens/lawyer_chat_list_screen.dart';
import '../../features/lawyer/ai_manager/presentation/screens/lawyer_ai_manager_screen.dart';
import '../../features/lawyer/chat/presentation/screens/lawyer_chat_handoff_screen.dart';
import '../../features/lawyer/clients/presentation/screens/lawyer_client_detail_screen.dart';
import '../../shared/widgets/layout/client_main_layout.dart';
import '../../shared/widgets/layout/lawyer_main_layout.dart';

final class AppRouter {
  static const String initialRoute = '/splash';
  static const String splashRoute = '/splash';
  static const String loginRoute = '/login';
  static const String clientDashboardRoute = '/client-dashboard';
  static const String lawyerDashboardRoute = '/lawyer-dashboard';
  static const String lawyerClientsRoute = '/lawyer-clients';
  static const String lawyerProcedureDetailRoute = '/lawyer-procedure-detail';
  static const String lawyerProfileRoute = '/lawyer-profile';
  static const String lawyerLeadDetailRoute = '/lawyer-lead-detail';
  static const String lawyerNotificationsRoute = '/lawyer-notifications';
  static const String lawyerFilesRoute = '/lawyer-files';
  static const String lawyerFileReviewRoute = '/lawyer-file-review';
  static const String lawyerChatsRoute = '/lawyer-chats';
  static const String lawyerAIManagerRoute = '/lawyer-ai-manager';
  static const String lawyerChatHandoffRoute = '/lawyer-chat-handoff';
  static const String procedureListRoute = '/procedure-list';
  static const String procedureTimelineRoute = '/procedure-timeline';
  static const String filesRoute = '/files';
  static const String profileRoute = '/profile';
  static const String notificationsRoute = '/notifications';
  static const String chatMirrorRoute = '/chat-mirror';
  static const String chatsRoute = '/chats';
  static const String designSystemRoute = '/design-system';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      case loginRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case clientDashboardRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const ClientMainLayout(initialIndex: 0),
          settings: settings,
        );
      case lawyerLeadDetailRoute:
        final args = settings.arguments as Map<String, String>?;
        return MaterialPageRoute<void>(
          builder: (_) => LawyerLeadDetailScreen(
            leadId: args?['id'],
            name: args?['name'] ?? '',
            caseType: args?['caseType'] ?? '',
            urgency: args?['urgency'] ?? '',
          ),
          settings: settings,
        );
      case procedureListRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const ClientMainLayout(initialIndex: 1),
          settings: settings,
        );
      case procedureTimelineRoute:
        final args = settings.arguments;
        final processId = args is String
            ? args
            : args is Map<String, dynamic>
            ? args['processId'] as String?
            : null;
        return MaterialPageRoute<void>(
          builder: (_) => ClientProcedureTimelineScreen(processId: processId),
          settings: settings,
        );
      case filesRoute:
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
          builder: (_) => const LawyerMainLayout(initialIndex: 0),
          settings: settings,
        );
      case lawyerClientsRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const LawyerMainLayout(initialIndex: 3),
          settings: settings,
        );
      case '/lawyer-client-detail':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute<void>(
          builder: (_) => LawyerClientDetailScreen(
            clientId: args?['id'] as String?,
            name: args?['name'] as String? ?? '',
            cpf: args?['cpf'] as String? ?? '',
            phone: args?['phone'] as String? ?? '',
            email: args?['email'] as String?,
          ),
          settings: settings,
        );
      case lawyerProcedureDetailRoute:
        final args = settings.arguments;
        final processId = args is String
            ? args
            : args is Map<String, dynamic>
            ? args['processId'] as String?
            : null;
        return MaterialPageRoute<void>(
          builder: (_) => LawyerProcedureDetailScreen(processId: processId),
          settings: settings,
        );
      case lawyerProfileRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const LawyerProfileScreen(),
          settings: settings,
        );
      case lawyerNotificationsRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const LawyerNotificationScreen(),
          settings: settings,
        );
      case lawyerFilesRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const LawyerFileListScreen(),
          settings: settings,
        );
      case lawyerFileReviewRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute<void>(
          builder: (_) => LawyerFileReviewScreen(
            documentId: args?['documentId'] as String?,
          ),
          settings: settings,
        );
      case lawyerChatsRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const LawyerChatListScreen(),
          settings: settings,
        );
      case lawyerAIManagerRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const LawyerAIManagerScreen(),
          settings: settings,
        );
      case lawyerChatHandoffRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute<void>(
          builder: (_) => LawyerChatHandoffScreen(
            clientName: args?['clientName'] as String? ?? 'Cliente',
            whatsappNumber: args?['whatsappNumber'] as String? ?? '',
          ),
          settings: settings,
        );
      case designSystemRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const DesignSystemScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Rota não encontrada'))),
          settings: settings,
        );
    }
  }
}
