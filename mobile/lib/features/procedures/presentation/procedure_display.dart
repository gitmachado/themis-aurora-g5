import 'package:flutter/material.dart';

import '../../../shared/widgets/buttons/app_badge.dart';
import '../domain/entities/legal_process.dart';

extension LegalProcessDisplay on LegalProcess {
  String get displayTitle => title;

  String? get displaySubtitle {
    final number = processNumber;
    if (number == null || number.isEmpty) return null;
    return 'Tramite: $number';
  }

  String get displayStatus => switch (currentStatus) {
    'UNDER_ANALYSIS' => 'Em Analise',
    'AWAITING_DOCUMENT' => 'Aguardando Docs',
    'COMPLETED' => 'Concluido',
    'ARCHIVED' => 'Arquivado',
    _ => 'Aberto',
  };

  BadgeType get badgeType => switch (currentStatus) {
    'UNDER_ANALYSIS' || 'AWAITING_DOCUMENT' => BadgeType.warning,
    'COMPLETED' || 'ARCHIVED' => BadgeType.success,
    _ => BadgeType.primary,
  };

  int get progressPercentage => switch (currentStatus) {
    'OPEN' => 20,
    'UNDER_ANALYSIS' => 45,
    'AWAITING_DOCUMENT' => 35,
    'COMPLETED' || 'ARCHIVED' => 100,
    _ => 30,
  };

  IconData get icon => switch (caseType) {
    'Labor' => Icons.work_outline,
    'Family' => Icons.people_outline,
    'Criminal' => Icons.gavel_outlined,
    'SocialSecurity' => Icons.home_work_outlined,
    _ => Icons.gavel_outlined,
  };

  String get caseTypeLabel => switch (caseType) {
    'Labor' => 'Trabalhista',
    'Civil' => 'Civel',
    'Family' => 'Familia',
    'Criminal' => 'Criminal',
    'SocialSecurity' => 'Previdenciario',
    _ => 'Juridico',
  };
}

String translateStatus(String status) => switch (status) {
  'UNDER_ANALYSIS' => 'EM ANÁLISE',
  'AWAITING_DOCUMENT' => 'AGUARDANDO DOCUMENTO',
  'COMPLETED' => 'CONCLUÍDO',
  'ARCHIVED' => 'ARQUIVADO',
  'OPEN' => 'ABERTO',
  _ => status,
};

String formatTimelineContent(String content) {
  var formatted = content;
  final statuses = [
    'UNDER_ANALYSIS',
    'AWAITING_DOCUMENT',
    'COMPLETED',
    'ARCHIVED',
    'OPEN',
  ];

  for (final status in statuses) {
    formatted = formatted.replaceAll(status, translateStatus(status));
  }

  return formatted;
}
