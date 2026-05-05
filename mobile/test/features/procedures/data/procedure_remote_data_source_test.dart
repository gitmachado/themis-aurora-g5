import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/procedures/data/datasources/procedure_remote_data_source.dart';

import '../../../helpers/fakes.dart';

void main() {
  test(
    'uses the server routes for processes, timeline, documents, and status',
    () async {
      final apiClient = FakeApiClient()
        ..listResponses['GET /processes/my'] = [_processJson('process-1')]
        ..jsonResponses['GET /processes/process-1'] = _processJson('process-1')
        ..listResponses['GET /timeline/process/process-1'] = [
          {
            'id': 'event-1',
            'legalProcessId': 'process-1',
            'type': 'PROCESS_CREATED',
            'content': 'Criado',
            'createdAt': '2026-04-24T12:00:00.000Z',
          },
        ]
        ..listResponses['GET /documents/process/process-1'] = [
          {
            'id': 'doc-1',
            'legalProcessId': 'process-1',
            'fileName': 'rg.pdf',
            'fileUrl': '/uploads/rg.pdf',
            'sizeBytes': 1024,
            'mimeType': 'application/pdf',
            'sentById': 'user-1',
            'createdAt': '2026-04-24T12:00:00.000Z',
          },
        ]
        ..listResponses['GET /documents/my'] = [
          _documentJson('doc-2', 'contrato.pdf'),
        ]
        ..jsonResponses['GET /documents/doc-2'] = _documentJson(
          'doc-2',
          'contrato.pdf',
        )
        ..jsonResponses['POST_MULTIPART /documents/upload'] = _documentJson(
          'doc-3',
          'novo.pdf',
        )
        ..jsonResponses['PATCH /processes/process-1/status'] = _processJson(
          'process-1',
          status: 'UNDER_ANALYSIS',
        );
      final dataSource = ProcedureRemoteDataSource(apiClient);

      final processes = await dataSource.getMyProcesses();
      final process = await dataSource.getProcessById('process-1');
      final timeline = await dataSource.getTimeline('process-1');
      final documents = await dataSource.getDocuments('process-1');
      final myDocuments = await dataSource.getMyDocuments();
      final document = await dataSource.getDocumentById('doc-2');
      final uploaded = await dataSource.uploadDocument(
        processId: 'process-1',
        filePath: '/tmp/novo.pdf',
        fileName: 'novo.pdf',
      );
      await dataSource.deleteDocument('doc-2');
      final updated = await dataSource.updateStatus(
        processId: 'process-1',
        status: 'UNDER_ANALYSIS',
        reason: 'Triagem finalizada',
      );

      expect(processes.single.id, 'process-1');
      expect(process.id, 'process-1');
      expect(timeline.single.legalProcessId, 'process-1');
      expect(documents.single.fileName, 'rg.pdf');
      expect(myDocuments.single.id, 'doc-2');
      expect(myDocuments.single.sizeBytes, 2048);
      expect(document.fileName, 'contrato.pdf');
      expect(uploaded.id, 'doc-3');
      expect(updated.currentStatus, 'UNDER_ANALYSIS');
      expect(apiClient.calls.map((call) => '${call.method} ${call.path}'), [
        'GET /processes/my',
        'GET /processes/process-1',
        'GET /timeline/process/process-1',
        'GET /documents/process/process-1',
        'GET /documents/my',
        'GET /documents/doc-2',
        'POST_MULTIPART /documents/upload',
        'DELETE /documents/doc-2',
        'PATCH /processes/process-1/status',
      ]);
      expect(apiClient.calls[6].data, {'legalProcessId': 'process-1'});
      expect(apiClient.calls[6].fileField, 'file');
      expect(apiClient.calls[6].filePath, '/tmp/novo.pdf');
      expect(apiClient.calls[6].fileName, 'novo.pdf');
      expect(apiClient.calls.last.data, {
        'status': 'UNDER_ANALYSIS',
        'reason': 'Triagem finalizada',
      });
    },
  );
}

Map<String, dynamic> _documentJson(String id, String fileName) {
  return {
    'id': id,
    'legalProcessId': 'process-1',
    'fileName': fileName,
    'fileUrl': '/uploads/$fileName',
    'sizeBytes': '2048',
    'mimeType': 'application/pdf',
    'sentById': 'user-1',
    'createdAt': '2026-04-24T12:00:00.000Z',
  };
}

Map<String, dynamic> _processJson(String id, {String status = 'OPEN'}) {
  return {
    'id': id,
    'clientId': 'client-1',
    'lawyerId': 'lawyer-1',
    'title': 'Acao Trabalhista',
    'description': 'Descricao',
    'currentStatus': status,
    'processNumber': '0001234-56.2026',
    'caseType': 'Labor',
    'lastNote': 'Movimentacao recente',
    'createdAt': '2026-04-24T12:00:00.000Z',
    'updatedAt': '2026-04-24T12:00:00.000Z',
  };
}
