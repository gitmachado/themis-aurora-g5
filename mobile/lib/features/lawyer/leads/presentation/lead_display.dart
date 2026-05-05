import '../../../../../shared/utils/api_formatters.dart';
import '../../../../../shared/utils/string_utils.dart';
import '../domain/entities/lead.dart';

extension LeadDisplay on Lead {
  String get displayName =>
      (name == null || name!.isEmpty) ? 'Lead sem nome' : name!;

  String get shortName => StringUtils.formatFirstAndLastName(displayName);

  String get caseTypeLabel => switch (caseType) {
    'Labor' => 'Trabalhista',
    'Civil' => 'Cível',
    'Family' => 'Família',
    'Criminal' => 'Criminal',
    'SocialSecurity' => 'Previdenciário',
    _ => 'Jurídico',
  };

  String get urgencyLabel => switch (urgency) {
    'High' => 'Alta',
    'Medium' => 'Média',
    'Low' => 'Baixa',
    _ => 'Média',
  };

  String get availabilityLabel => switch (contactAvailability) {
    'Morning' => 'Manhã',
    'Afternoon' => 'Tarde',
    'Evening' => 'Noite',
    _ => '--',
  };

  String get timeLabel => formatFullDateTime(createdAt);
}
