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

  Future<AppointmentModel> updateAppointment(
    String id,
    Map<String, dynamic> data,
  ) async {
    final json = await _apiClient.patchJson(
      '/appointments/$id',
      data: data,
    );
    return AppointmentModel.fromJson(json);
  }

  // ===== NEW: Appointment Approval Workflow =====

  Future<List<AppointmentModel>> getPendingAppointments() async {
    final response = await _apiClient.getJson('/appointments/pending');
    final items = response['items'] as List?;
    return items
            ?.map(
              (json) => AppointmentModel.fromJson(
                Map<String, dynamic>.from(json as Map),
              ),
            )
            .toList() ??
        [];
  }

  Future<AppointmentModel> approveAppointment(
    String id, {
    Map<String, dynamic>? edits,
  }) async {
    final json = await _apiClient.patchJson(
      '/appointments/$id/approve',
      data: edits ?? {},
    );
    return AppointmentModel.fromJson(json);
  }

  Future<void> rejectAppointment(String id) async {
    await _apiClient.patchJson(
      '/appointments/$id/reject',
      data: {},
    );
  }

  Future<AppointmentModel> resetToAIVersion(String id) async {
    final json = await _apiClient.patchJson(
      '/appointments/$id/reset-to-ai-version',
      data: {},
    );
    return AppointmentModel.fromJson(json);
  }

  Future<Map<String, dynamic>> requestReschedule(
    String id,
    String instruction,
  ) async {
    final json = await _apiClient.postJson(
      '/appointments/$id/reschedule-request',
      data: {'instruction': instruction},
    );
    return json as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getRescheduleSuggestions(
    String id,
  ) async {
    final response = await _apiClient.getJson(
      '/appointments/$id/reschedule-suggestions',
    );

    final items = response['items'] as List?;
    return items?.map((item) => Map<String, dynamic>.from(item as Map)).toList() ?? [];
  }

  Future<AppointmentModel> acceptRescheduleSuggestion(
    String suggestionId,
    String appointmentId,
  ) async {
    final json = await _apiClient.patchJson(
      '/reschedule-suggestions/$suggestionId/accept?appointmentId=$appointmentId',
      data: {},
    );
    return AppointmentModel.fromJson(json);
  }

  Future<void> rejectRescheduleSuggestion(String suggestionId) async {
    await _apiClient.patchJson(
      '/reschedule-suggestions/$suggestionId/reject',
      data: {},
    );
  }
}
