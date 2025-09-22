// lib/widgets/common/app_date_field.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_date_picker.dart';

class AppDateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final DateFormat format;
  final DateTime? firstDate;
  final DateTime? lastDate;

  // ← const 빼기!
  AppDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    DateFormat? format,
    this.firstDate,
    this.lastDate,
  }) : format = format ?? DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          readOnly: true,
          controller: TextEditingController(text: this.format.format(value)),
          decoration: InputDecoration(
            isDense: true,
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final picked = await showThemedDatePicker(
                  context,
                  initialDate: value,
                  firstDate: firstDate,
                  lastDate: lastDate,
                );
                if (picked != null) {
                  onChanged(DateTime(picked.year, picked.month, picked.day));
                }
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}
