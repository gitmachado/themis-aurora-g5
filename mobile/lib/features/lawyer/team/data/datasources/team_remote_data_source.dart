import '../../../../../../shared/network/api_client.dart';
import '../../domain/entities/team_member_created.dart';
import '../../domain/entities/team_member_draft.dart';
import '../models/team_member_model.dart';

abstract interface class TeamRemoteDataSource {
  Future<List<TeamMemberModel>> listTeam();
  Future<TeamMemberModel> getMember(String id);
  Future<TeamMemberCreated> addMember(TeamMemberDraft draft);
  Future<TeamMemberModel> updatePermissions(
    String id,
    Map<String, bool> permissions,
  );
  Future<void> removeMember(String id);
}

final class TeamRemoteDataSourceImpl implements TeamRemoteDataSource {
  final ApiClient _apiClient;

  const TeamRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<TeamMemberModel>> listTeam() async {
    final list = await _apiClient.getList('/team');
    return list
        .map(
          (json) =>
              TeamMemberModel.fromJson(Map<String, dynamic>.from(json as Map)),
        )
        .toList();
  }

  @override
  Future<TeamMemberModel> getMember(String id) async {
    final json = await _apiClient.getJson('/team/$id');
    return TeamMemberModel.fromJson(json);
  }

  @override
  Future<TeamMemberCreated> addMember(TeamMemberDraft draft) async {
    final json = await _apiClient.postJson('/team', data: draft.toJson());
    final memberJson = Map<String, dynamic>.from(json['member'] as Map);
    return TeamMemberCreated(
      member: TeamMemberModel.fromJson(memberJson),
      tempPassword: json['tempPassword'] as String? ?? '',
    );
  }

  @override
  Future<TeamMemberModel> updatePermissions(
    String id,
    Map<String, bool> permissions,
  ) async {
    final json = await _apiClient.patchJson(
      '/team/$id/permissions',
      data: {'permissions': permissions},
    );
    return TeamMemberModel.fromJson(json);
  }

  @override
  Future<void> removeMember(String id) async {
    await _apiClient.deleteVoid('/team/$id');
  }
}
