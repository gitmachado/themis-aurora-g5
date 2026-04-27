import 'package:equatable/equatable.dart';

enum UserRole {
  client,
  lawyer;

  static UserRole fromApi(String value) {
    return value.toUpperCase() == 'LAWYER' ? UserRole.lawyer : UserRole.client;
  }

  String get apiValue => switch (this) {
    UserRole.client => 'CLIENT',
    UserRole.lawyer => 'LAWYER',
  };
}

class Account extends Equatable {
  final String id;
  final String name;
  final String whatsappNumber;
  final String? cpf;
  final String? email;
  final UserRole role;
  final Map<String, bool> notificationPreferences;

  const Account({
    required this.id,
    required this.name,
    required this.whatsappNumber,
    required this.role,
    this.cpf,
    this.email,
    this.notificationPreferences = const {},
  });

  @override
  List<Object?> get props => [
    id,
    name,
    whatsappNumber,
    cpf,
    email,
    role,
    notificationPreferences,
  ];
}
