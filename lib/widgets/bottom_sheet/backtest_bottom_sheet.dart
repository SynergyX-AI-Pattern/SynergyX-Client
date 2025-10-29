import 'package:flutter/material.dart';

class BacktestBottomSheet extends StatelessWidget {
  const BacktestBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 제목 및 닫기 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '백테스팅 지표 설명',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 표 형태
              Table(
                columnWidths: const {
                  0: FixedColumnWidth(100),
                  1: FlexColumnWidth(),
                },
                border: TableBorder.symmetric(
                  inside: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                children: const [
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('하이라이트 구간', style: TextStyles.title),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('패턴 감지 후 최대 수익률 발생 구간'),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('승률', style: TextStyles.title),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('수익 발생 매칭 비율\n(수익 발생 매칭 횟수 / 전체 매칭 횟수)'),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('평균 수익률', style: TextStyles.title),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('모든 매칭의 평균 수익률\n(매칭 수익률의 합 / 매칭 횟수)'),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('최대 수익률', style: TextStyles.title),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('전체 매칭 중 최고 수익률'),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('최대 손실률', style: TextStyles.title),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('전체 매칭 중 최저 수익률'),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('누적 수익률', style: TextStyles.title),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('모든 매칭 수익률의 단순 합'),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('마지막 수익률', style: TextStyles.title),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('가장 최근 매칭의 수익률'),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),

              const Text(
                '수익률 계산 방식',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Text('• 매칭 수익률', style: TextStyles.title),
                  Text(
                    ' = (단순 수익률 + 구간 증가 평균 수익률) / 2',
                    style: TextStyles.content,
                  ),
                ],
              ),

              const Text.rich(
                TextSpan(
                  style: TextStyle(height: 1.6, fontSize: 13),
                  children: [
                    TextSpan(text: '  → 단순 수익률 = ', style: TextStyles.title),
                    TextSpan(
                      text: '(매도가 - 매수가) / 매수가\n',
                      style: TextStyles.content,
                    ),
                    TextSpan(
                      text: '  → 구간 증가 평균 수익률 = ',
                      style: TextStyles.title,
                    ),
                    TextSpan(
                      text: '(평균가 - 매수가) / 매수가\n',
                      style: TextStyles.content,
                    ),
                    TextSpan(text: '     ▪ 평균가 = ', style: TextStyles.title),
                    TextSpan(
                      text: '매수 시점부터 투자 기간 동안의 평균 가격',
                      style: TextStyles.content,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
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
