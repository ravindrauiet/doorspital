class PublicNurse {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String specialization;
  final String qualificationLevel;
  final int experienceYears;
  final List<String> services;
  final String city;
  final String state;
  final String avatarUrl;

  const PublicNurse({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.specialization,
    required this.qualificationLevel,
    required this.experienceYears,
    required this.services,
    required this.city,
    required this.state,
    required this.avatarUrl,
  });

  factory PublicNurse.fromJson(Map<String, dynamic> json) {
    return PublicNurse(
      id: json['_id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? 'Nurse',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      specialization: json['specialization']?.toString() ?? '',
      qualificationLevel: json['qualificationLevel']?.toString() ?? '',
      experienceYears: (json['experienceYears'] as num?)?.toInt() ?? 0,
      services:
          (json['services'] as List<dynamic>? ?? const [])
              .map((item) => item.toString())
              .toList(),
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
    );
  }
}
