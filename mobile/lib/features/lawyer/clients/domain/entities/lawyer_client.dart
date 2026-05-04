import 'package:equatable/equatable.dart';

class LawyerClient extends Equatable {
  final String id;
  final String name;
  final String whatsappNumber;
  final String? cpf;
  final String? email;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  const LawyerClient({
    required this.id,
    required this.name,
    required this.whatsappNumber,
    this.cpf,
    this.email,
    this.lastMessage,
    this.lastMessageAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    whatsappNumber,
    cpf,
    email,
    lastMessage,
    lastMessageAt,
  ];
}
