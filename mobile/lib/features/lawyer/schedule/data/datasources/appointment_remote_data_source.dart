import '../../../../../../shared/network/api_client.dart';
import '../models/appointment_model.dart';

final class AppointmentRemoteDataSource {
  final ApiClient _apiClient;

  const AppointmentRemoteDataSource(this._apiClient);

  Future<List<AppointmentModel>> getAppointments({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final list = await _apiClient.getList(
      '/appointments?startDate=${Uri.encodeComponent(startDate.toIso8601String())}&endDate=${Uri.encodeComponent(endDate.toIso8601String())}',
    );

    return list
        .map((json) => AppointmentModel.fromJson(
              Map<String, dynamic>.from(json as Map),
            ))
        .toList();
  }

  Future<AppointmentModel> createAppointment(
    Map<String, dynamic> data,
  ) async {
    final json = await _apiClient.postJson('/appointments', data: data);
    return AppointmentModel.fromJson(json);
  }

  Future<AppointmentModel> updateAppointmentStatus(
    String id,
    String status,
  ) async {
    final json = await _apiClient.patchJson(
      '/appointments/$id',
      data: {'status': status},
    );
    return AppointmentModel.fromJson(json);
  }
}
