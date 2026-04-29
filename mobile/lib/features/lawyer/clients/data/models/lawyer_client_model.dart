import '../../domain/entities/lawyer_client.dart';

final class LawyerClientModel extends LawyerClient {
  const LawyerClientModel({
    required super.id,
    required super.name,
    required super.whatsappNumber,
    super.cpf,
    super.email,
  });

  factory LawyerClientModel.fromJson(Map<String, dynamic> json) {
    return LawyerClientModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Cliente',
      whatsappNumber: json['whatsappNumber'] as String? ?? '',
      cpf: json['cpf'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'whatsappNumber': whatsappNumber,
      'cpf': cpf,
      'email': email,
    };
  }
}
