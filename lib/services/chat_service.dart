import 'package:door/services/api_client.dart';
import 'package:door/services/models/api_response.dart';
import 'package:door/services/models/chat_models.dart';

class ChatService {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<List<ChatRoom>>> getRooms() async {
    try {
      final response = await _client.get('/chat/rooms');
      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        final rooms = (data['data'] as List<dynamic>? ?? [])
            .map(
              (room) => ChatRoom.fromJson(
                Map<String, dynamic>.from(room as Map<String, dynamic>),
              ),
            )
            .toList();
        return ApiResponse<List<ChatRoom>>(success: true, data: rooms);
      }

      return ApiResponse<List<ChatRoom>>(
        success: false,
        message: data['message'] ?? 'Failed to load chats',
      );
    } catch (e) {
      return ApiResponse<List<ChatRoom>>(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<ChatRoom>> createOrGetRoom(String appointmentId) async {
    try {
      final response = await _client.post(
        '/chat/rooms',
        body: {'appointmentId': appointmentId},
      );
      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse<ChatRoom>(
          success: true,
          data: ChatRoom.fromJson(
            Map<String, dynamic>.from(data['data'] as Map<String, dynamic>),
          ),
        );
      }

      return ApiResponse<ChatRoom>(
        success: false,
        message: data['message'] ?? 'Unable to create chat',
        errors: data['errors'] != null
            ? Map<String, dynamic>.from(data['errors'])
            : null,
      );
    } catch (e) {
      return ApiResponse<ChatRoom>(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<ChatMessagesPage>> getMessages(
    String roomId, {
    String? cursor,
    int limit = 30,
  }) async {
    try {
      final response = await _client.get(
        '/chat/rooms/$roomId/messages',
        queryParams: {
          'limit': limit.toString(),
          if (cursor != null) 'cursor': cursor,
        },
      );
      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse<ChatMessagesPage>(
          success: true,
          data: ChatMessagesPage.fromJson(data),
        );
      }

      return ApiResponse<ChatMessagesPage>(
        success: false,
        message: data['message'] ?? 'Failed to load messages',
      );
    } catch (e) {
      return ApiResponse<ChatMessagesPage>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<ChatMessage>> sendMessage(
    String roomId,
    String body,
  ) async {
    try {
      final response = await _client.post(
        '/chat/rooms/$roomId/messages',
        body: {'body': body},
      );
      final data = _client.parseResponse(response);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        return ApiResponse<ChatMessage>(
          success: true,
          data: ChatMessage.fromJson(
            Map<String, dynamic>.from(data['data'] as Map<String, dynamic>),
          ),
        );
      }

      return ApiResponse<ChatMessage>(
        success: false,
        message: data['message'] ?? 'Failed to send message',
      );
    } catch (e) {
      return ApiResponse<ChatMessage>(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<bool>> markRoomRead(String roomId) async {
    try {
      final response = await _client.patch('/chat/rooms/$roomId/read');
      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse<bool>(success: true, data: true);
      }

      return ApiResponse<bool>(
        success: false,
        message: data['message'] ?? 'Failed to update read status',
      );
    } catch (e) {
      return ApiResponse<bool>(success: false, message: e.toString());
    }
  }
}


