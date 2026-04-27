import 'package:equatable/equatable.dart';

import 'account.dart';

class AuthSession extends Equatable {
  final String token;
  final String userId;
  final UserRole role;
  final Account? account;

  const AuthSession({
    required this.token,
    required this.userId,
    required this.role,
    this.account,
  });

  AuthSession copyWith({
    String? token,
    String? userId,
    UserRole? role,
    Account? account,
  }) {
    return AuthSession(
      token: token ?? this.token,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      account: account ?? this.account,
    );
  }

  @override
  List<Object?> get props => [token, userId, role, account];
}
