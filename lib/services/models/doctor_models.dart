class DoctorSignUpRequest {
  final String name;
  final String email;
  final String password;
  final String specialization;
  final int? experienceYears;
  final double? consultationFee;
  final String? city;
  final String? timeZone;

  DoctorSignUpRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.specialization,
    this.experienceYears,
    this.consultationFee,
    this.city,
    this.timeZone,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'specialization': specialization,
    if (experienceYears != null) 'experienceYears': experienceYears,
    if (consultationFee != null) 'consultationFee': consultationFee,
    if (city != null) 'city': city,
    if (timeZone != null) 'timeZone': timeZone,
  };
}

class Doctor {
  final String id;
  final String specialization;
  final int? experienceYears;
  final double? consultationFee;
  final String? city;
  final String? timeZone;
  final bool? isActive;

  Doctor({
    required this.id,
    required this.specialization,
    this.experienceYears,
    this.consultationFee,
    this.city,
    this.timeZone,
    this.isActive,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      specialization: json['specialization'] ?? '',
      experienceYears: json['experienceYears'],
      consultationFee: json['consultationFee']?.toDouble(),
      city: json['city'],
      timeZone: json['timeZone'],
      isActive: json['isActive'],
    );
  }
}

class DoctorVerificationRequest {
  final String doctorId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String medicalSpecialization;
  final int yearsOfExperience;
  final String clinicHospitalName;
  final String clinicAddress;
  final String state;
  final String city;
  final String registrationNumber;
  final String councilName;
  final String issueDate;
  final String documentType;

  DoctorVerificationRequest({
    required this.doctorId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.medicalSpecialization,
    required this.yearsOfExperience,
    required this.clinicHospitalName,
    required this.clinicAddress,
    required this.state,
    required this.city,
    required this.registrationNumber,
    required this.councilName,
    required this.issueDate,
    required this.documentType,
  });

  Map<String, String> toFormFields() => {
    'doctorId': doctorId,
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
    'medicalSpecialization': medicalSpecialization,
    'yearsOfExperience': yearsOfExperience.toString(),
    'clinicHospitalName': clinicHospitalName,
    'clinicAddress': clinicAddress,
    'state': state,
    'city': city,
    'registrationNumber': registrationNumber,
    'councilName': councilName,
    'issueDate': issueDate,
    'documentType': documentType,
  };
}

class AvailabilityRule {
  final int dayOfWeek; // 0 = Sunday, 6 = Saturday
  final String startTime; // HH:MM format
  final String endTime; // HH:MM format
  final int? slotDurationMinutes;
  final bool? isActive;

  AvailabilityRule({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.slotDurationMinutes,
    this.isActive,
  });

  Map<String, dynamic> toJson() => {
    'dayOfWeek': dayOfWeek,
    'startTime': startTime,
    'endTime': endTime,
    if (slotDurationMinutes != null) 'slotDurationMinutes': slotDurationMinutes,
    if (isActive != null) 'isActive': isActive,
  };
}

class SetAvailabilityRequest {
  final List<AvailabilityRule> availability;

  SetAvailabilityRequest({required this.availability});

  Map<String, dynamic> toJson() => {
    'availability': availability.map((rule) => rule.toJson()).toList(),
  };
}

class TimeSlot {
  final String startUtc;
  final String? startLocal;
  final String label;
  final bool available;
  final int? durationMinutes;

  TimeSlot({
    required this.startUtc,
    required this.label,
    required this.available,
    this.startLocal,
    this.durationMinutes,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startUtc: json['startUtc'] ?? '',
      startLocal: json['startLocal'] as String?,
      label: json['label'] ?? '',
      available: json['available'] ?? false,
      durationMinutes: json['durationMinutes'] as int?,
    );
  }
}

class DayAvailability {
  final String date;
  final List<TimeSlot> slots;

  DayAvailability({required this.date, required this.slots});

  factory DayAvailability.fromJson(Map<String, dynamic> json) {
    return DayAvailability(
      date: json['date'] ?? '',
      slots:
          (json['slots'] as List<dynamic>?)
              ?.map((slot) => TimeSlot.fromJson(slot as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class AvailabilityResponse {
  final String doctorId;
  final List<DayAvailability> days;

  AvailabilityResponse({required this.doctorId, required this.days});

  factory AvailabilityResponse.fromJson(Map<String, dynamic> json) {
    return AvailabilityResponse(
      doctorId: json['doctorId'] ?? '',
      days:
          (json['days'] as List<dynamic>?)
              ?.map(
                (day) => DayAvailability.fromJson(day as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

class VerificationStatus {
  final String status;
  final String? message;

  VerificationStatus({required this.status, this.message});

  factory VerificationStatus.fromJson(Map<String, dynamic> json) {
    return VerificationStatus(
      status: json['status'] ?? 'pending',
      message: json['message'],
    );
  }
}
