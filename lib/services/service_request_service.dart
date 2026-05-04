import 'package:door/services/api_client.dart';
import 'package:door/services/models/api_response.dart';

class ServiceRequestPayload {
  final String name;
  final String mobileNumber;
  final String requestFor;
  final String requesterName;
  final String requesterMobileNumber;
  final String serviceType;
  final String serviceKey;
  final String serviceTitle;
  final String providerKind;
  final String providerId;
  final String providerName;
  final String providerPhone;
  final String notes;

  const ServiceRequestPayload({
    required this.name,
    required this.mobileNumber,
    this.requestFor = 'self',
    this.requesterName = '',
    this.requesterMobileNumber = '',
    required this.serviceType,
    required this.serviceKey,
    required this.serviceTitle,
    required this.providerKind,
    required this.providerId,
    required this.providerName,
    required this.providerPhone,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'mobileNumber': mobileNumber,
    'requestFor': requestFor,
    'requesterName': requesterName,
    'requesterMobileNumber': requesterMobileNumber,
    'serviceType': serviceType,
    'serviceKey': serviceKey,
    'serviceTitle': serviceTitle,
    'providerKind': providerKind,
    'providerId': providerId,
    'providerName': providerName,
    'providerPhone': providerPhone,
    'notes': notes,
  };
}

class ServiceRequestService {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<Map<String, dynamic>>> submitRequest(
    ServiceRequestPayload payload,
  ) async {
    try {
      final response = await _client.post(
        '/service-requests',
        body: payload.toJson(),
        includeAuth: false,
      );
      final data = _client.parseResponse(response);

      if (response.statusCode == 201 && data['success'] == true) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          data: Map<String, dynamic>.from(data['data'] as Map? ?? const {}),
          message: data['message']?.toString(),
        );
      }

      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: data['message']?.toString() ?? 'Failed to submit service request',
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: e.toString(),
      );
    }
  }
}
