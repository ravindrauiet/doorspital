import 'package:door/services/api_client.dart';
import 'package:door/services/models/api_response.dart';

class SupportTicket {
  final String id;
  final String subject;
  final String message;
  final String status;
  final String priority;
  final String? adminResponse;
  final DateTime? resolvedAt;
  final DateTime? createdAt;

  const SupportTicket({
    required this.id,
    required this.subject,
    required this.message,
    required this.status,
    required this.priority,
    this.adminResponse,
    this.resolvedAt,
    this.createdAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['_id']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? 'open',
      priority: json['priority']?.toString() ?? 'medium',
      adminResponse: json['adminResponse']?.toString(),
      resolvedAt: _parseDate(json['resolvedAt']),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }
}

class SupportService {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<Map<String, dynamic>>> createTicket({
    required String subject,
    required String message,
    String priority = 'medium',
  }) async {
    try {
      final response = await _client.post(
        '/support/tickets',
        body: {
          'subject': subject,
          'message': message,
          'priority': priority,
        },
      );
      final data = _client.parseResponse(response);

      if (response.statusCode == 201 && data['success'] == true) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          data: Map<String, dynamic>.from(data['data'] ?? {}),
          message: data['message'] ?? 'Support request created',
        );
      }

      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: data['message'] ?? 'Failed to create support request',
        errors: data['errors'],
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<List<SupportTicket>>> getMyTickets() async {
    try {
      final response = await _client.get('/support/tickets/me');
      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        final rawList = (data['data'] as List? ?? const []);
        final tickets = rawList
            .whereType<Map>()
            .map((item) => SupportTicket.fromJson(Map<String, dynamic>.from(item)))
            .toList();

        return ApiResponse<List<SupportTicket>>(
          success: true,
          data: tickets,
        );
      }

      return ApiResponse<List<SupportTicket>>(
        success: false,
        message: data['message'] ?? 'Failed to load support requests',
        errors: data['errors'],
      );
    } catch (e) {
      return ApiResponse<List<SupportTicket>>(
        success: false,
        message: e.toString(),
      );
    }
  }
}
