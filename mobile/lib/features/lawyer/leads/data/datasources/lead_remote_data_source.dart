import '../../../../../../shared/network/api_client.dart';
import '../models/lead_model.dart';

final class LeadRemoteDataSource {
  final ApiClient _apiClient;

  const LeadRemoteDataSource(this._apiClient);

  Future<List<LeadModel>> getPending() async {
    final list = await _apiClient.getList('/leads');
    return _parseList(list);
  }

  Future<List<LeadModel>> getByStatus(String status) async {
    final list = await _apiClient.getList('/leads?status=$status');
    return _parseList(list);
  }

  List<LeadModel> _parseList(List<dynamic> list) {
    return list
        .map(
          (json) => LeadModel.fromJson(Map<String, dynamic>.from(json as Map)),
        )
        .toList();
  }

  Future<LeadModel> getById(String id) async {
    final json = await _apiClient.getJson('/leads/$id');
    return LeadModel.fromJson(json);
  }

  Future<void> convert(String id) async {
    await _apiClient.patchJson('/leads/$id/convert');
  }

  Future<void> discard(String id, {String? reason}) async {
    await _apiClient.patchJson(
      '/leads/$id/discard',
      data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
    );
  }
}
