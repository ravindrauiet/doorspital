import 'package:door/services/api_client.dart';
import 'package:door/services/models/api_response.dart';
import 'package:door/services/models/appointment_models.dart';

class AppointmentService {
  final ApiClient _client = ApiClient();

  // GET /api/appointments/doctors/available
  Future<ApiResponse<SearchAvailableDoctorsResponse>>
      searchAvailableDoctors({
    required String date, // YYYY-MM-DD format
    String? specialization,
    String? city,
  }) async {
    try {
      final queryParams = <String, String>{
        'date': date,
      };
      if (specialization != null) {
        queryParams['specialization'] = specialization;
      }
      if (city != null) {
        queryParams['city'] = city;
      }

      final response = await _client.get(
        '/appointments/doctors/available',
        queryParams: queryParams,
        includeAuth: false,
      );

      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse<SearchAvailableDoctorsResponse>(
          success: true,
          data: SearchAvailableDoctorsResponse.fromJson(data['data'] ?? {}),
        );
      } else {
        return ApiResponse<SearchAvailableDoctorsResponse>(
          success: false,
          message: data['message'] ?? 'Failed to search available doctors',
        );
      }
    } catch (e) {
      return ApiResponse<SearchAvailableDoctorsResponse>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // POST /api/appointments/book
  Future<ApiResponse<Map<String, dynamic>>> bookAppointment(
      BookAppointmentRequest request) async {
    try {
      final response = await _client.post(
        '/appointments/book',
        body: request.toJson(),
      );

      final data = _client.parseResponse(response);

      if (response.statusCode == 201 && data['success'] == true) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: data['message'],
          data: data['data'],
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: data['message'] ?? 'Failed to book appointment',
          errors: data['errors'],
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // GET /api/appointments/my-appointments
  Future<ApiResponse<List<Appointment>>> getMyAppointments({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (status != null) queryParams['status'] = status;

      final response = await _client.get(
        '/appointments/my-appointments',
        queryParams: queryParams,
      );

      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        final appointments = (data['data'] as List<dynamic>?)
                ?.map((apt) =>
                    Appointment.fromJson(apt as Map<String, dynamic>))
                .toList() ??
            [];
        return ApiResponse<List<Appointment>>(
          success: true,
          data: appointments,
        );
      } else {
        return ApiResponse<List<Appointment>>(
          success: false,
          message: data['message'] ?? 'Failed to get appointments',
        );
      }
    } catch (e) {
      return ApiResponse<List<Appointment>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // PUT /api/appointments/:appointmentId/cancel
  Future<ApiResponse<Map<String, dynamic>>> cancelAppointment(
      String appointmentId) async {
    try {
      final response = await _client.put(
        '/appointments/$appointmentId/cancel',
      );

      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: data['message'],
          data: data['data'],
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: data['message'] ?? 'Failed to cancel appointment',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: e.toString(),
      );
    }
  }
}



