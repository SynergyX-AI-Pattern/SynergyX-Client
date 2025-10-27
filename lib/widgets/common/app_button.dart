import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool block; // 가로 꽉 차게
  final IconData? leadingIcon;

  // 선택적으로 스타일 커스터마이즈 (필요할 때만)
  final Color? bgColor;
  final Color? fgColor;
  final Color? shadowColor;
  final double? elevation;
  final BorderSide? side;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final double minHeight;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.block = false,
    this.leadingIcon,
    this.bgColor,
    this.fgColor,
    this.shadowColor,
    this.elevation,
    this.side,
    this.radius = 8,
    this.padding,
    this.textStyle,
    this.minHeight = 42,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
      width: 18, height: 18,
      child: CircularProgressIndicator(strokeWidth: 2),
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(label),
      ],
    );

    return SizedBox(
      width: block ? double.infinity : null,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor ?? Colors.black,
          foregroundColor: fgColor ?? Colors.white,
          shadowColor: shadowColor,
          elevation: elevation ?? 0,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          textStyle: (textStyle ??
              const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ))
              .copyWith(fontFamily: 'Pretendard'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          side: side,
          minimumSize: Size(block ? double.infinity : 0, minHeight), // 여기서 높이만 조정
          alignment: Alignment.center, // 세로 중앙 정렬 확실히
        ),
        child: child,
      ),
    );
  }
}
