// lib/widgets/interest/pattern/pattern_alert_button.dart
import 'package:flutter/material.dart';
import 'package:stockapp/data/pattern_apply_api.dart';

class PatternAlertButton extends StatefulWidget {
  final int patternApplyId;
  final bool initialEnabled;
  const PatternAlertButton({
    super.key,
    required this.patternApplyId,
    this.initialEnabled = false,
  });

  @override
  State<PatternAlertButton> createState() => _PatternAlertButtonState();
}

class _PatternAlertButtonState extends State<PatternAlertButton> {
  bool _enabled = false;
  bool _busy = false;
  final _api = PatternApplyApi();

  @override
  void initState() {
    super.initState();
    _enabled = widget.initialEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: 20,
      onPressed: _busy ? null : () async {
        final prev = _enabled;

        // 낙관적 토글
        setState(() {
          _busy = true;
          _enabled = !prev;

        });

        try {
          final server = await _api.toggleNotification(widget.patternApplyId);
          if (server != null) {
            // 서버가 명확한 상태를 주면 그 값으로 보정
            setState(() => _enabled = server);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_enabled ? '알림이 켜졌습니다.' : '알림이 꺼졌습니다.')),
          );
        } catch (e) {
          // 실패 시 롤백
          setState(() => _enabled = prev);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('알림 설정 실패: $e')),
          );
        } finally {
          setState(() => _busy = false);
        }

        print('toggle notif: patternApplyId=${widget.patternApplyId}');
      },
      icon: Icon(
        _enabled ? Icons.notifications_active : Icons.notifications_none,
        color: _enabled ? const Color(0xFF000000) : null,
      ),
      tooltip: _enabled ? '알림 끄기' : '알림 켜기',
    );
  }
}

