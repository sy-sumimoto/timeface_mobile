import 'package:flutter/material.dart';
import '../../common/theme/app_colors.dart';
import '../../common/widgets/badge.dart';

/// 勤怠一覧の出勤日1件分のカード。
/// 予定/実績/休憩に加え、残業・深夜労働・休日出勤・承認状況・備考、
/// および残業等を判定できない日([isUnresolvable])の注意書きを表示する。
class AttendanceCard extends StatelessWidget {
  const AttendanceCard({
    super.key,
    required this.date,
    required this.workType,
    required this.statusLabel,
    required this.scheduledTime,
    required this.actualTime,
    required this.breakTime,
    this.workedTime = '―',
    this.overtime = '―',
    this.holidayWork = '―',
    this.midnight = '―',
    this.midnightIsEstimate = false,
    this.isUnresolvable = false,
    this.approvalLabel = '―',
    this.note = '',
  });

  final String date;
  final String workType;
  final String statusLabel;
  final String scheduledTime;
  final String actualTime;
  final String breakTime;
  final String workedTime;
  final String overtime;
  final String holidayWork;
  final String midnight;
  final bool midnightIsEstimate;
  final bool isUnresolvable;
  final String approvalLabel;
  final String note;

  /// "―" や空文字は「値なし」とみなして表示しない。
  bool _has(String v) => v.isNotEmpty && v != '―';

  @override
  Widget build(BuildContext context) {
    final metrics = <Widget>[
      if (_has(workedTime)) _metric('実働', workedTime),
      if (_has(overtime)) _metric('残業', overtime, warn: isUnresolvable),
      if (_has(holidayWork)) _metric('休日出勤', holidayWork, warn: isUnresolvable),
      if (_has(midnight))
        _metric('深夜', midnightIsEstimate ? '$midnight（概算）' : midnight),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textBase),
                    children: [
                      TextSpan(text: date),
                      TextSpan(
                        text: '  $workType',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSubtle),
                      ),
                    ],
                  ),
                ),
              ),
              Wrap(
                spacing: 6,
                children: [
                  AppBadge(text: statusLabel, variant: AppBadgeVariant.active),
                  if (_has(approvalLabel))
                    AppBadge(text: approvalLabel, variant: AppBadgeVariant.neutral),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(scheduledTime, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              Text('実勤務 $actualTime', style: const TextStyle(fontSize: 12, color: AppColors.textSubtle)),
              Text('休憩 $breakTime', style: const TextStyle(fontSize: 12, color: AppColors.textSubtle)),
            ],
          ),
          if (metrics.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 6, children: metrics),
          ],
          if (isUnresolvable) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.info_outline_rounded, size: 14, color: AppColors.badgeWarningText),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '勤務パターン未設定のため、残業・休日出勤を判定できません',
                    style: TextStyle(fontSize: 11.5, color: AppColors.badgeWarningText),
                  ),
                ),
              ],
            ),
          ],
          if (_has(note)) ...[
            const SizedBox(height: 6),
            Text(
              '備考: $note',
              style: const TextStyle(fontSize: 11.5, color: AppColors.textSubtle),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metric(String label, String value, {bool warn = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.badgeNeutralBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
          children: [
            TextSpan(text: '$label '),
            TextSpan(
              text: value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: warn ? AppColors.badgeWarningText : AppColors.textBase,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
