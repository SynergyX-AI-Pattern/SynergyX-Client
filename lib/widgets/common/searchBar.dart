import 'package:flutter/material.dart';
import 'package:stockapp/screens/search_screen.dart';

class StockSerachBar extends StatelessWidget {
  final String text;

  const StockSerachBar({super.key, required this.text});

  void _handleDetail2(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StockSearchPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width * 0.9,
      child: ElevatedButton(
        style: AppButtonStyles.stockSearch,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(Icons.search, size: 26, color: Colors.grey),
            SizedBox(width: 8),
            Text(text, style: AppStyles.buttonText,),
          ],
        ),
        onPressed: () => _handleDetail2(context),
      ),
    );
  }
}

// styles
class AppButtonStyles {
  static final ButtonStyle stockSearch = ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    backgroundColor: Color(0xFFF9F9F9),
    //버튼 배경색
    // 버튼 클릭 효과 삭제
    elevation: 0,
    splashFactory: NoSplash.splashFactory,
    shadowColor: Colors.transparent,
    // 라운드 처리
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}

class AppStyles {
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFFB2B2B2),
  );
}
