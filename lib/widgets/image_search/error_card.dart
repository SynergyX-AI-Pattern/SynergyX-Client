import 'package:flutter/material.dart';

// ─ 에러 카드 위젯
class ErrorCard extends StatelessWidget {
  final String error;
  final VoidCallback? onRetryCamera;
  final VoidCallback? onRetryGallery;
  final bool loading;
  final ButtonStyle buttonStyle;

  const ErrorCard({
    super.key,
    required this.error,
    this.onRetryCamera,
    this.onRetryGallery,
    this.loading = false,
    required this.buttonStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  error,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (error.contains('용량'))
            const Text('• 이미지 크기를 줄이거나 스크린샷 대신 원본 이미지를 사용해 보세요.'),
          if (error.contains('형식'))
            const Text('• 파일 확장자가 jpg/jpeg/png인지 확인하세요.'),
          if (error.contains('찾지 못했어요')) const Text('• 선명하게 다시 촬영해 보세요.'),
          if (error.contains('찾지 못했어요')) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: buttonStyle,
                    onPressed: loading ? null : onRetryCamera,
                    icon: const Icon(
                      Icons.photo_camera,
                      color: Color(0xFFF5F5F5),
                    ),
                    label: const Text(
                      '다시 찍기',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: buttonStyle,
                    onPressed: loading ? null : onRetryGallery,
                    icon: const Icon(
                      Icons.photo_library,
                      color: Color(0xFFF5F5F5),
                    ),
                    label: const Text(
                      '다른 이미지',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
