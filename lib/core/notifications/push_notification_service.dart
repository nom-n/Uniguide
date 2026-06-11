import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:uniguide/core/auth/auth_service.dart';
import 'firebase_options.dart';

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  bool _initialized = false;
  bool _firebaseReady = false;
  bool get isFirebaseReady => _firebaseReady;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _initializeFirebase();
    if (!_firebaseReady) return;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    await _requestPermission();

    await AuthService.instance.initialize();
    AuthService.instance.authStateChanges.listen((user) {
      if (user == null) return;
      _syncCurrentToken();
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      _syncTokenToBackend(token);
    });

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('Foreground notification: ${message.messageId}');
    });

    // لا ننتظر المزامنة هنا لكي لا يعلق التطبيق عند التشغيل بدون إنترنت
    _syncCurrentToken();
  }

  Future<void> _initializeFirebase() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _firebaseReady = true;
    } catch (e) {
      _firebaseReady = false;
      debugPrint('Firebase init skipped: $e');
    }
  }

  Future<void> _requestPermission() async {
    if (kIsWeb) return;
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  Future<void> _syncCurrentToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) return;
    await _syncTokenToBackend(token);
  }

  Future<void> _syncTokenToBackend(String token) async {
    if (!AuthService.instance.isAuthenticated) return;
    try {
      await AuthService.instance.saveDeviceFcmToken(
        fcmToken: token,
        platform: _platformName(),
      );
    } catch (e) {
      debugPrint('FCM token sync failed: $e');
    }
  }

  String _platformName() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (_) {
    // Ignore background handler init errors in non-Firebase environments.
  }
  debugPrint('Background notification: ${message.messageId}');
}
