import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/lawyer/leads/data/datasources/lead_remote_data_source.dart';

import '../../../../helpers/fakes.dart';

void main() {
  test('uses lawyer lead routes for listing, detail, and conversion', () async {
    final lead = {
      'id': 'lead-1',
      'whatsappNumber': '11999999999',
      'name': 'Carla Menezes',
      'cpf': '12345678900',
      'caseType': 'Labor',
      'caseDescription': 'Relato',
      'urgency': 'High',
      'contactAvailability': 'Morning',
      'status': 'PENDING',
      'createdAt': '2026-04-24T12:00:00.000Z',
    };
    final apiClient = FakeApiClient()
      ..listResponses['GET /leads/pending'] = [lead]
      ..listResponses['GET /leads'] = [lead]
      ..listResponses['GET /leads?status=DISCARDED'] = [
        {...lead, 'id': 'lead-archived', 'status': 'DISCARDED'},
      ]
      ..jsonResponses['GET /leads/lead-1'] = lead
      ..jsonResponses['PATCH /leads/lead-1/convert'] = {'id': 'user-1'};
    final dataSource = LeadRemoteDataSource(apiClient);

    final leads = await dataSource.getPending();
    final allLeads = await dataSource.getAllLeads();
    final archivedLeads = await dataSource.getByStatus('DISCARDED');
    final detail = await dataSource.getById('lead-1');
    await dataSource.convert('lead-1');

    expect(leads.single.id, 'lead-1');
    expect(allLeads.single.id, 'lead-1');
    expect(archivedLeads.single.status, 'DISCARDED');
    expect(detail.name, 'Carla Menezes');
    expect(apiClient.calls.map((call) => '${call.method} ${call.path}'), [
      'GET /leads/pending',
      'GET /leads',
      'GET /leads?status=DISCARDED',
      'GET /leads/lead-1',
      'PATCH /leads/lead-1/convert',
    ]);
  });
}
