import 'package:flutter/material.dart';
import 'package:stockapp/screens/chart/chart_screen.dart';
import 'package:stockapp/screens/diary_screen.dart';
import 'package:stockapp/screens/interest/interest_screen.dart';
import 'package:stockapp/screens/main_screen.dart';
import 'package:stockapp/screens/mypage_screen.dart';

class Tabview extends StatefulWidget {
  const Tabview({super.key});

  @override
  State<Tabview> createState() => _TabviewState();
}

class _TabviewState extends State<Tabview> {
  int _index = 0;

  final _pages = <Widget>[
    MainScreen(),
    InterestScreen(),
    ChartScreen(),
    DiaryScreen(),
    MypageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 키보드가 올라오면 body를 올려서 가려지지 않게
      resizeToAvoidBottomInset: true,

      // (옵션) 페이지 상태 보존
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),

      bottomNavigationBar: SafeArea(
        bottom: false, // 바텀만 보호
        child: BottomNavigationBar(
          currentIndex: _index,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: const Color(0xFFB3B3B3),

          // 줄바꿈/확대 대비: 폰트 크기를 명시
          selectedFontSize: 12,
          unselectedFontSize: 12,
          showUnselectedLabels: true,

          onTap: (value) => setState(() => _index = value),

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
  }
}
