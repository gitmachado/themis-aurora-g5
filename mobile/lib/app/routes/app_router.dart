import 'package:flutter/material.dart';
import '../../features/design_system/presentation/screens/design_system_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
// Client
import '../../features/client/processes/presentation/screens/client_process_timeline_screen.dart';
import '../../features/client/profile/presentation/screens/client_profile_screen.dart';
import '../../features/client/notifications/presentation/screens/client_notifications_screen.dart';
import '../../features/client/chat/presentation/screens/client_chat_mirror_screen.dart';
// Lawyer
import '../../features/lawyer/processes/presentation/screens/lawyer_process_detail_screen.dart';
import '../../features/lawyer/profile/presentation/screens/lawyer_profile_screen.dart';
import '../../features/lawyer/leads/presentation/screens/lawyer_lead_detail_screen.dart';
import '../../features/lawyer/notifications/presentation/screens/lawyer_notification_screen.dart';
import '../../features/lawyer/documents/presentation/screens/lawyer_document_review_screen.dart';
import '../../features/lawyer/documents/presentation/screens/lawyer_document_list_screen.dart';
import '../../features/lawyer/chat/presentation/screens/lawyer_chat_list_screen.dart';
import '../../features/lawyer/ai_manager/presentation/screens/lawyer_ai_manager_screen.dart';
import '../../features/lawyer/chat/presentation/screens/lawyer_chat_handoff_screen.dart';
import '../../features/lawyer/clients/presentation/screens/lawyer_client_detail_screen.dart';
import '../../shared/widgets/layout/client_main_layout.dart';
import '../../shared/widgets/layout/lawyer_main_layout.dart';


final class AppRouter {
  static const String initialRoute = '/login';
  static const String loginRoute = '/login';
  static const String clientDashboardRoute = '/client-dashboard';
  static const String lawyerDashboardRoute = '/lawyer-dashboard';
  static const String lawyerClientsRoute = '/lawyer-clients';
  static const String lawyerProcessDetailRoute = '/lawyer-process-detail';
  static const String lawyerProfileRoute = '/lawyer-profile';
  static const String lawyerLeadDetailRoute = '/lawyer-lead-detail';
  static const String lawyerNotificationsRoute = '/lawyer-notifications';
  static const String lawyerDocumentsRoute = '/lawyer-documents';
  static const String lawyerDocumentReviewRoute = '/lawyer-document-review';
  static const String lawyerChatsRoute = '/lawyer-chats';
  static const String lawyerAIManagerRoute = '/lawyer-ai-manager';
  static const String lawyerChatHandoffRoute = '/lawyer-chat-handoff';
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
            name: args?['name'] ?? '',
            caseType: args?['caseType'] ?? '',
            urgency: args?['urgency'] ?? '',
          ),
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
            name: args?['name'] ?? '',
            cpf: args?['cpf'] ?? '',
          ),
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
      case lawyerNotificationsRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const LawyerNotificationScreen(),
          settings: settings,
        );
      case lawyerDocumentsRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const LawyerDocumentListScreen(),
          settings: settings,
        );
      case lawyerDocumentReviewRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const LawyerDocumentReviewScreen(),
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
          builder: (_) => LawyerChatHandoffScreen(clientName: args?['clientName'] ?? 'Cliente'),
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
