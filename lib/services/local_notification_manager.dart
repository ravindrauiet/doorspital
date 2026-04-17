import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:door/routes/route_constants.dart';
import 'package:door/services/notification_service.dart';
import 'package:door/services/models/notification_models.dart';
import 'package:door/services/auth_service.dart';
import 'package:door/services/appointment_service.dart';
import 'package:door/features/chat/view/chat_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LocalNotificationManager {
  static final LocalNotificationManager _instance =
      LocalNotificationManager._internal();
  factory LocalNotificationManager() => _instance;
  LocalNotificationManager._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final NotificationService _notificationService = NotificationService();
  final AppointmentService _appointmentService = AppointmentService();
  final AuthService _authService = AuthService();

  bool _isInitialized = false;
  bool _isPolling = false;
  Timer? _pollingTimer;
  GoRouter? _router;
  RemoteMessage? _pendingOpenedMessage;

  // Track appointments that have already been notified (to avoid duplicates)
  final Set<String> _notifiedAppointmentIds = {};

  // Track notifications that have already been shown (to avoid duplicates)
  final Set<String> _shownNotificationIds = {};

  /// Initialize local notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Skip initialization on web platform
    if (kIsWeb) {
      print('⚠️ Local notifications not supported on web platform');
      _isInitialized = true; // Mark as initialized to prevent retries
      return;
    }

    try {
      // Initialize Android settings
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // Initialize iOS settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create notification channel for Android (skip on web)
      if (!kIsWeb) {
        try {
          // Try to get Android implementation
          final androidImplementation = _localNotifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

          if (androidImplementation != null) {
            const androidChannel = AndroidNotificationChannel(
              'default',
              'DoctoSpitals Notifications',
              description:
                  'Notifications for appointments, messages, and updates',
              importance: Importance.high,
              playSound: true,
              enableVibration: true,
            );
            await androidImplementation.createNotificationChannel(
              androidChannel,
            );
          }
        } catch (e) {
          print('⚠️ Could not create Android notification channel: $e');
        }
      }

      _isInitialized = true;
      print('✅ Local notifications initialized');
    } catch (e) {
      print('❌ Error initializing local notifications: $e');
    }
  }

  /// Set router for navigation
  void setRouter(GoRouter router) {
    _router = router;
    final pendingMessage = _pendingOpenedMessage;
    if (pendingMessage != null) {
      _pendingOpenedMessage = null;
      unawaited(handleRemoteMessageOpened(pendingMessage));
    }
  }

  /// Start polling for new notifications
  void startPolling({Duration interval = const Duration(seconds: 30)}) {
    if (_isPolling) return;

    stopPolling(); // Stop any existing polling

    _isPolling = true;
    _pollingTimer = Timer.periodic(interval, (_) async {
      await _checkForNewNotifications();
      await _checkUpcomingAppointments();
    });

    // Check immediately
    _checkForNewNotifications();
    _checkUpcomingAppointments();
  }

  /// Stop polling for notifications
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
  }

  /// Manually check for new notifications (useful when app comes to foreground)
  Future<void> checkNow() async {
    await _checkForNewNotifications();
    await _checkUpcomingAppointments();
  }

  /// Check for new notifications from backend
  Future<void> _checkForNewNotifications() async {
    try {
      // Check if user is authenticated
      final isAuthenticated = await _authService.isAuthenticated();
      if (!isAuthenticated) {
        return;
      }

      // Fetch latest notifications - increase limit to catch more chat messages
      final response = await _notificationService.getNotifications(
        page: 1,
        limit: 20, // Check more notifications to catch all chat messages
      );

      if (response.success && response.data != null) {
        final notifications = response.data!.notifications;

        if (notifications.isEmpty) return;

        // Find unread notifications that haven't been shown yet
        final unreadNotifications = notifications
            .where((n) => !n.isRead && !_shownNotificationIds.contains(n.id))
            .toList();

        if (unreadNotifications.isEmpty) return;

        // Show notifications for all unread chat messages (sorted by newest first)
        final chatNotifications =
            unreadNotifications.where((n) => n.type == 'chat').toList()
              ..sort((a, b) {
                final aTime = a.createdAt ?? DateTime(0);
                final bTime = b.createdAt ?? DateTime(0);
                return bTime.compareTo(aTime); // Newest first
              });

        // Show the most recent chat notification
        if (chatNotifications.isNotEmpty) {
          final latestChatNotification = chatNotifications.first;
          await _showNotification(latestChatNotification);
          _rememberShownNotification(latestChatNotification.id);
        } else {
          // Show other types of notifications
          final latestNotification = unreadNotifications.first;
          if (!_shownNotificationIds.contains(latestNotification.id)) {
            await _showNotification(latestNotification);
            _rememberShownNotification(latestNotification.id);
          }
        }
      }
    } catch (e) {
      print('❌ Error checking for notifications: $e');
    }
  }

  /// Show a local notification
  Future<void> _showNotification(
    NotificationItem notification, {
    String? payload,
  }) async {
    try {
      // Skip on web
      if (kIsWeb || !_isInitialized) return;

      // Customize notification title and body for chat messages
      String notificationTitle = notification.title;
      String notificationBody = notification.body;

      // For chat messages, enhance the notification text
      if (notification.type == 'chat') {
        // Try to get sender name from data if available
        final senderName = notification.data['senderName'] as String?;
        if (senderName != null && senderName.isNotEmpty) {
          notificationTitle = 'New message from $senderName';
        } else {
          notificationTitle = 'New message from doctor';
        }

        // Truncate body if too long
        if (notificationBody.length > 100) {
          notificationBody = '${notificationBody.substring(0, 100)}...';
        }
      }

      const androidDetails = AndroidNotificationDetails(
        'default',
        'DoctoSpitals Notifications',
        channelDescription:
            'Notifications for appointments, messages, and updates',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        category: AndroidNotificationCategory.message,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'MESSAGE_CATEGORY',
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Use notification ID hash as notification ID to avoid duplicates
      // Add timestamp to ensure uniqueness for multiple notifications
      final notificationId =
          (notification.id.hashCode +
              (notification.createdAt?.millisecondsSinceEpoch ?? 0)) %
          2147483647;

      await _localNotifications.show(
        notificationId,
        notificationTitle,
        notificationBody,
        details,
        payload: payload ?? notification.id,
      );

      print('📱 Notification shown: $notificationTitle - $notificationBody');
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  void _rememberShownNotification(String notificationId) {
    _shownNotificationIds.add(notificationId);
    if (_shownNotificationIds.length <= 100) {
      return;
    }

    final idsToRemove = (_shownNotificationIds.toList()..sort())
        .take(_shownNotificationIds.length - 50)
        .toList();
    _shownNotificationIds.removeAll(idsToRemove);
  }

  dynamic _decodeRemoteValue(dynamic value) {
    if (value is! String) {
      return value;
    }

    final trimmed = value.trim();
    if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
        (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
      try {
        return jsonDecode(trimmed);
      } catch (_) {
        return value;
      }
    }

    return value;
  }

  Map<String, dynamic> _normalizeRemoteData(Map<String, dynamic> data) {
    final normalized = <String, dynamic>{};
    for (final entry in data.entries) {
      normalized[entry.key] = _decodeRemoteValue(entry.value);
    }
    return normalized;
  }

  Future<void> handleForegroundRemoteMessage(RemoteMessage message) async {
    final remoteData = _normalizeRemoteData(message.data);
    final notificationId =
        remoteData['notificationId']?.toString() ??
        message.messageId ??
        DateTime.now().millisecondsSinceEpoch.toString();

    if (_shownNotificationIds.contains(notificationId)) {
      return;
    }

    final title =
        message.notification?.title ??
        remoteData['title']?.toString() ??
        'DoorSpitals';
    final body =
        message.notification?.body ?? remoteData['body']?.toString() ?? '';

    if (title.isEmpty && body.isEmpty) {
      return;
    }

    final notification = NotificationItem(
      id: notificationId,
      title: title,
      body: body,
      isRead: false,
      type: remoteData['type']?.toString(),
      data: remoteData,
      createdAt: DateTime.now(),
    );

    await _showNotification(notification, payload: notificationId);
    _rememberShownNotification(notificationId);
  }

  Future<void> handleRemoteMessageOpened(RemoteMessage message) async {
    if (_router == null) {
      _pendingOpenedMessage = message;
      return;
    }

    await _handleRemoteMessageNavigation(message);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload == null || _router == null) return;

    final payload = response.payload!;
    print('📱 Notification tapped: $payload');

    // Check if it's an appointment reminder
    if (payload.startsWith('appointment:')) {
      // Navigate to home screen (where appointments are shown)
      _router!.goNamed(RouteConstants.bottomNavBarScreen);
      return;
    }

    // Otherwise, handle as regular notification
    _handleNotificationNavigation(payload);
  }

  Future<void> _handleRemoteMessageNavigation(RemoteMessage message) async {
    if (_router == null) return;

    final remoteData = _normalizeRemoteData(message.data);
    final notificationId = remoteData['notificationId']?.toString();
    if (notificationId != null && notificationId.isNotEmpty) {
      await _handleNotificationNavigation(notificationId);
      return;
    }

    final type = remoteData['type']?.toString();
    switch (type) {
      case 'chat':
        final appointmentId = remoteData['appointmentId']?.toString();
        if (appointmentId != null && appointmentId.isNotEmpty) {
          _router!.pushNamed(
            RouteConstants.chatScreen,
            extra: ChatScreenArgs(appointmentId: appointmentId),
          );
          return;
        }
        break;
      case 'appointment':
        _router!.goNamed(RouteConstants.bottomNavBarScreen);
        return;
      default:
        break;
    }

    _router!.pushNamed(RouteConstants.notificationsScreen);
  }

  /// Navigate based on notification type
  Future<void> _handleNotificationNavigation(String notificationId) async {
    if (_router == null) return;

    try {
      // Fetch notification details
      final response = await _notificationService.getNotifications(
        page: 1,
        limit: 50,
      );

      if (response.success && response.data != null) {
        final notification = response.data!.notifications.firstWhere(
          (n) => n.id == notificationId,
          orElse: () => response.data!.notifications.first,
        );

        final type = notification.type;
        final data = notification.data;

        switch (type) {
          case 'chat':
            final roomId = data['roomId'] as String?;
            final appointmentId = data['appointmentId'] as String?;
            if (roomId != null && appointmentId != null) {
              _router!.pushNamed(
                RouteConstants.chatScreen,
                extra: ChatScreenArgs(appointmentId: appointmentId),
              );
            }
            break;

          case 'appointment':
            // Navigate to home screen (appointments tab)
            _router!.goNamed(RouteConstants.bottomNavBarScreen);
            break;

          default:
            // Navigate to notifications screen
            _router!.pushNamed(RouteConstants.notificationsScreen);
            break;
        }

        // Mark as read
        await _notificationService.markAsRead(notificationId);
      }
    } catch (e) {
      print('❌ Error handling notification navigation: $e');
      // Fallback: just go to notifications screen
      _router!.pushNamed(RouteConstants.notificationsScreen);
    }
  }

  /// Show a notification manually (for testing or immediate display)
  Future<void> showNotification({
    required String title,
    required String body,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      isRead: false,
      type: type,
      data: data ?? const {},
      createdAt: DateTime.now(),
    );

    await _showNotification(notification);
  }

  /// Check for upcoming appointments and send 5-minute reminder
  Future<void> _checkUpcomingAppointments() async {
    try {
      // Skip on web
      if (kIsWeb || !_isInitialized) return;

      // Check if user is authenticated
      final isAuthenticated = await _authService.isAuthenticated();
      if (!isAuthenticated) {
        return;
      }

      // Fetch upcoming appointments
      final response = await _appointmentService.getMyAppointments(
        status: 'confirmed', // Only check confirmed appointments
        page: 1,
        limit: 20, // Check up to 20 upcoming appointments
      );

      if (!response.success || response.data == null) {
        return;
      }

      final now = DateTime.now();
      final appointments = response.data!;

      for (final appointment in appointments) {
        // Skip if already notified
        if (_notifiedAppointmentIds.contains(appointment.id)) {
          continue;
        }

        final startTime = appointment.startTime.toLocal();
        final timeUntilAppointment = startTime.difference(now);

        // Check if appointment is starting in exactly 5 minutes (with 30 second tolerance)
        if (timeUntilAppointment.inMinutes == 5 &&
            timeUntilAppointment.inSeconds >= 270 &&
            timeUntilAppointment.inSeconds <= 330) {
          // Get doctor name for the notification
          final doctorName =
              appointment.doctor?.specialization ??
              appointment.doctor?.name ??
              'Doctor';

          // Show notification
          await _showAppointmentReminderNotification(
            appointmentId: appointment.id,
            doctorName: doctorName,
            startTime: startTime,
          );

          // Mark as notified
          _notifiedAppointmentIds.add(appointment.id);

          print('📅 Appointment reminder sent: ${appointment.id}');
        }

        // Clean up old appointment IDs (appointments that have passed)
        if (startTime.isBefore(now)) {
          _notifiedAppointmentIds.remove(appointment.id);
        }
      }
    } catch (e) {
      print('❌ Error checking upcoming appointments: $e');
    }
  }

  /// Show appointment reminder notification
  Future<void> _showAppointmentReminderNotification({
    required String appointmentId,
    required String doctorName,
    required DateTime startTime,
  }) async {
    try {
      final timeStr = _formatTime(startTime);
      final dateStr = _formatDate(startTime);

      const androidDetails = AndroidNotificationDetails(
        'default',
        'DoctoSpitals Notifications',
        channelDescription:
            'Notifications for appointments, messages, and updates',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Use appointment ID hash as notification ID
      final notificationId = appointmentId.hashCode;

      await _localNotifications.show(
        notificationId,
        'Appointment Reminder',
        'Your appointment with $doctorName is in 5 minutes ($dateStr at $timeStr)',
        details,
        payload: 'appointment:$appointmentId',
      );

      print('📱 Appointment reminder notification shown');
    } catch (e) {
      print('❌ Error showing appointment reminder: $e');
    }
  }

  /// Format time for display
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// Format date for display
  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  /// Dispose resources
  void dispose() {
    stopPolling();
    _notifiedAppointmentIds.clear();
  }
}
