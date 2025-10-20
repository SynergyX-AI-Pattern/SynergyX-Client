import 'package:flutter/material.dart';
import 'package:stockapp/models/stock_brief.dart';

class StockTile extends StatelessWidget {
  final StockBrief item;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  const StockTile({
    super.key,
    required this.item,
    this.leading,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (leading != null) leading!,
              if (leading != null) const SizedBox(width: 8),

              /// 종목 이미지
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFF0F2F5),
                backgroundImage:
                item.imageUrl != null ? NetworkImage(item.imageUrl!) : null,
                child: item.imageUrl == null
                    ? Text(
                  item.stockName.isNotEmpty
                      ? item.stockName.characters.first
                      : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                )
                    : null,
              ),

              const SizedBox(width: 12),

              /// 종목명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.stockName,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                  ],
                ),
              ),

              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
