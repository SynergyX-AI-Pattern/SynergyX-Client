// lib/widgets/main/StockItems.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockapp/models/StockItemModel.dart';

class StockItems extends StatelessWidget {
  final StockItem stock;

  /// 행 전체 탭 동작(상세 이동 등)
  final VoidCallback? onTap;

  /// 오른쪽 액션(패턴 버튼, 알림 벨 등)을 넣을 수 있는 슬롯
  final Widget? trailing;

  /// 패딩 조절(관심/메인 공통 사용)
  final EdgeInsetsGeometry padding;

  const StockItems({
    super.key,
    required this.stock,
    this.onTap,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(vertical: 2),
  });

  @override
  Widget build(BuildContext context) {
    final isUp = stock.changeRate >= 0;
    final numberFormat = NumberFormat('#,###');

    final priceText = '${numberFormat.format(stock.price)}원';
    final pctText = '${isUp ? '+' : ''}${stock.changeRate.toStringAsFixed(2)}%';

    final pctColor = isUp ? const Color(0xFFDF1525) : const Color(0xFF1573FE);

    final row = Padding(
      padding: padding,
      child: Row(
        children: [
          // 아이콘
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: ClipOval(
              child: Image.network(
                stock.imageUrl,
                width: 40, height: 40, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 40, height: 40,
                  color: const Color(0xFFF8FAFB),
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    width: 40, height: 40, color: const Color(0xFFF8FAFB),
                    child: const Center(
                      child: SizedBox(
                        width: 16, height: 16,
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
            child: Text(
              stock.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.symbolText,
            ),
          ),

          const SizedBox(width: 8),

          // 가격 + 등락률
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(priceText, style: TextStyles.costText),
              Text(pctText, style: TextStyle(fontSize: 14, color: pctColor, fontWeight: FontWeight.bold)),
            ],
          ),

          // 옵션: 오른쪽 액션 슬롯
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );

    // onTap이 있으면 잉크 효과 제공
    return onTap == null
        ? row
        : Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: row),
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
