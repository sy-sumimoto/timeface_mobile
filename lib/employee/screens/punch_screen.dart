import 'dart:async';
import 'package:flutter/material.dart';
import '../models/punch_state.dart';
import '../../common/theme/app_colors.dart';
import '../../common/utils/date_format.dart';

/// 打刻タブ。TimeFace2のダッシュボード打刻ボタン(出勤/退勤/休憩開始/休憩終了)に
/// 対応する4つのボタンを表示する。実際のAPI呼び出しは[EmployeeShell]側の
/// `_runPunchAction` が担い、このWidgetはコールバックを呼ぶだけ。
class PunchScreen extends StatefulWidget {
  const PunchScreen({
    super.key,
    required this.punchState,
    required this.onClockIn,
    required this.onClockOut,
    required this.onBreakStart,
    required this.onBreakEnd,
  });

  final PunchState? punchState;
  final VoidCallback onClockIn;
  final VoidCallback onClockOut;
  final VoidCallback onBreakStart;
  final VoidCallback onBreakEnd;

  @override
  State<PunchScreen> createState() => _PunchScreenState();
}

class _PunchScreenState extends State<PunchScreen> {
  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // 画面上部の現在時刻表示のみを更新するタイマー(打刻データ自体は再取得しない)
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.punchState;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(state?.location ?? '—', style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
              const SizedBox(height: 8),
              Text(formatJapaneseDate(_now), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Text(formatTime(_now), style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(state?.employeeName ?? '—', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.8,
                children: [
                  _KioskButton(label: '出勤', enabled: state?.canClockIn ?? false, onTap: widget.onClockIn),
                  _KioskButton(label: '退勤', enabled: state?.canClockOut ?? false, onTap: widget.onClockOut),
                  _KioskButton(label: '休憩開始', enabled: state?.canStartBreak ?? false, onTap: widget.onBreakStart),
                  _KioskButton(label: '休憩終了', enabled: state?.canEndBreak ?? false, onTap: widget.onBreakEnd),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KioskButton extends StatelessWidget {
  const _KioskButton({required this.label, required this.enabled, this.onTap});

  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onTap : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFF1F2F4),
        disabledForegroundColor: AppColors.textSubtle,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }
}
