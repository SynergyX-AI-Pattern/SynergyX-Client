import 'package:flutter/material.dart';

class Recentstock extends StatefulWidget {
  const Recentstock({super.key});

  @override
  State<Recentstock> createState() => _RecentstockState();
}

class _RecentstockState extends State<Recentstock> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text('최근 조회', style: TextStyles.title),
          ),
        ],
      ),
    );
  }
}

// styles
class TextStyles {
  static const TextStyle title = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 20,
  );
}
