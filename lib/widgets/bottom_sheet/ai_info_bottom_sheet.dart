import 'package:flutter/material.dart';

class AiInfoBottomSheet extends StatelessWidget {
  const AiInfoBottomSheet({super.key});

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
                'AI 예측 주가 도움말',
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
            'AI 예측 주가란?',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'AI가 과거 주가 흐름과 패턴을 분석해, 단기적으로 예상되는 주가 범위를 예측한 지표입니다.',
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
                      '현재가',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      '실시간으로 변동 중인 현재 주식의 시장 가격입니다. 예측 범위와 비교해 투자 판단에 참고할 수 있습니다.',
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
                      '상한 예측가',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFEC221F)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'AI가 예측한 향후 일정 기간 내 도달할 수 있는 최대 주가입니다. 상승 여력을 가늠할 수 있습니다.',
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
                      '하한 예측가',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF289BF6)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'AI가 예측한 동일 기간 내 예상되는 최저 주가입니다. 하락 가능성을 확인하는 참고 지표입니다.',
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
                      '적정 매도 가격',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'AI가 분석한 데이터 상 수익 실현(매도)에 적합한 가격 구간입니다.',
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
                      '적정 매수 가격',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'AI가 분석한 데이터 상 진입(매수)에 적합한 가격 구간입니다.',
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
                      '예측 범위',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'AI 예측이 유효한 기간으로, 통상 7~14일 이내의 단기 변동 구간을 의미합니다.',
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