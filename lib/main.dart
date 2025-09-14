import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:stockapp/screens/login_screen.dart';
import 'package:stockapp/routes/TabView.dart';
import 'package:stockapp/services/auth_state.dart';
import 'package:stockapp/services/push_notification_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage( //얘가 앞에 있는게 좋다고 해서 수정
    PushNotificationService.firebaseMessagingBackgroundHandler,
  );

  await PushNotificationService.initialize();

  await initializeDateFormatting('ko', null);
  // 저장된 토큰/유저 정보를 불러와 자동 로그인 여부 확인
  await AuthState.loadFromPrefs();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Pretendard', //폰트 추가
      ),
      // 토큰이 있으면 바로 Tabview로 진입하여 자동 로그인
      home: AuthState.accessToken != null
          ? const Tabview()
          : const LoginScreen(),
    );
  }
}