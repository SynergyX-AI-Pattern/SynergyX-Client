import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stockapp/screens/stock_detail_screen.dart';
import 'package:stockapp/screens/topStock_screen.dart';
import 'package:stockapp/models/StockItemModel.dart';
import 'package:stockapp/widgets/common/RecentStocks.dart';
import 'package:stockapp/widgets/common/dialog/info_dialog.dart';
import 'package:stockapp/widgets/main/StockRankItem.dart';

// Top 20 리스트 카드
class TopStockListCard extends StatelessWidget {
  final List<StockItem> stockList;
  final String title;

  const TopStockListCard({super.key, required this.stockList, required this.title});

  @override
  Widget build(BuildContext context) {
    final topFive = stockList.take(5).toList(); // 상위 5개만 표시

    // title 값에 따라 다이얼로그 내용 다르게 지정
    String dialogTitle;
    String dialogDescription;

    if (title.contains('AI')) {
      dialogTitle = 'AI Top 20 종목';
      dialogDescription =
      'AI 모델이 최근 시장 데이터를 분석하여 가격 \n상승 가능성이 높은 상위 20개 종목을 선별한 리스트입니다.\n\n'
          '매일 갱신되며, 예측 알고리즘에 기반해\n'
          '투자 참고용으로 제공됩니다.';
    } else {
      dialogTitle = 'Top 20 종목';
      dialogDescription =
      '실시간 거래량, 변동률, 관심도 등을 종합해\n'
          '현재 시장에서 가장 주목받는 상위 20개 종목을 보여줍니다.\n\n'
          '데이터는 일정 주기로 자동 갱신됩니다.';
    }

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 텍스트
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HourBasisText(style: TextStyles.timeText),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Text(title, style: TextStyles.topText),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => InfoDialog(
                                title: dialogTitle,
                                description: dialogDescription,
                              ),
                            );
                          },
                          child: const Icon(Icons.info_outline, size: 20, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 구분선
            Container(
              width: 500,
              child: Divider(color: Color(0xFFD9D9D9), thickness: 1.0),
            ),

            // 종목 리스트
            ...topFive.map((stock) {
              return GestureDetector(
                //종목 상세 페이지로 이동
                onTap: () {
                  RecentStocks.add(stock);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailScreen(stock: stock)),
                  );
                },
                child: StockRankItem(stock: stock),
              );
            }),

            const SizedBox(height: 12),

            // 더보기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => TopStocksScreen(stockList: stockList, stockTitle: title),
                    ),
                  );
                },
                child: const Text('더보기', style: TextStyles.buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//현재시간 업데이트
class TextStyles {
  static const TextStyle timeText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );

  static const TextStyle topText = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle buttonText = TextStyle(fontWeight: FontWeight.w700);
}


class HourBasisText extends StatefulWidget {
  final TextStyle? style;
  const HourBasisText({super.key, this.style});

  @override
  State<HourBasisText> createState() => _HourBasisTextState();
}

class _HourBasisTextState extends State<HourBasisText> {
  Timer? _timer;
  late String _label;

  void _update() {
    final now = DateTime.now();
    _label = '${now.hour}시 기준'; // 8:56 -> 8시 기준, 16:45 -> 16시 기준
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _update();
    // 다음 분 경계에 맞춰 1분마다 업데이트
    final now = DateTime.now();
    final toNextMinute = Duration(minutes: 1)
        - Duration(seconds: now.second, milliseconds: now.millisecond);
    _timer = Timer(toNextMinute, () {
      _update();
      _timer = Timer.periodic(const Duration(minutes: 1), (_) => _update());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_label, style: widget.style);
  }
}