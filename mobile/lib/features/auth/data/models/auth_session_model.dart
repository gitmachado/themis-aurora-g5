import '../../domain/entities/account.dart';
import '../../domain/entities/auth_session.dart';
import 'account_model.dart';

final class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.token,
    required super.userId,
    required super.role,
    super.account,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final accountJson = json['account'];
    final account = accountJson is Map
        ? AccountModel.fromJson(Map<String, dynamic>.from(accountJson))
        : null;

    return AuthSessionModel(
      token: json['token'] as String,
      userId: json['userId'] as String,
      role: UserRole.fromApi(json['role'] as String? ?? 'CLIENT'),
      account: account,
    );
  }
}
