/// Specialty options accepted by the backend when adding a team member.
enum TeamSpecialty {
  labor('Labor', 'Trabalhista'),
  civil('Civil', 'Cível'),
  family('Family', 'Família'),
  criminal('Criminal', 'Criminal'),
  socialSecurity('SocialSecurity', 'Previdenciário');

  final String apiValue;
  final String label;

  const TeamSpecialty(this.apiValue, this.label);
}

class TeamMemberDraft {
  final String name;
  final String email;
  final String whatsappNumber;
  final String oabNumber;
  final TeamSpecialty specialty;

  const TeamMemberDraft({
    required this.name,
    required this.email,
    required this.whatsappNumber,
    required this.oabNumber,
    required this.specialty,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'whatsappNumber': whatsappNumber,
      'oabNumber': oabNumber,
      'specialty': specialty.apiValue,
    };
  }
}
