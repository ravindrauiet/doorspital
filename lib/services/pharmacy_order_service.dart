import 'package:door/services/api_client.dart';
import 'package:door/services/models/api_response.dart';
import 'package:door/services/models/pharmacy_models.dart';

class PharmacyOrderService {
  final ApiClient _client = ApiClient();

  // POST /api/pharmacy/orders
  Future<ApiResponse<PharmacyOrder>> createOrder(
      CreateOrderRequest request) async {
    try {
      final response = await _client.post(
        '/pharmacy/orders',
        body: request.toJson(),
        includeAuth: true, // Authenticated users only
      );

      final data = _client.parseResponse(response);

      if (response.statusCode == 201 && data['success'] == true) {
        return ApiResponse<PharmacyOrder>(
          success: true,
          message: data['message'],
          data: PharmacyOrder.fromJson(data['data'] ?? {}),
        );
      } else {
        return ApiResponse<PharmacyOrder>(
          success: false,
          message: data['message'] ?? 'Failed to create order',
          errors: data['errors'],
        );
      }
    } catch (e) {
      return ApiResponse<PharmacyOrder>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // GET /api/pharmacy/orders/me
  Future<ApiResponse<List<PharmacyOrder>>> getMyOrders() async {
    try {
      final response = await _client.get(
        '/pharmacy/orders/me',
        includeAuth: true, // Authenticated users only
      );

      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        final orders = (data['data'] as List<dynamic>?)
                ?.map((order) =>
                    PharmacyOrder.fromJson(order as Map<String, dynamic>))
                .toList() ??
            [];
        return ApiResponse<List<PharmacyOrder>>(
          success: true,
          data: orders,
        );
      } else {
        return ApiResponse<List<PharmacyOrder>>(
          success: false,
          message: data['message'] ?? 'Failed to fetch orders',
        );
      }
    } catch (e) {
      return ApiResponse<List<PharmacyOrder>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // GET /api/pharmacy/orders/:orderId
  Future<ApiResponse<PharmacyOrder>> getOrderById(String orderId) async {
    try {
      final response = await _client.get(
        '/pharmacy/orders/$orderId',
        includeAuth: true, // Authenticated users only
      );

      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse<PharmacyOrder>(
          success: true,
          data: PharmacyOrder.fromJson(data['data'] ?? {}),
        );
      } else {
        return ApiResponse<PharmacyOrder>(
          success: false,
          message: data['message'] ?? 'Failed to fetch order',
        );
      }
    } catch (e) {
      return ApiResponse<PharmacyOrder>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // GET /api/pharmacy/orders (Admin only)
  Future<ApiResponse<OrdersResponse>> getAllOrders({
    String? status,
    String? paymentStatus,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (paymentStatus != null && paymentStatus.isNotEmpty) {
        queryParams['paymentStatus'] = paymentStatus;
      }

      final response = await _client.get(
        '/pharmacy/orders',
        queryParams: queryParams,
        includeAuth: true, // Admin only
      );

      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse<OrdersResponse>(
          success: true,
          data: OrdersResponse.fromJson(data['data'] ?? {}),
        );
      } else {
        return ApiResponse<OrdersResponse>(
          success: false,
          message: data['message'] ?? 'Failed to fetch orders',
        );
      }
    } catch (e) {
      return ApiResponse<OrdersResponse>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // PATCH /api/pharmacy/orders/:orderId/status (Admin only)
  Future<ApiResponse<PharmacyOrder>> updateOrderStatus(
    String orderId,
    UpdateOrderStatusRequest request,
  ) async {
    try {
      final response = await _client.patch(
        '/pharmacy/orders/$orderId/status',
        body: request.toJson(),
        includeAuth: true, // Admin only
      );

      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse<PharmacyOrder>(
          success: true,
          message: data['message'],
          data: PharmacyOrder.fromJson(data['data'] ?? {}),
        );
      } else {
        return ApiResponse<PharmacyOrder>(
          success: false,
          message: data['message'] ?? 'Failed to update order status',
        );
      }
    } catch (e) {
      return ApiResponse<PharmacyOrder>(
        success: false,
        message: e.toString(),
      );
    }
  }
}

