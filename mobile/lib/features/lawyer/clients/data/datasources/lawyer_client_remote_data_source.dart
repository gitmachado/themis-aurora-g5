import '../../../../../../shared/network/api_client.dart';
import '../models/lawyer_client_model.dart';

final class LawyerClientRemoteDataSource {
  final ApiClient _apiClient;

  const LawyerClientRemoteDataSource(this._apiClient);

  Future<List<LawyerClientModel>> getMyClients() async {
    final list = await _apiClient.getList('/clients/my');
    return list
        .map(
          (json) => LawyerClientModel.fromJson(
            Map<String, dynamic>.from(json as Map),
          ),
        )
        .toList();
  }

  Future<LawyerClientModel> getById(String id) async {
    final json = await _apiClient.getJson('/clients/$id');
    return LawyerClientModel.fromJson(json);
  }

  Future<void> deleteClient(String id) async {
    await _apiClient.deleteVoid('/clients/$id');
  }
}
