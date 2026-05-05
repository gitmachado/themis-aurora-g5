import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';

import '../entities/team_member.dart';
import '../entities/team_member_created.dart';
import '../entities/team_member_draft.dart';
import '../repositories/team_repository.dart';

final class ListTeamUseCase {
  final TeamRepository _repository;
  const ListTeamUseCase(this._repository);

  Future<Either<Failure, List<TeamMember>>> call() => _repository.listTeam();
}

final class GetTeamMemberUseCase {
  final TeamRepository _repository;
  const GetTeamMemberUseCase(this._repository);

  Future<Either<Failure, TeamMember>> call(String id) =>
      _repository.getMember(id);
}

final class AddTeamMemberUseCase {
  final TeamRepository _repository;
  const AddTeamMemberUseCase(this._repository);

  Future<Either<Failure, TeamMemberCreated>> call(TeamMemberDraft draft) =>
      _repository.addMember(draft);
}

final class UpdateTeamMemberPermissionsUseCase {
  final TeamRepository _repository;
  const UpdateTeamMemberPermissionsUseCase(this._repository);

  Future<Either<Failure, TeamMember>> call(
    String id,
    Map<String, bool> permissions,
  ) => _repository.updatePermissions(id, permissions);
}

final class RemoveTeamMemberUseCase {
  final TeamRepository _repository;
  const RemoveTeamMemberUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String id) => _repository.removeMember(id);
}
