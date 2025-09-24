import 'package:flutter/material.dart';
import '../../models/image_search_result.dart';
import '../../models/StockItemModel.dart';
import '../../screens/stock_detail_screen.dart';

// ─ 결과 카드 위젯
class ResultCard extends StatelessWidget {
  final ImageSearchData result;
  final ButtonStyle buttonStyle;
  final bool loading;
  final VoidCallback? onRetryCamera;
  final VoidCallback? onRetryGallery;

  const ResultCard({
    super.key,
    required this.result,
    required this.buttonStyle,
    this.loading = false,
    this.onRetryCamera,
    this.onRetryGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // ─ 강조 스타일
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF1A237E), width: 1.2),
      ),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ─ 헤더 라벨
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'AI 분석 결과',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ─ 이미지 (LISTED일 때만)
            if (result.status == 'LISTED' && result.imageUrl != null) ...[
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.grey.shade100,
                backgroundImage: NetworkImage(result.imageUrl!),
              ),
              const SizedBox(height: 12),
            ],

            // ─ 이름
            Text(
              result.status == 'UNKNOWN'
                  ? '이미지로 종목을 찾지 못했어요.'
                  : (result.name ?? '종목명 미확인'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 8),

            // ─ 상태 안내
            _buildStatusText(context),

            const SizedBox(height: 16),

            // ─ 상세 버튼 (LISTED만)
            if (result.status == 'LISTED' && result.id != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: buttonStyle.copyWith(
                    backgroundColor: MaterialStateProperty.all(
                      const Color(0xFF1A237E),
                    ),
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  icon: const Icon(Icons.open_in_new, color: Color(0xFFF5F5F5)),
                  label: const Text(
                    '종목 상세 보기',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onPressed: () {
                    final item = StockItem(
                      stockId: result.id!,
                      name: result.name ?? '',
                      imageUrl: result.imageUrl ?? '',
                      price: 0,
                      changeRate: 0,
                      rank: 0,
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(stock: item),
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

  // ─ 상태 텍스트
  Widget _buildStatusText(BuildContext context) {
    String? guide;
    switch (result.status) {
      case 'LISTED':
        guide = 'KOSPI 100에 포함된 종목이에요.';
        break;
      case 'LISTED_OUTSIDE':
        guide = '국내외 증시에 상장된 기업이에요.';
        break;
      case 'UNLISTED':
        guide = '비상장 기업이에요.';
        break;
      case 'UNKNOWN':
        guide = null; // 안내 문구 미표시
        break;
    }

    return Column(
      children: [
        if (guide != null)
          Text(
            guide,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4A4A4A), // 다크 그레이
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        if (result.status == 'UNKNOWN')
          const Text(
            '• 선명하게 다시 촬영해 보세요.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF4A4A4A),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
