import '../../domain/entities/account.dart';

final class AccountModel extends Account {
  const AccountModel({
    required super.id,
    required super.name,
    required super.whatsappNumber,
    required super.role,
    super.cpf,
    super.email,
    super.avatarUrl,
    super.notificationPreferences,
    super.teamPermissions,
    super.lawyerAdminId,
    super.mustChangePassword,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Usuario',
      whatsappNumber: json['whatsappNumber'] as String? ?? '',
      cpf: json['cpf'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: UserRole.fromApi(json['role'] as String? ?? 'CLIENT'),
      notificationPreferences: _boolMap(json['notificationPreferences']),
      teamPermissions: _boolMap(json['teamPermissions']),
      lawyerAdminId: json['lawyerAdminId'] as String?,
      mustChangePassword: json['mustChangePassword'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'whatsappNumber': whatsappNumber,
      'cpf': cpf,
      'email': email,
      'avatarUrl': avatarUrl,
      'role': role.apiValue,
      'notificationPreferences': notificationPreferences,
      'teamPermissions': teamPermissions,
      'lawyerAdminId': lawyerAdminId,
      'mustChangePassword': mustChangePassword,
    };
  }
}

Map<String, bool> _boolMap(Object? value) {
  if (value is! Map) return const {};

  return Map<String, bool>.unmodifiable(
    value.map(
      (key, preference) => MapEntry(key.toString(), preference == true),
    ),
  );
}
