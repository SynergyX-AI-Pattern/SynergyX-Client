import 'dart:io';
import 'package:flutter/material.dart';

// ─ 이미지 카드 위젯
class ImageCard extends StatelessWidget {
  final File? file;

  const ImageCard({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    if (file != null) {
      return Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            file!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 1,
      child: Container(
        height: 200,
        alignment: Alignment.center,
        child: const Text(
          '이미지를 선택해주세요.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  }
}
