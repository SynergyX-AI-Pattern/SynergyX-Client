import 'package:flutter/material.dart';
import 'package:stockapp/screens/chart_screen.dart';
import 'package:stockapp/screens/diary_screen.dart';
import 'package:stockapp/screens/interest_screen.dart';
import 'package:stockapp/screens/main_screen.dart';
import 'package:stockapp/screens/mypage_screen.dart';

class Tabview extends StatefulWidget {
  const Tabview({super.key});

  @override
  State<Tabview> createState() => _TabviewState();
}

class _TabviewState extends State<Tabview> {
  var _index = 0;

  List<Widget> _pages = [
    MainScreen(),
    InterestScreen(),
    ChartScreen(),
    DairyScreen(),
    MypageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index], // 현재 선택된 화면을 여기에 렌더링
      bottomNavigationBar: SizedBox(
        height: 70,
        child: BottomNavigationBar(
          currentIndex: _index,
          backgroundColor: Colors.white,
          // 또는 원하는 배경색
          selectedItemColor: Colors.black,
          // 선택된 아이템 색상
          unselectedItemColor: Color(0xFFB3B3B3),
          // 선택되지 않은 아이템 색상
          selectedLabelStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.normal,
          ),
          // 선택된 라벨 스타일
          unselectedLabelStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.normal,
          ),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: (value) {
            setState(() {
              _index = value;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded, size: 29),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_rounded, size: 29),
              label: '관심종목',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart_outlined, size: 29),
              label: '패턴',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sentiment_satisfied_alt, size: 29),
              label: '감정일기',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 32),
              label: 'My',
            ),
          ],
        ),
      ),
    );
  }
}
