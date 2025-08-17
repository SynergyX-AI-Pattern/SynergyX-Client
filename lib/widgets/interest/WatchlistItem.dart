// screens/watchlist/widgets/watchlist_item.dart
import 'package:flutter/material.dart';
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
              child: OutlinedButton(
                onPressed: () {
                  /* 패턴 화면 */
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 9,
                  ),
                  // 내부 여백 축소
                  minimumSize: const Size(0, 0),
                  // 기본 최소 크기 없애기
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  // 터치 타겟 축소 허용
                  backgroundColor: const Color(0xFF000000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '패턴',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ),

            // 5) 알림 벨
            IconButton(
              onPressed: () {
                /* 알림 토글 */
              },
              icon: Icon(Icons.notifications_none),
              splashRadius: 20,
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
