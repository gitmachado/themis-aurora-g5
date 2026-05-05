import 'package:equatable/equatable.dart';

/// Permission keys recognised by the backend for team members.
class TeamPermissionKeys {
  TeamPermissionKeys._();

  static const String viewAllClients = 'viewAllClients';
  static const String convertLeads = 'convertLeads';
  static const String manageDocuments = 'manageDocuments';
  static const String receiveSupportNotifications =
      'receiveSupportNotifications';

  static const List<String> all = [
    viewAllClients,
    convertLeads,
    manageDocuments,
    receiveSupportNotifications,
  ];

  static String labelFor(String key) {
    switch (key) {
      case viewAllClients:
        return 'Ver todos os clientes do escritório';
      case convertLeads:
        return 'Converter leads em clientes';
      case manageDocuments:
        return 'Gerenciar documentos dos processos';
      case receiveSupportNotifications:
        return 'Receber notificações de suporte humano';
      default:
        return key;
    }
  }

  static String descriptionFor(String key) {
    switch (key) {
      case viewAllClients:
        return 'Sem essa permissão, o advogado vê apenas os clientes que ele atende.';
      case convertLeads:
        return 'Permite transformar um lead em cliente e abrir o processo inicial.';
      case manageDocuments:
        return 'Permite enviar, revisar e remover arquivos dos processos.';
      case receiveSupportNotifications:
        return 'Recebe avisos quando um cliente pede atendimento humano via WhatsApp.';
      default:
        return '';
    }
  }
}

class TeamMemberStats extends Equatable {
  final int activeProcesses;
  final int completedProcesses;
  final int assignedLeads;
  final int convertedLeads;
  final DateTime? lastActivityAt;

  const TeamMemberStats({
    this.activeProcesses = 0,
    this.completedProcesses = 0,
    this.assignedLeads = 0,
    this.convertedLeads = 0,
    this.lastActivityAt,
  });

  @override
  List<Object?> get props => [
    activeProcesses,
    completedProcesses,
    assignedLeads,
    convertedLeads,
    lastActivityAt,
  ];
}

class TeamMember extends Equatable {
  final String id;
  final String name;
  final String? email;
  final String whatsappNumber;
  final String? avatarUrl;
  final String? oabNumber;
  final String? specialty;
  final Map<String, bool> permissions;
  final DateTime joinedAt;
  final bool isActive;
  final TeamMemberStats stats;

  const TeamMember({
    required this.id,
    required this.name,
    required this.whatsappNumber,
    required this.permissions,
    required this.joinedAt,
    required this.stats,
    this.email,
    this.avatarUrl,
    this.oabNumber,
    this.specialty,
    this.isActive = true,
  });

  TeamMember copyWith({
    Map<String, bool>? permissions,
    TeamMemberStats? stats,
  }) {
    return TeamMember(
      id: id,
      name: name,
      whatsappNumber: whatsappNumber,
      avatarUrl: avatarUrl,
      email: email,
      oabNumber: oabNumber,
      specialty: specialty,
      isActive: isActive,
      joinedAt: joinedAt,
      permissions: permissions ?? this.permissions,
      stats: stats ?? this.stats,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    whatsappNumber,
    avatarUrl,
    oabNumber,
    specialty,
    permissions,
    joinedAt,
    isActive,
    stats,
  ];
}
