import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/app/app.dart';
import 'package:mobile/shared/network/api_client.dart';
import 'package:mobile/shared/widgets/layout/app_bottom_nav_bar.dart';
import 'package:mobile/shared/network/websocket_client.dart';

import '../helpers/fakes.dart';

void main() {
  testWidgets('cliente percorre login, trâmites, arquivos, chat e perfil', (
    tester,
  ) async {
    final apiClient = FakeApiClient();
    final tokenStorage = FakeTokenStorage();
    _seedCommonResponses(apiClient, account: _clientAccount);
    _seedClientResponses(apiClient);

    await _pumpApp(tester, apiClient: apiClient, tokenStorage: tokenStorage);
    await _login(tester, email: 'cliente@themis.test');

    expect(find.text('Lucas Silva'), findsOneWidget);
    expect(find.text('Aguardando envio do RG'), findsOneWidget);
    expect(find.text('Falar com a Themis'), findsOneWidget);

    await tester.tap(find.text('Ver linha do tempo'));
    await tester.pumpAndSettle();

    expect(find.text('OC-2026-0001'), findsOneWidget);
    expect(find.text('Tramite criado'), findsOneWidget);
    expect(find.text('Documento do cliente anexado'), findsOneWidget);

    await tester.tap(find.text('Documentos'));
    await tester.pumpAndSettle();

    expect(find.text('cliente-rg.pdf'), findsOneWidget);

    await _goBack(tester);

    await _tapBottomNavAt(tester, 1);
    expect(find.text('Revisional de contrato'), findsOneWidget);

    await _tapBottomNavAt(tester, 2);
    expect(find.text('cliente-rg.pdf'), findsOneWidget);

    await _tapBottomNavAt(tester, 3);
    expect(find.text('Mensagem enviada pelo cliente'), findsOneWidget);
    expect(find.text('Assistente coletou os dados iniciais'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);

    await _tapBottomNavAt(tester, 4);
    expect(find.text('Conta de cliente'), findsOneWidget);
    expect(find.text('cliente@themis.test'), findsOneWidget);

    expect(tokenStorage.token, 'client-token');
    _expectCall(apiClient, 'POST', '/auth/login');
    _expectCall(apiClient, 'GET', '/processes/my');
    _expectCall(apiClient, 'GET', '/timeline/process/process-1');
    _expectCall(apiClient, 'GET', '/documents/process/process-1');
    _expectCall(apiClient, 'GET', '/documents/my');
    _expectCall(apiClient, 'GET', '/messages/11999999999');
  });

  testWidgets(
    'advogado percorre login, leads, trâmites, clientes, handoff e perfil',
    (tester) async {
      final apiClient = FakeApiClient();
      final tokenStorage = FakeTokenStorage();
      _seedCommonResponses(apiClient, account: _lawyerAccount);
      _seedLawyerResponses(apiClient);

      await _pumpApp(tester, apiClient: apiClient, tokenStorage: tokenStorage);
      await _login(tester, email: 'advogado@themis.test');

      expect(find.text('Dra. Paula Nunes'), findsOneWidget);
      expect(find.text('Handoff humano'), findsOneWidget);
      expect(find.text('Maria Oliveira'), findsOneWidget);

      await _tapBottomNavAt(tester, 1);
      expect(find.text('Leads'), findsWidgets);
      expect(find.text('Maria Oliveira'), findsOneWidget);

      await tester.tap(find.text('Maria Oliveira').first);
      await tester.pumpAndSettle();

      expect(find.text('Dados do Lead'), findsOneWidget);
      expect(
        find.text('Preciso de ajuda com verbas rescisórias.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Converter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sim, Converter Agora'));
      await tester.pumpAndSettle();

      expect(find.text('Cliente Convertido!'), findsOneWidget);
      _expectCall(apiClient, 'PATCH', '/leads/lead-1/convert');

      await tester.tap(find.text('Voltar à Fila'));
      await tester.pumpAndSettle();

      await _tapBottomNavAt(tester, 2);
      expect(find.text('Ação trabalhista'), findsOneWidget);

      await tester.tap(find.text('Ação trabalhista'));
      await tester.pumpAndSettle();

      expect(find.text('Resumo'), findsOneWidget);
      expect(find.text('Dados do trâmite'), findsOneWidget);

      await tester.tap(find.text('Status'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Concluído'));
      await tester.pumpAndSettle();

      expect(find.text('Status atualizado.'), findsOneWidget);
      _expectCall(apiClient, 'PATCH', '/processes/process-1/status');

      await tester.tap(find.text('Andamento'));
      await tester.pumpAndSettle();
      expect(find.text('Nota do advogado registrada'), findsOneWidget);

      await tester.tap(find.text('Documentos'));
      await tester.pumpAndSettle();
      expect(find.text('peticao-inicial.pdf'), findsOneWidget);

      await _goBack(tester);

      await _tapBottomNavAt(tester, 3);
      expect(find.text('Lucas Silva'), findsOneWidget);

      await tester.tap(find.text('Lucas Silva').first);
      await tester.pumpAndSettle();

      expect(find.text('Ficha do Cliente'), findsOneWidget);
      expect(find.text('Trâmites Vinculados'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chat_outlined));
      await tester.pumpAndSettle();

      expect(
        find.text('Histórico do WhatsApp em modo somente leitura.'),
        findsOneWidget,
      );
      expect(find.text('Mensagem enviada pelo cliente'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      await _goBack(tester);
      await _goBack(tester);

      await _tapBottomNavAt(tester, 4);
      expect(find.text('advogado@themis.test'), findsWidgets);
      expect(find.text('Mensagens e Handoffs'), findsOneWidget);

      expect(tokenStorage.token, 'lawyer-token');
      _expectCall(apiClient, 'GET', '/leads/pending');
      _expectCall(apiClient, 'GET', '/clients/my');
      _expectCall(apiClient, 'GET', '/clients/client-1');
      _expectCall(apiClient, 'GET', '/messages/11999999999');
    },
  );
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required FakeApiClient apiClient,
  required FakeTokenStorage tokenStorage,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(apiClient),
        tokenStorageProvider.overrideWithValue(tokenStorage),
        webSocketClientProvider.overrideWithValue(FakeWebSocketClient()),
      ],
      child: const ThemisApp(),
    ),
  );
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

Future<void> _login(WidgetTester tester, {required String email}) async {
  await tester.enterText(find.byType(TextField).at(0), email);
  await tester.enterText(find.byType(TextField).at(1), 'senha-segura');
  await tester.tap(find.text('Entrar'));
  await tester.pumpAndSettle();
}

Future<void> _tapBottomNavAt(WidgetTester tester, int index) async {
  final nav = tester.getRect(find.byType(AppBottomNavigationBar));
  final itemWidth = nav.width / 5;
  await tester.tapAt(
    Offset(nav.left + itemWidth * (index + 0.5), nav.center.dy),
  );
  await tester.pumpAndSettle();
}

Future<void> _goBack(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded).first);
  await tester.pumpAndSettle();
}

void _expectCall(FakeApiClient apiClient, String method, String path) {
  expect(
    apiClient.calls.any((call) => call.method == method && call.path == path),
    isTrue,
    reason: 'Expected $method $path to be called.',
  );
}

void _seedCommonResponses(
  FakeApiClient apiClient, {
  required Map<String, dynamic> account,
}) {
  final role = account['role'] as String;
  final token = role == 'LAWYER' ? 'lawyer-token' : 'client-token';

  apiClient.jsonResponses['POST /auth/login'] = {
    'token': token,
    'userId': account['id'],
    'role': role,
  };
  apiClient.jsonResponses['GET /account'] = account;
  apiClient.listResponses['GET /processes/my'] = _processes;
  apiClient.jsonResponses['GET /processes/process-1'] = _processes.first;
  apiClient.listResponses['GET /timeline/process/process-1'] = _timeline;
  apiClient.listResponses['GET /documents/process/process-1'] = _documents;
  apiClient.listResponses['GET /documents/my'] = _documents;
  apiClient.jsonResponses['GET /documents/doc-1/access-url'] = {
    'url': 'https://files.themis.test/peticao-inicial.pdf',
  };
  apiClient.listResponses['GET /notifications/my'] = _notifications;
  apiClient.listResponses['GET /messages/11999999999'] = _messages;
  apiClient.jsonResponses['PATCH /account/notification-preferences'] = account;
  apiClient.jsonResponses['POST_MULTIPART /account/avatar'] = account;
}

void _seedClientResponses(FakeApiClient apiClient) {
  apiClient.jsonResponses['GET /documents/doc-2/access-url'] = {
    'url': 'https://files.themis.test/cliente-rg.pdf',
  };
}

void _seedLawyerResponses(FakeApiClient apiClient) {
  apiClient.listResponses['GET /leads/pending'] = _pendingLeads;
  apiClient.listResponses['GET /leads?status=DISCARDED'] = _archivedLeads;
  apiClient.jsonResponses['GET /leads/lead-1'] = _pendingLeads.first;
  apiClient.listResponses['GET /clients/my'] = _clients;
  apiClient.jsonResponses['GET /clients/client-1'] = _clients.first;
  apiClient.jsonResponses['PATCH /processes/process-1/status'] = {
    ..._processes.first,
    'currentStatus': 'COMPLETED',
    'lastNote': 'Status atualizado pelo advogado',
  };
  apiClient.jsonResponses['PATCH /leads/lead-1/convert'] = {'id': 'user-1'};
}

final _clientAccount = {
  'id': 'client-1',
  'name': 'Lucas Silva',
  'whatsappNumber': '11999999999',
  'cpf': '12345678900',
  'email': 'cliente@themis.test',
  'role': 'CLIENT',
  'notificationPreferences': {
    'processUpdates': true,
    'documents': true,
    'messages': true,
  },
};

final _lawyerAccount = {
  'id': 'lawyer-1',
  'name': 'Dra. Paula Nunes',
  'whatsappNumber': '11888888888',
  'cpf': '98765432100',
  'email': 'advogado@themis.test',
  'role': 'LAWYER',
  'notificationPreferences': {
    'leads': true,
    'processUpdates': true,
    'documents': true,
  },
};

final _processes = [
  {
    'id': 'process-1',
    'clientId': 'client-1',
    'lawyerId': 'lawyer-1',
    'title': 'Ação trabalhista',
    'description': 'Revisional de contrato com documentos pendentes.',
    'currentStatus': 'AWAITING_DOCUMENT',
    'processNumber': 'OC-2026-0001',
    'caseType': 'TRABALHISTA',
    'lastNote': 'Aguardando envio do RG',
    'lastMovementDate': '2026-05-01T10:00:00.000Z',
    'createdAt': '2026-04-20T10:00:00.000Z',
    'updatedAt': '2026-05-01T10:00:00.000Z',
  },
  {
    'id': 'process-2',
    'clientId': 'client-1',
    'lawyerId': 'lawyer-1',
    'title': 'Revisional de contrato',
    'description': 'Caso concluído e arquivado.',
    'currentStatus': 'ARCHIVED',
    'processNumber': 'OC-2026-0002',
    'caseType': 'CIVEL',
    'lastNote': 'Trâmite arquivado',
    'createdAt': '2026-04-10T10:00:00.000Z',
    'updatedAt': '2026-04-30T10:00:00.000Z',
  },
];

final _timeline = [
  {
    'id': 'timeline-1',
    'legalProcessId': 'process-1',
    'type': 'PROCESS_CREATED',
    'content': 'Tramite aberto pelo atendimento.',
    'createdAt': '2026-04-20T10:00:00.000Z',
  },
  {
    'id': 'timeline-2',
    'legalProcessId': 'process-1',
    'type': 'LAWYER_NOTE',
    'content': 'Nota do advogado registrada',
    'createdAt': '2026-05-01T10:00:00.000Z',
  },
  {
    'id': 'timeline-3',
    'legalProcessId': 'process-1',
    'type': 'DOCUMENT_SENT',
    'content': 'Documento do cliente anexado',
    'createdAt': '2026-05-01T12:00:00.000Z',
  },
];

final _documents = [
  {
    'id': 'doc-1',
    'legalProcessId': 'process-1',
    'fileName': 'peticao-inicial.pdf',
    'fileUrl': '/uploads/peticao-inicial.pdf',
    'sentById': 'lawyer-1',
    'sizeBytes': 230000,
    'mimeType': 'application/pdf',
    'createdAt': '2026-04-21T10:00:00.000Z',
  },
  {
    'id': 'doc-2',
    'legalProcessId': 'process-1',
    'fileName': 'cliente-rg.pdf',
    'fileUrl': '/uploads/cliente-rg.pdf',
    'sentById': 'client-1',
    'sizeBytes': 120000,
    'mimeType': 'application/pdf',
    'createdAt': '2026-05-01T12:00:00.000Z',
  },
];

final _notifications = [
  {
    'id': 'notification-1',
    'userId': 'lawyer-1',
    'type': 'HUMAN_SUPPORT',
    'title': 'Handoff solicitado',
    'body': 'Cliente pediu atendimento humano.',
    'isRead': false,
    'createdAt': '2026-05-01T13:00:00.000Z',
  },
];

final _pendingLeads = [
  {
    'id': 'lead-1',
    'whatsappNumber': '11999999999',
    'name': 'Maria Oliveira',
    'cpf': '11122233344',
    'caseType': 'TRABALHISTA',
    'caseDescription': 'Preciso de ajuda com verbas rescisórias.',
    'urgency': 'HIGH',
    'contactAvailability': 'MORNING',
    'status': 'PENDING',
    'createdAt': '2026-05-02T09:00:00.000Z',
  },
];

final _archivedLeads = [
  {
    'id': 'lead-2',
    'whatsappNumber': '11777777777',
    'name': 'Carlos Arquivado',
    'caseType': 'CIVEL',
    'caseDescription': 'Lead arquivado para histórico.',
    'urgency': 'LOW',
    'status': 'DISCARDED',
    'createdAt': '2026-04-30T09:00:00.000Z',
  },
];

final _clients = [
  {
    'id': 'client-1',
    'name': 'Lucas Silva',
    'whatsappNumber': '11999999999',
    'cpf': '12345678900',
    'email': 'cliente@themis.test',
  },
];

final _messages = [
  {
    'id': 'message-1',
    'leadId': 'lead-1',
    'userId': 'client-1',
    'sender': 'CLIENT',
    'content': 'Mensagem enviada pelo cliente',
    'whatsappMessageId': 'wamid-1',
    'createdAt': '2026-05-02T09:15:00.000Z',
  },
  {
    'id': 'message-2',
    'leadId': 'lead-1',
    'userId': 'lawyer-1',
    'sender': 'BOT',
    'content': 'Assistente coletou os dados iniciais',
    'whatsappMessageId': 'wamid-2',
    'createdAt': '2026-05-02T09:16:00.000Z',
  },
];
