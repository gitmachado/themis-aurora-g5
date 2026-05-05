import 'package:equatable/equatable.dart';

import 'team_member.dart';

/// Resultado do cadastro de um novo advogado: o membro persistido e a senha
/// temporária que deve ser repassada uma única vez ao advogado.
class TeamMemberCreated extends Equatable {
  final TeamMember member;
  final String tempPassword;

  const TeamMemberCreated({required this.member, required this.tempPassword});

  @override
  List<Object?> get props => [member, tempPassword];
}
