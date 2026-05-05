import 'package:equatable/equatable.dart';

enum UserRole {
  client,
  lawyer,
  lawyerAdmin;

  static UserRole fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'LAWYER_ADMIN':
        return UserRole.lawyerAdmin;
      case 'LAWYER':
        return UserRole.lawyer;
      default:
        return UserRole.client;
    }
  }

  String get apiValue => switch (this) {
    UserRole.client => 'CLIENT',
    UserRole.lawyer => 'LAWYER',
    UserRole.lawyerAdmin => 'LAWYER_ADMIN',
  };

  bool get isLawyerSide => this == UserRole.lawyer || this == UserRole.lawyerAdmin;

  bool get isAdmin => this == UserRole.lawyerAdmin;
}

class Account extends Equatable {
  final String id;
  final String name;
  final String whatsappNumber;
  final String? cpf;
  final String? email;
  final String? avatarUrl;
  final UserRole role;
  final Map<String, bool> notificationPreferences;
  final Map<String, bool> teamPermissions;
  final String? lawyerAdminId;
  final bool mustChangePassword;

  const Account({
    required this.id,
    required this.name,
    required this.whatsappNumber,
    required this.role,
    this.cpf,
    this.email,
    this.avatarUrl,
    this.notificationPreferences = const {},
    this.teamPermissions = const {},
    this.lawyerAdminId,
    this.mustChangePassword = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    whatsappNumber,
    cpf,
    email,
    avatarUrl,
    role,
    notificationPreferences,
    teamPermissions,
    lawyerAdminId,
    mustChangePassword,
  ];
}
