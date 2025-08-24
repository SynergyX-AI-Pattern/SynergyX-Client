import 'package:flutter/material.dart';
import 'package:stockapp/screens/search_screen.dart';
import 'package:stockapp/screens/image_search_screen.dart';

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
      height: 44,
      child: ElevatedButton(
        style: AppButtonStyles.stockSearch,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.search, size: 26, color: Color(0xFF767676)),
                SizedBox(width: 8),
                Text(text, style: AppStyles.buttonText,),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.image_search, color: Color(0xFF767676), size: 26),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ImageSearchScreen()),
                );
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
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
    padding: const EdgeInsets.only(left: 16, right: 4, top: 10, bottom: 10),
    backgroundColor: Color(0xFFEEEEEE),
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
    fontWeight: FontWeight.w500,
    color: Color(0xFFB2B2B2),
  );
}
