import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:stockapp/screens/login_screen.dart';
import 'package:stockapp/routes/TabView.dart';
import 'package:stockapp/services/auth_state.dart';
import 'package:stockapp/services/push_notification_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await PushNotificationService.initialize();

  await initializeDateFormatting('ko', null);
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
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.white,
        ),
      ),

      // 토큰이 있으면 바로 Tabview로 진입하여 자동 로그인
      home: AuthState.accessToken != null
          ? const Tabview()
          : const LoginScreen(),
    );
  }
}