import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:stockapp/screens/login_screen.dart';
import 'package:stockapp/services/push_notification_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage( //얘가 앞에 있는게 좋다고 해서 수정
    PushNotificationService.firebaseMessagingBackgroundHandler,
  );

  await PushNotificationService.initialize();

  await initializeDateFormatting('ko', null);
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
        fontFamily: 'Pretendard' //폰트 추가
      ),
      home: const LoginScreen(),  // MainScreen 호출
    );
  }
}
