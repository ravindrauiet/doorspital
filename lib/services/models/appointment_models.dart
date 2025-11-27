import 'doctor_models.dart';

class AvailableDoctor {
  final Doctor doctor;
  final String date;
  final int availableSlots;
  final List<TimeSlot> slots;

  AvailableDoctor({
    required this.doctor,
    required this.date,
    required this.availableSlots,
    required this.slots,
  });

  factory AvailableDoctor.fromJson(Map<String, dynamic> json) {
    return AvailableDoctor(
      doctor: Doctor.fromJson(json['doctor'] ?? {}),
      date: json['date'] ?? '',
      availableSlots: json['availableSlots'] ?? 0,
      slots:
          (json['slots'] as List<dynamic>?)
              ?.map((slot) => TimeSlot.fromJson(slot as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class BookAppointmentRequest {
  final String doctorId;
  final String startTime; // ISO 8601 format
  final String? reason;
  final String mode; // 'online' or 'offline'

  BookAppointmentRequest({
    required this.doctorId,
    required this.startTime,
    this.reason,
    this.mode = 'online',
  });

  Map<String, dynamic> toJson() => {
    'doctorId': doctorId,
    'startTime': startTime,
    if (reason != null) 'reason': reason,
    'mode': mode,
  };
}

class Appointment {
  final String id;
  final String? patientId;
  final String? doctorId;
  final Doctor? doctor;
  final DateTime startTime;
  final DateTime endTime;
  final String? reason;
  final String mode;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Appointment({
    required this.id,
    this.patientId,
    this.doctorId,
    this.doctor,
    required this.startTime,
    required this.endTime,
    this.reason,
    required this.mode,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    String? getPatientId() {
      if (json['patient'] == null) return null;
      if (json['patient'] is String) return json['patient'] as String;
      if (json['patient'] is Map) {
        return json['patient']?['_id']?.toString();
      }
      return null;
    }

    String? getDoctorId() {
      if (json['doctor'] == null) return null;
      if (json['doctor'] is String) return json['doctor'] as String;
      if (json['doctor'] is Map) {
        return json['doctor']?['_id']?.toString();
      }
      return null;
    }

    return Appointment(
      id: json['_id']?.toString() ?? json['appointmentId']?.toString() ?? '',
      patientId: getPatientId(),
      doctorId: getDoctorId(),
      doctor: json['doctor'] is Map
          ? Doctor.fromJson(json['doctor'] as Map<String, dynamic>)
          : null,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'].toString())
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'].toString())
          : DateTime.now(),
      reason: json['reason'],
      mode: json['mode'] ?? 'online',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
    );
  }
}

class DoctorAppointmentSummary {
  final String id;
  final String status;
  final String mode;
  final DateTime startTime;
  final DateTime endTime;
  final String? reason;
  final DoctorAppointmentPatient? patient;

  const DoctorAppointmentSummary({
    required this.id,
    required this.status,
    required this.mode,
    required this.startTime,
    required this.endTime,
    this.reason,
    this.patient,
  });

  bool get canChat =>
      status.toLowerCase() == 'confirmed' ||
      status.toLowerCase() == 'completed';

  factory DoctorAppointmentSummary.fromJson(Map<String, dynamic> json) {
    return DoctorAppointmentSummary(
      id: json['appointmentId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      mode: json['mode']?.toString() ?? 'online',
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'].toString())
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'].toString())
          : DateTime.now(),
      reason: json['reason'] as String?,
      patient: json['patient'] != null
          ? DoctorAppointmentPatient.fromJson(
              Map<String, dynamic>.from(json['patient'] as Map),
            )
          : null,
    );
  }
}

class DoctorAppointmentPatient {
  final String? id;
  final String? name;
  final String? email;

  const DoctorAppointmentPatient({this.id, this.name, this.email});

  factory DoctorAppointmentPatient.fromJson(Map<String, dynamic> json) {
    return DoctorAppointmentPatient(
      id: json['id']?.toString(),
      name: json['name'] as String?,
      email: json['email'] as String?,
    );
  }
}

class SearchAvailableDoctorsResponse {
  final String date;
  final int totalDoctors;
  final List<AvailableDoctor> doctors;

  SearchAvailableDoctorsResponse({
    required this.date,
    required this.totalDoctors,
    required this.doctors,
  });

  factory SearchAvailableDoctorsResponse.fromJson(Map<String, dynamic> json) {
    return SearchAvailableDoctorsResponse(
      date: json['date'] ?? '',
      totalDoctors: json['totalDoctors'] ?? 0,
      doctors:
          (json['doctors'] as List<dynamic>?)
              ?.map(
                (doctor) =>
                    AvailableDoctor.fromJson(doctor as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}
