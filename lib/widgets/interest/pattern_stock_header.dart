import 'package:flutter/material.dart';

class StockHeader extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const StockHeader({super.key, required this.name, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    Widget avatar;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = ClipOval(
        child: Image.network(
          imageUrl!,
          width: 40, height: 40, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(name),
          loadingBuilder: (c, child, p) =>
          p == null ? child : _loading(),
        ),
      );
    } else {
      avatar = _fallback(name);  // 빈/널이면 플레이스홀더
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          avatar,
          const SizedBox(width: 10),
          Expanded(child: Text(name,
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  Widget _fallback(String name) => CircleAvatar(
    radius: 20,
    backgroundColor: const Color(0xFFF1F3F5),
    child: Text(
      name.isNotEmpty ? name.characters.first : '?',
      style: const TextStyle(fontWeight: FontWeight.w700),
    ),
  );

  Widget _loading() => const SizedBox(
    width: 40, height: 40,
    child: Center(child: SizedBox(
        width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
  );
}
