import 'dart:io';
import 'package:door/services/api_client.dart';
import 'package:door/services/models/api_response.dart';
import 'package:door/services/models/doctor_models.dart';
import 'package:http/http.dart' as http;

class DoctorService {
  final ApiClient _client = ApiClient();

  // GET /api/doctors/top
  Future<ApiResponse<List<Doctor>>> getTopDoctors({
    String? specialization,
    String? city,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (specialization != null) queryParams['specialization'] = specialization;
      if (city != null) queryParams['city'] = city;

      final response = await _client.get(
        '/doctors/top',
        queryParams: queryParams,
        includeAuth: false,
      );

      final data = _client.parseResponse(response);

      if (response.statusCode == 200) {
        final doctors = (data['data'] as List<dynamic>?)
                ?.map((doc) => Doctor.fromJson(doc as Map<String, dynamic>))
                .toList() ??
            [];
        return ApiResponse<List<Doctor>>(
          success: true,
          data: doctors,
        );
      } else {
        return ApiResponse<List<Doctor>>(
          success: false,
          message: data['message'] ?? 'Failed to fetch doctors',
        );
      }
    } catch (e) {
      return ApiResponse<List<Doctor>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // POST /api/doctors/sign-up
  Future<ApiResponse<Map<String, dynamic>>> doctorSignUp(
      DoctorSignUpRequest request) async {
    try {
      final response = await _client.post(
        '/doctors/sign-up',
        body: request.toJson(),
        includeAuth: false,
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
          message: data['message'] ?? 'Doctor sign up failed',
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

  // GET /api/doctors/verification/:doctorId
  Future<ApiResponse<Map<String, dynamic>>> getVerificationStatus(
      String doctorId) async {
    try {
      final response = await _client.get(
        '/doctors/verification/$doctorId',
        includeAuth: false,
      );

      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          data: data['data'],
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: data['message'] ?? 'Failed to get verification status',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // POST /api/doctors/verification/submit
  Future<ApiResponse<Map<String, dynamic>>> submitVerification(
    DoctorVerificationRequest request, {
    required File mbbsCertificate,
    File? mdMsBdsCertificate,
    required File registrationCertificate,
    required File governmentId,
    required File selfie,
  }) async {
    try {
      // Prepare files
      final files = <String, List<http.MultipartFile>>{
        'mbbsCertificate': [
          await http.MultipartFile.fromPath(
            'mbbsCertificate',
            mbbsCertificate.path,
          ),
        ],
        'registrationCertificate': [
          await http.MultipartFile.fromPath(
            'registrationCertificate',
            registrationCertificate.path,
          ),
        ],
        'governmentId': [
          await http.MultipartFile.fromPath(
            'governmentId',
            governmentId.path,
          ),
        ],
        'selfie': [
          await http.MultipartFile.fromPath(
            'selfie',
            selfie.path,
          ),
        ],
      };

      if (mdMsBdsCertificate != null) {
        files['mdMsBdsCertificate'] = [
          await http.MultipartFile.fromPath(
            'mdMsBdsCertificate',
            mdMsBdsCertificate.path,
          ),
        ];
      }

      final response = await _client.postMultipart(
        '/doctors/verification/submit',
        fields: request.toFormFields(),
        files: files,
        includeAuth: false,
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
          message: data['message'] ?? 'Verification submission failed',
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

  // POST /api/doctors/:doctorId/availability/set
  Future<ApiResponse<Map<String, dynamic>>> setAvailability(
    String doctorId,
    SetAvailabilityRequest request,
  ) async {
    try {
      final response = await _client.post(
        '/doctors/$doctorId/availability/set',
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
          message: data['message'] ?? 'Failed to set availability',
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

  // GET /api/doctors/:doctorId/availability/schedule
  Future<ApiResponse<AvailabilityResponse>> getAvailabilitySchedule(
    String doctorId, {
    String? start,
    int? days,
    String? tz,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (start != null) queryParams['start'] = start;
      if (days != null) queryParams['days'] = days.toString();
      if (tz != null) queryParams['tz'] = tz;

      final response = await _client.get(
        '/doctors/$doctorId/availability/schedule',
        queryParams: queryParams,
        includeAuth: false,
      );

      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse<AvailabilityResponse>(
          success: true,
          data: AvailabilityResponse.fromJson(data['data'] ?? {}),
        );
      } else {
        return ApiResponse<AvailabilityResponse>(
          success: false,
          message: data['message'] ?? 'Failed to get availability',
        );
      }
    } catch (e) {
      return ApiResponse<AvailabilityResponse>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // GET /api/doctor/:doctorId
  Future<ApiResponse<Doctor>> getDoctor(String doctorId) async {
    try {
      final response = await _client.get(
        '/doctor/$doctorId',
        includeAuth: false,
      );

      final data = _client.parseResponse(response);

      if (response.statusCode == 200) {
        return ApiResponse<Doctor>(
          success: true,
          data: Doctor.fromJson(data['data'] ?? {}),
        );
      } else {
        return ApiResponse<Doctor>(
          success: false,
          message: data['message'] ?? 'Doctor not found',
        );
      }
    } catch (e) {
      return ApiResponse<Doctor>(
        success: false,
        message: e.toString(),
      );
    }
  }
}





