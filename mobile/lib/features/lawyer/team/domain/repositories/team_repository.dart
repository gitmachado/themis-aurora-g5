import 'package:fpdart/fpdart.dart';
import 'package:mobile/shared/errors/failures.dart';

import '../entities/team_member.dart';
import '../entities/team_member_created.dart';
import '../entities/team_member_draft.dart';

abstract interface class TeamRepository {
  Future<Either<Failure, List<TeamMember>>> listTeam();
  Future<Either<Failure, TeamMember>> getMember(String id);
  Future<Either<Failure, TeamMemberCreated>> addMember(TeamMemberDraft draft);
  Future<Either<Failure, TeamMember>> updatePermissions(
    String id,
    Map<String, bool> permissions,
  );
  Future<Either<Failure, Unit>> removeMember(String id);
}
