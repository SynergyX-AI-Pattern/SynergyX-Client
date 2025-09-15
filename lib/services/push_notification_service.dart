import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

import 'package:stockapp/services/user_service.dart';

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await Firebase.initializeApp();

    // iOS 권한 요청
    await _messaging.requestPermission();

    // FCM 토큰을 얻은 뒤 서버에 저장
    final token = await _messaging.getToken();
    debugPrint("🔥 FCM Token: $token");
    if (token != null) {
      try {
        await UserService().saveFcmToken(token);
      } catch (e) {
        debugPrint("⚠️ FCM 토큰 저장 실패: $e");
      }
    }

    // 토큰 갱신 감지
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint("🆕 New FCM Token: $newToken");
      try {
        await UserService().saveFcmToken(newToken);
      } catch (e) {
        debugPrint("⚠️ 갱신된 FCM 토큰 저장 실패: $e");
      }
    });

    // 알림 채널 설정 (Android)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: '중요한 알림을 위한 채널입니다.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 포그라운드 알림 수신
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final n = message.notification;
      if (n != null) {
        _localNotifications.show(
          message.hashCode,
          n.title,
          n.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription: '중요한 알림을 위한 채널입니다.',
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    // 알림 클릭 처리
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("📲 알림 클릭됨: ${message.data}");
    });
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("📦 백그라운드 메시지: ${message.messageId}");
}
