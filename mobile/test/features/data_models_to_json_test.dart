import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/data/models/account_model.dart';
import 'package:mobile/features/auth/data/models/auth_session_model.dart';
import 'package:mobile/features/auth/domain/entities/account.dart';
import 'package:mobile/features/lawyer/chat/data/models/chat_message_model.dart';
import 'package:mobile/features/lawyer/clients/data/models/lawyer_client_model.dart';
import 'package:mobile/features/lawyer/leads/data/models/lead_model.dart';
import 'package:mobile/features/notifications/data/models/app_notification_model.dart';
import 'package:mobile/features/procedures/data/models/legal_process_model.dart';
import 'package:mobile/features/procedures/data/models/process_document_model.dart';
import 'package:mobile/features/procedures/data/models/timeline_event_model.dart';

void main() {
  test('core mobile data models serialize with API field names', () {
    const createdAt = '2026-04-29T10:00:00.000Z';

    expect(
      const AccountModel(
        id: 'account-1',
        name: 'Lucas Silva',
        whatsappNumber: '5511999999999',
        role: UserRole.client,
        cpf: '12345678900',
        email: 'lucas@example.com',
        avatarUrl: 'https://cdn/avatar.png',
        notificationPreferences: {'documents': true},
      ).toJson(),
      {
        'id': 'account-1',
        'name': 'Lucas Silva',
        'whatsappNumber': '5511999999999',
        'cpf': '12345678900',
        'email': 'lucas@example.com',
        'avatarUrl': 'https://cdn/avatar.png',
        'role': 'CLIENT',
        'notificationPreferences': {'documents': true},
      },
    );

    expect(
      AuthSessionModel.fromJson({
        'token': 'jwt-token',
        'userId': 'account-1',
        'role': 'LAWYER',
      }).toJson(),
      {
        'token': 'jwt-token',
        'userId': 'account-1',
        'role': 'LAWYER',
        'account': null,
      },
    );

    expect(
      LegalProcessModel.fromJson({
        'id': 'process-1',
        'clientId': 'client-1',
        'lawyerId': 'lawyer-1',
        'title': 'Processo trabalhista',
        'description': 'Descricao',
        'currentStatus': 'OPEN',
        'processNumber': '0001',
        'caseType': 'LABOR',
        'lastNote': 'Atualizado',
        'lastMovementDate': createdAt,
        'createdAt': createdAt,
        'updatedAt': createdAt,
      }).toJson(),
      containsPair('currentStatus', 'OPEN'),
    );

    final document = ProcessDocumentModel.fromJson({
      'id': 'doc-1',
      'legalProcessId': 'process-1',
      'fileName': 'contrato.pdf',
      'fileUrl': '/documents/view/contrato.pdf',
      'sizeBytes': '1024',
      'mimeType': 'application/pdf',
      'sentById': 'account-1',
      'createdAt': createdAt,
    });
    expect(document.sizeBytes, 1024);
    expect(document.toJson(), containsPair('fileName', 'contrato.pdf'));

    expect(
      TimelineEventModel.fromJson({
        'id': 'timeline-1',
        'legalProcessId': 'process-1',
        'type': 'STATUS_UPDATE',
        'content': 'Status atualizado',
        'previousStatus': 'OPEN',
        'createdAt': createdAt,
      }).toJson(),
      containsPair('previousStatus', 'OPEN'),
    );

    expect(
      AppNotificationModel.fromJson({
        'id': 'notification-1',
        'userId': 'account-1',
        'type': 'STATUS_CHANGED',
        'title': 'Atualizacao',
        'body': 'Seu processo mudou',
        'isRead': false,
        'createdAt': createdAt,
      }).toJson(),
      containsPair('isRead', false),
    );

    expect(
      LeadModel.fromJson({
        'id': 'lead-1',
        'whatsappNumber': '5511888888888',
        'name': 'Maria',
        'cpf': '11122233344',
        'caseType': 'CIVIL',
        'caseDescription': 'Preciso de ajuda',
        'urgency': 'HIGH',
        'contactAvailability': 'manha',
        'status': 'PENDING',
        'createdAt': createdAt,
      }).toJson(),
      containsPair('caseDescription', 'Preciso de ajuda'),
    );

    expect(
      LawyerClientModel.fromJson({
        'id': 'client-1',
        'name': 'Ana',
        'whatsappNumber': '5511777777777',
        'cpf': '99988877766',
        'email': 'ana@example.com',
      }).toJson(),
      containsPair('email', 'ana@example.com'),
    );

    expect(
      ChatMessageModel.fromJson({
        'id': 'message-1',
        'leadId': 'lead-1',
        'userId': 'account-1',
        'sender': 'USER',
        'content': 'Ola',
        'whatsappMessageId': 'wamid-1',
        'createdAt': createdAt,
      }).toJson(),
      containsPair('whatsappMessageId', 'wamid-1'),
    );
  });
}
