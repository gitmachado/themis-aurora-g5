import '../../../../../../shared/network/api_client.dart';
import '../models/lead_model.dart';

final class LeadRemoteDataSource {
  final ApiClient _apiClient;

  const LeadRemoteDataSource(this._apiClient);

  Future<List<LeadModel>> getPending() async {
    final list = await _apiClient.getList('/leads/pending');
    return _parseList(list);
  }

  Future<List<LeadModel>> getAllLeads() async {
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
      data: reason != null ? {'reason': reason} : null,
    );
  }

  Future<LeadModel> update(String id, Map<String, dynamic> data) async {
    final cleanId = id.trim();
    final path = '/leads/$cleanId';
    // ignore: avoid_print
    print('LeadRemoteDataSource: PATCH $path payload: $data');
    final json = await _apiClient.patchJson(path, data: data);
    return LeadModel.fromJson(json);
  }

  Future<void> deleteLead(String id) async {
    final cleanId = id.trim();
    await _apiClient.deleteVoid('/leads/$cleanId');
  }
}
