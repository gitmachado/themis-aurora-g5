import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';
import 'package:mobile/shared/errors/repository_guard.dart';

import '../../domain/entities/team_member.dart';
import '../../domain/entities/team_member_created.dart';
import '../../domain/entities/team_member_draft.dart';
import '../../domain/repositories/team_repository.dart';
import '../datasources/team_remote_data_source.dart';

final class TeamRepositoryImpl implements TeamRepository {
  final TeamRemoteDataSource _remoteDataSource;

  const TeamRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<TeamMember>>> listTeam() {
    return guardRepository<List<TeamMember>>(_remoteDataSource.listTeam);
  }

  @override
  Future<Either<Failure, TeamMember>> getMember(String id) {
    return guardRepository<TeamMember>(() => _remoteDataSource.getMember(id));
  }

  @override
  Future<Either<Failure, TeamMemberCreated>> addMember(TeamMemberDraft draft) {
    return guardRepository<TeamMemberCreated>(
      () => _remoteDataSource.addMember(draft),
    );
  }

  @override
  Future<Either<Failure, TeamMember>> updatePermissions(
    String id,
    Map<String, bool> permissions,
  ) {
    return guardRepository<TeamMember>(
      () => _remoteDataSource.updatePermissions(id, permissions),
    );
  }

  @override
  Future<Either<Failure, Unit>> removeMember(String id) {
    return guardRepositoryUnit(() => _remoteDataSource.removeMember(id));
  }
}
