// screens/watchlist/widgets/watchlist_item.dart
import 'package:flutter/material.dart';
import 'package:stockapp/screens/interest/interest_pattern_screen.dart';
import 'package:stockapp/widgets/common/app_button.dart';
import 'package:stockapp/widgets/interest/pattern_alert_button.dart';
import '../../../models/stock.dart';

class WatchlistItem extends StatelessWidget {
  final Stock stock;
  final VoidCallback? onTap;

  const WatchlistItem({super.key, required this.stock, this.onTap});

  @override
  Widget build(BuildContext context) {
    // final up = stock.changePct >= 0;
    // final changeText =
    //     '${up ? '+' : ''}${stock.changePct.toStringAsFixed(2)}%';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // 종목 이미지
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: ClipOval(
                child: Image.network(
                  stock.imageUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        width: 40,
                        height: 40,
                        color: const Color(0xFFF8FAFB),
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 40,
                      height: 40,
                      color: const Color(0xFFF8FAFB),
                      child: const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(width: 10),

            // 종목명
            Expanded(
              flex: 2,
              child: Text(stock.name, style: TextStyles.symbolText),
            ),

            // 3) 가격/변동률
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.end,
            //   children: [
            //     Text('\$${stock.price.toStringAsFixed(2)}',
            //         style: const TextStyle(
            //             fontSize: 16, fontWeight: FontWeight.w600)),
            //     const SizedBox(height: 4),
            //     Container(
            //       padding:
            //       const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            //       decoration: BoxDecoration(
            //         color: up ? Colors.green.withOpacity(.1) : Colors.red.withOpacity(.1),
            //         borderRadius: BorderRadius.circular(999),
            //       ),
            //       child: Text(
            //         changeText,
            //         style: TextStyle(
            //           fontSize: 12,
            //           color: up ? Colors.green : Colors.red,
            //           fontWeight: FontWeight.w600,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(width: 8),

            // 4) 패턴 버튼
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: AppButton(
                label: '패턴',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => InterestPatternScreen(
                            /*넘겨줄 값*/
                            stockId: stock.id, // 모델에 맞게 전달
                            stockName: stock.name,
                            stockImageUrl: stock.imageUrl,
                          ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TextStyles {
  static const TextStyle costText = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );

  static const TextStyle symbolText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );
}
