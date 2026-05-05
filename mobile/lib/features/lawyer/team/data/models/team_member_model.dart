import '../../domain/entities/team_member.dart';

final class TeamMemberModel extends TeamMember {
  const TeamMemberModel({
    required super.id,
    required super.name,
    required super.whatsappNumber,
    required super.permissions,
    required super.joinedAt,
    required super.stats,
    super.email,
    super.avatarUrl,
    super.oabNumber,
    super.specialty,
    super.isActive,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? 'Advogado',
      email: json['email'] as String?,
      whatsappNumber: (json['whatsappNumber'] as String?) ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      oabNumber: json['oabNumber'] as String?,
      specialty: json['specialty'] as String?,
      isActive: (json['isActive'] as bool?) ?? true,
      joinedAt: _parseDate(json['joinedAt']) ?? DateTime.now(),
      permissions: _boolMap(json['permissions']),
      stats: _statsFromJson(json['stats']),
    );
  }
}

TeamMemberStats _statsFromJson(Object? value) {
  if (value is! Map) return const TeamMemberStats();
  final map = Map<String, dynamic>.from(value);
  return TeamMemberStats(
    activeProcesses: (map['activeProcesses'] as num?)?.toInt() ?? 0,
    completedProcesses: (map['completedProcesses'] as num?)?.toInt() ?? 0,
    assignedLeads: (map['assignedLeads'] as num?)?.toInt() ?? 0,
    convertedLeads: (map['convertedLeads'] as num?)?.toInt() ?? 0,
    lastActivityAt: _parseDate(map['lastActivityAt']),
  );
}

Map<String, bool> _boolMap(Object? value) {
  if (value is! Map) return const {};
  return Map<String, bool>.unmodifiable(
    value.map((key, v) => MapEntry(key.toString(), v == true)),
  );
}

DateTime? _parseDate(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  if (value is DateTime) return value;
  return null;
}
