import 'dart:async';
import 'dart:math';

import 'package:door/services/api_client.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef RemoteMessageCallback = Future<void> Function(RemoteMessage message);

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  static const String _deviceIdKey = 'push_device_id';

  final ApiClient _client = ApiClient();
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  bool _initialized = false;
  bool _firebaseReady = false;
  RemoteMessageCallback? _onForegroundMessage;
  RemoteMessageCallback? _onMessageOpened;
  RemoteMessage? _initialMessage;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;

  bool get _supportsPush =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> initialize({
    RemoteMessageCallback? onForegroundMessage,
    RemoteMessageCallback? onMessageOpened,
  }) async {
    _onForegroundMessage = onForegroundMessage;
    _onMessageOpened = onMessageOpened;

    if (_initialized) {
      await _flushInitialMessage();
      return;
    }

    _initialized = true;
    if (!_supportsPush) {
      return;
    }

    try {
      await Firebase.initializeApp();
      _firebaseReady = true;

      await _messaging.requestPermission(alert: true, badge: true, sound: true);

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _messaging.setForegroundNotificationPresentationOptions(
          alert: false,
          badge: true,
          sound: true,
        );
      }

      _messageSubscription = FirebaseMessaging.onMessage.listen((
        message,
      ) async {
        final callback = _onForegroundMessage;
        if (callback != null) {
          await callback(message);
        }
      });

      _messageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen((
        message,
      ) async {
        final callback = _onMessageOpened;
        if (callback != null) {
          await callback(message);
        } else {
          _initialMessage = message;
        }
      });

      _initialMessage = await _messaging.getInitialMessage();

      _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((
        token,
      ) async {
        await registerTokenWithBackend(token: token);
      });

      await _flushInitialMessage();
    } catch (error) {
      debugPrint('Push notification initialization failed: $error');
    }
  }

  Future<void> _flushInitialMessage() async {
    final callback = _onMessageOpened;
    final message = _initialMessage;
    if (callback == null || message == null) {
      return;
    }

    _initialMessage = null;
    await callback(message);
  }

  Future<String?> getToken() async {
    if (!_firebaseReady) {
      return null;
    }

    try {
      return await _messaging.getToken();
    } catch (error) {
      debugPrint('Unable to get FCM token: $error');
      return null;
    }
  }

  Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final random = Random();
    final nextId =
        '${DateTime.now().millisecondsSinceEpoch}-${random.nextInt(1 << 32)}';
    await prefs.setString(_deviceIdKey, nextId);
    return nextId;
  }

  String get _platformLabel {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return 'unknown';
    }
  }

  Future<void> syncTokenIfAuthenticated() async {
    final authToken = await _client.getToken();
    if (authToken == null || authToken.isEmpty) {
      return;
    }

    await registerTokenWithBackend();
  }

  Future<void> registerTokenWithBackend({String? token}) async {
    if (!_firebaseReady) {
      return;
    }

    final authToken = await _client.getToken();
    if (authToken == null || authToken.isEmpty) {
      return;
    }

    final resolvedToken = (token != null && token.trim().isNotEmpty)
        ? token.trim()
        : await getToken();
    if (resolvedToken == null || resolvedToken.isEmpty) {
      return;
    }

    try {
      await _client.post(
        '/notifications/devices',
        body: {
          'token': resolvedToken,
          'platform': _platformLabel,
          'deviceId': await _getOrCreateDeviceId(),
        },
      );
    } catch (error) {
      debugPrint('Unable to register push token: $error');
    }
  }

  Future<void> unregisterTokenFromBackend() async {
    if (!_firebaseReady) {
      return;
    }

    final authToken = await _client.getToken();
    if (authToken == null || authToken.isEmpty) {
      return;
    }

    final token = await getToken();
    final deviceId = await _getOrCreateDeviceId();

    if ((token == null || token.isEmpty) && deviceId.isEmpty) {
      return;
    }

    try {
      await _client.post(
        '/notifications/devices/remove',
        body: {
          if (token != null && token.isNotEmpty) 'token': token,
          'deviceId': deviceId,
        },
      );
    } catch (error) {
      debugPrint('Unable to unregister push token: $error');
    }
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _messageSubscription?.cancel();
    await _messageOpenedSubscription?.cancel();
  }
}
