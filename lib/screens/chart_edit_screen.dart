import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ChartEditPage extends StatefulWidget {
  final Map<String, dynamic> patternData;
  final Future<String> Function() onSaved;

  const ChartEditPage({super.key, required this.patternData, required this.onSaved});

  @override
  State<ChartEditPage> createState() => _ChartEditPageState();
}

class _ChartEditPageState extends State<ChartEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _periodValueController;
  String _selectedUnit = '분';
  late TextEditingController _toleranceController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.patternData['title'] ?? '');
    _periodValueController = TextEditingController(text: widget.patternData['periodValue'].toString());

    final unit = widget.patternData['periodUnit'];
    if (['분', '시간', '일'].contains(unit)) {
      _selectedUnit = unit;
    } else {
      _selectedUnit = '분';
    }

    _toleranceController = TextEditingController(text: widget.patternData['tolerance'].toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _periodValueController.dispose();
    _toleranceController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    widget.patternData['title'] = _titleController.text;
    widget.patternData['periodValue'] = int.tryParse(_periodValueController.text) ?? 0;
    widget.patternData['periodUnit'] = _selectedUnit;
    widget.patternData['tolerance'] = double.tryParse(_toleranceController.text) ?? 0.0;

    final ts = widget.patternData['timestamp'];
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/pattern_$ts.json');
    await file.writeAsString(jsonEncode(widget.patternData));

    final updatedJson = await widget.onSaved();
    if (!mounted) return;
    Navigator.pop(context, updatedJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('패턴 수정')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '패턴 이름'),
            ),
            TextField(
              controller: _periodValueController,
              decoration: const InputDecoration(labelText: '기간 값'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: _selectedUnit,
              items: ['분', '시간', '일'].map((unit) {
                return DropdownMenuItem(value: unit, child: Text(unit));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedUnit = value;
                  });
                }
              },
              decoration: const InputDecoration(labelText: '기간 단위'),
            ),
            TextField(
              controller: _toleranceController,
              decoration: const InputDecoration(labelText: '오차 범위 (%)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('저장'),
            )
          ],
        ),
      ),
    );
  }
}
