import 'package:flutter/material.dart';

class InfoCardGroup extends StatelessWidget {
  final String? title;
  final List<Map<String, dynamic>> rows; // 변경된 타입

  const InfoCardGroup({
    super.key,
    this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final hasTitle = (title != null && title!.isNotEmpty); //title 유무

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasTitle) Text(title!, style: CardStyles.title),  //title 존재시 출력
            if (hasTitle) const SizedBox(height: 10),
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
                      final String? subValue = row['subValue']?.toString();
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
                            if (subValue != null && subValue.isNotEmpty) // 값 있을 때만 출력
                              Text(subValue, style: CardStyles.subvalue.copyWith(color: color)),
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
    fontWeight: FontWeight.w700,
    fontSize: 16,
    color: Color(0xFF03314B),
  );

  static const TextStyle subtitle = TextStyle(
      color: Color(0xFF8198A5),
      fontWeight: FontWeight.w400,
      fontSize: 13
  );

  static const TextStyle cost = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );

  static const TextStyle subvalue = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 12,
  );
}
