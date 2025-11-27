import 'package:door/services/models/appointment_models.dart';

class ChatParticipant {
  final String id;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final String? role;

  ChatParticipant({
    required this.id,
    this.name,
    this.email,
    this.avatarUrl,
    this.role,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['_id']?.toString() ?? '',
      name: json['userName'] as String? ?? json['name'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String?,
    );
  }
}

class ChatDoctorSummary {
  final String id;
  final String? specialization;
  final String? city;
  final int? experienceYears;

  ChatDoctorSummary({
    required this.id,
    this.specialization,
    this.city,
    this.experienceYears,
  });

  factory ChatDoctorSummary.fromJson(Map<String, dynamic> json) {
    return ChatDoctorSummary(
      id: json['_id']?.toString() ?? '',
      specialization: json['specialization'] as String?,
      city: json['city'] as String?,
      experienceYears: json['experienceYears'] as int?,
    );
  }
}

class ChatLastMessage {
  final String? text;
  final String? sentBy;
  final DateTime? sentAt;

  ChatLastMessage({this.text, this.sentBy, this.sentAt});

  factory ChatLastMessage.fromJson(Map<String, dynamic> json) {
    return ChatLastMessage(
      text: json['text'] as String?,
      sentBy: json['sentBy']?.toString(),
      sentAt: json['sentAt'] != null ? DateTime.tryParse(json['sentAt']) : null,
    );
  }
}

class ChatRoom {
  final String id;
  final Appointment? appointment;
  final ChatParticipant? patient;
  final ChatDoctorSummary? doctor;
  final ChatParticipant? doctorUser;
  final ChatLastMessage? lastMessage;
  final int patientUnreadCount;
  final int doctorUnreadCount;
  final DateTime? patientLastSeenAt;
  final DateTime? doctorLastSeenAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ChatRoom({
    required this.id,
    this.appointment,
    this.patient,
    this.doctor,
    this.doctorUser,
    this.lastMessage,
    this.patientUnreadCount = 0,
    this.doctorUnreadCount = 0,
    this.patientLastSeenAt,
    this.doctorLastSeenAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['_id']?.toString() ?? '',
      appointment: json['appointment'] != null
          ? Appointment.fromJson(Map<String, dynamic>.from(json['appointment']))
          : null,
      patient: json['patient'] != null
          ? ChatParticipant.fromJson(Map<String, dynamic>.from(json['patient']))
          : null,
      doctor: json['doctor'] != null
          ? ChatDoctorSummary.fromJson(
              Map<String, dynamic>.from(json['doctor']),
            )
          : null,
      doctorUser: json['doctorUser'] != null
          ? ChatParticipant.fromJson(
              Map<String, dynamic>.from(json['doctorUser']),
            )
          : null,
      lastMessage: json['lastMessage'] != null
          ? ChatLastMessage.fromJson(
              Map<String, dynamic>.from(json['lastMessage']),
            )
          : null,
      patientUnreadCount: json['patientUnreadCount'] as int? ?? 0,
      doctorUnreadCount: json['doctorUnreadCount'] as int? ?? 0,
      patientLastSeenAt: json['patientLastSeenAt'] != null
          ? DateTime.tryParse(json['patientLastSeenAt'])
          : null,
      doctorLastSeenAt: json['doctorLastSeenAt'] != null
          ? DateTime.tryParse(json['doctorLastSeenAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }
}

class ChatMessage {
  final String id;
  final String roomId;
  final ChatParticipant? sender;
  final String body;
  final DateTime? createdAt;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.body,
    this.sender,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id']?.toString() ?? '',
      roomId: json['room']?.toString() ?? '',
      body: json['body'] as String? ?? '',
      sender: json['sender'] != null
          ? ChatParticipant.fromJson(Map<String, dynamic>.from(json['sender']))
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}

class ChatMessagesPage {
  final List<ChatMessage> messages;
  final String? nextCursor;

  ChatMessagesPage({required this.messages, this.nextCursor});

  factory ChatMessagesPage.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map(
          (item) => ChatMessage.fromJson(
            Map<String, dynamic>.from(item as Map<String, dynamic>),
          ),
        )
        .toList();
    return ChatMessagesPage(
      messages: list,
      nextCursor: json['nextCursor']?.toString(),
    );
  }
}
