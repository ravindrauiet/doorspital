import 'package:door/services/api_client.dart';
import 'package:door/services/models/api_response.dart';
import 'package:door/services/models/notification_models.dart';

class NotificationService {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<NotificationsResult>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        '/notifications',
        queryParams: {'page': page.toString(), 'limit': limit.toString()},
      );

      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        final notifications = (data['data'] as List<dynamic>? ?? [])
            .map(
              (item) => NotificationItem.fromJson(item as Map<String, dynamic>),
            )
            .toList();

        final pagination = data['pagination'] != null
            ? NotificationPagination.fromJson(
                data['pagination'] as Map<String, dynamic>,
              )
            : null;

        return ApiResponse<NotificationsResult>(
          success: true,
          data: NotificationsResult(
            notifications: notifications,
            pagination: pagination,
          ),
        );
      }

      return ApiResponse<NotificationsResult>(
        success: false,
        message: data['message'] ?? 'Failed to fetch notifications',
      );
    } catch (e) {
      return ApiResponse<NotificationsResult>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<NotificationItem>> markAsRead(
    String notificationId,
  ) async {
    try {
      final response = await _client.patch(
        '/notifications/$notificationId/read',
      );

      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse<NotificationItem>(
          success: true,
          message: data['message'],
          data: NotificationItem.fromJson(
            data['data'] as Map<String, dynamic>? ?? const {},
          ),
        );
      }

      return ApiResponse<NotificationItem>(
        success: false,
        message: data['message'] ?? 'Failed to mark notification as read',
      );
    } catch (e) {
      return ApiResponse<NotificationItem>(
        success: false,
        message: e.toString(),
      );
    }
  }
}
