import '../../../../../shared/utils/api_formatters.dart';
import '../domain/entities/lead.dart';

extension LeadDisplay on Lead {
  String get displayName =>
      (name == null || name!.isEmpty) ? 'Lead sem nome' : name!;

  String get caseTypeLabel => switch (caseType) {
    'Labor' => 'Trabalhista',
    'Civil' => 'Civel',
    'Family' => 'Familia',
    'Criminal' => 'Criminal',
    'SocialSecurity' => 'Previdenciario',
    _ => 'Juridico',
  };

  String get urgencyLabel => switch (urgency) {
    'High' => 'Alta',
    'Medium' => 'Media',
    'Low' => 'Baixa',
    _ => 'Media',
  };

  String get availabilityLabel => switch (contactAvailability) {
    'Morning' => 'Manha',
    'Afternoon' => 'Tarde',
    'Evening' => 'Noite',
    _ => '--',
  };

  String get timeLabel => formatRelativeDate(createdAt);
}
