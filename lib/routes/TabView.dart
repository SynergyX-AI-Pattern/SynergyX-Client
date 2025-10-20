import 'package:flutter/material.dart';
import 'package:stockapp/screens/chart/chart_screen.dart';
import 'package:stockapp/screens/diary_screen.dart';
import 'package:stockapp/screens/interest/interest_screen.dart';
import 'package:stockapp/screens/main_screen.dart';
import 'package:stockapp/screens/mypage_screen.dart';

/// 앱 전체 탭 전환을 제어할 전역 notifier
final tabIndexNotifier = ValueNotifier<int>(0);

class Tabview extends StatefulWidget {
  const Tabview({super.key});

  @override
  State<Tabview> createState() => _TabviewState();
}

class _TabviewState extends State<Tabview> {
  final _pages = const <Widget>[
    MainScreen(),
    InterestScreen(),
    ChartScreen(),
    DiaryScreen(),
    MypageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: tabIndexNotifier,
      builder: (context, index, _) {
        return Scaffold(
          resizeToAvoidBottomInset: true,

          // index notifier 값으로 제어
          body: IndexedStack(
            index: index,
            children: _pages,
          ),

          bottomNavigationBar: SafeArea(
            bottom: false,
            child: BottomNavigationBar(
              currentIndex: index,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: Colors.black,
              unselectedItemColor: const Color(0xFFB3B3B3),
              selectedFontSize: 12,
              unselectedFontSize: 12,
              showUnselectedLabels: true,

              onTap: (value) => tabIndexNotifier.value = value, // notifier 업데이트

              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded, size: 28),
                  label: '홈',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_rounded, size: 28),
                  label: '관심종목',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.show_chart_outlined, size: 28),
                  label: '패턴',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.sentiment_satisfied_alt, size: 28),
                  label: '감정일기',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person, size: 30),
                  label: 'My',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
