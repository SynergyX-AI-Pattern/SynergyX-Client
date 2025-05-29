import 'package:flutter/material.dart';

class InfoCardGroup extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> rows; // 변경된 타입

  const InfoCardGroup({
    super.key,
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: CardStyles.title),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Color(0xFFAEAEAE), blurRadius: 3),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double itemWidth = (constraints.maxWidth - 40) / 3;
                  return Wrap(
                    spacing: 20,
                    runSpacing: 12,
                    children: rows.map((row) {
                      final label = row['label'] as String;
                      final value = row['value'] as String;
                      final color = row['color'] as Color? ?? Colors.black; // 기본값 검정

                      return SizedBox(
                        width: itemWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(label, style: CardStyles.subtitle),
                            const SizedBox(height: 4),
                            Text(
                              value,
                              style: CardStyles.cost.copyWith(color: color),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
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

// styles
class CardStyles {
  static const TextStyle title = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: Color(0xFF03314B),
  );

  static const TextStyle subtitle = TextStyle(
      color: Color(0xFF8198A5),
      fontSize: 12
  );

  static const TextStyle cost = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );
}
