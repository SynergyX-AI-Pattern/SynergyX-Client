import 'package:flutter/material.dart';

class FinancialInfoBottomSheet extends StatelessWidget {
  const FinancialInfoBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 제목 + 닫기 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '재무 지표 도움말',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '재무 정보란?',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            '기업의 가치와 수익성을 파악하기 위한 기본적인 투자 지표를 보여줍니다.',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 10),

          // 지표 설명 표
          Table(
            border: TableBorder.symmetric(
              inside: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(3),
            },
            children: const [
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      '시가총액',
                      style: TextStyles.title,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      '현재 주가 × 발행 주식 수\n회사의 총 시장가치\n규모가 클수록 시장 내 영향력이 큼',
                      style: TextStyles.content,
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      '배당수익률',
                      style: TextStyles.title,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      '1주당 배당금 ÷ 현재 주가 × 100\n주식을 보유했을 때 얻을 수 있는 연간 배당 수익률',
                      style: TextStyles.content,
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'ROE',
                      style: TextStyles.title,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      '자기자본 대비 순이익 비율로, 기업의 수익성 효율을 보여줌',
                      style: TextStyles.content,
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'PBR',
                      style: TextStyles.title,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      '주가가 순자산가치(자본총계) 대비 몇 배로 거래되는지를 나타냄',
                      style: TextStyles.content,
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'PER',
                      style: TextStyles.title,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      '시가총액/순이익, 주가/EPS \n주당순이익대비 주가 수준을 비교',
                      style: TextStyles.content,
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'PSR',
                      style: TextStyles.title,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      '주가가 매출 대비 몇 배 수준인지를 나타냄',
                      style: TextStyles.content,
                    ),
                  ),
                ],
              ),
            ],
          ),

        ],
      ),
    );
  }
}

class TextStyles {
  static const TextStyle title = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );

  static const TextStyle content = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 13,
  );
}