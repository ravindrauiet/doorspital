import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:door/routes/route_constants.dart';
import 'package:door/services/notification_service.dart';
import 'package:door/services/models/notification_models.dart';
import 'package:door/services/auth_service.dart';
import 'package:door/features/chat/view/chat_screen.dart';

class LocalNotificationManager {
  static final LocalNotificationManager _instance = LocalNotificationManager._internal();
  factory LocalNotificationManager() => _instance;
  LocalNotificationManager._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final NotificationService _notificationService = NotificationService();
  final AuthService _authService = AuthService();

  bool _isInitialized = false;
  bool _isPolling = false;
  Timer? _pollingTimer;
  String? _lastNotificationId;
  GoRouter? _router;

  /// Initialize local notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Android settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
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

      // Create notification channel for Android
      if (Platform.isAndroid) {
        const androidChannel = AndroidNotificationChannel(
          'default',
          'DoctoSpitals Notifications',
          description: 'Notifications for appointments, messages, and updates',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        );
        await _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(androidChannel);
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
  }

  /// Start polling for new notifications
  void startPolling({Duration interval = const Duration(seconds: 30)}) {
    if (_isPolling) return;
    
    stopPolling(); // Stop any existing polling

    _isPolling = true;
    _pollingTimer = Timer.periodic(interval, (_) async {
      await _checkForNewNotifications();
    });

    // Check immediately
    _checkForNewNotifications();
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
  }

  /// Check for new notifications from backend
  Future<void> _checkForNewNotifications() async {
    try {
      // Check if user is authenticated
      final isAuthenticated = await _authService.isAuthenticated();
      if (!isAuthenticated) {
        return;
      }

      // Fetch latest notifications
      final response = await _notificationService.getNotifications(
        page: 1,
        limit: 5, // Only check the latest 5
      );

      if (response.success && response.data != null) {
        final notifications = response.data!.notifications;
        
        if (notifications.isEmpty) return;

        // Find unread notifications
        final unreadNotifications = notifications
            .where((n) => !n.isRead)
            .toList();

        if (unreadNotifications.isEmpty) return;

        // Show notification for the most recent unread one
        final latestNotification = unreadNotifications.first;
        
        // Only show if it's a new notification (different from last one)
        if (_lastNotificationId != latestNotification.id) {
          await _showNotification(latestNotification);
          _lastNotificationId = latestNotification.id;
        }
      }
    } catch (e) {
      print('❌ Error checking for notifications: $e');
    }
  }

  /// Show a local notification
  Future<void> _showNotification(NotificationItem notification) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'default',
        'DoctoSpitals Notifications',
        channelDescription: 'Notifications for appointments, messages, and updates',
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

      // Use notification ID hash as notification ID to avoid duplicates
      final notificationId = notification.id.hashCode;

      await _localNotifications.show(
        notificationId,
        notification.title,
        notification.body,
        details,
        payload: notification.id, // Store notification ID in payload
      );

      print('📱 Notification shown: ${notification.title}');
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload == null || _router == null) return;

    final notificationId = response.payload!;
    print('📱 Notification tapped: $notificationId');

    // Fetch notification details to get type and data
    _handleNotificationNavigation(notificationId);
  }

  /// Navigate based on notification type
  Future<void> _handleNotificationNavigation(String notificationId) async {
    if (_router == null) return;

    try {
      // Fetch notification details
      final response = await _notificationService.getNotifications(page: 1, limit: 50);
      
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

  /// Dispose resources
  void dispose() {
    stopPolling();
  }
}

