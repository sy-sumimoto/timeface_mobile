import 'package:flutter/material.dart';
import '../../common/theme/app_colors.dart';
import '../../common/widgets/badge.dart';

/// 勤怠一覧の出勤日1件分のカード(予定時間・実績時間・休憩時間を表示)。
class AttendanceCard extends StatelessWidget {
  const AttendanceCard({
    super.key,
    required this.date,
    required this.workType,
    required this.statusLabel,
    required this.scheduledTime,
    required this.actualTime,
    required this.breakTime,
  });

  final String date;
  final String workType;
  final String statusLabel;
  final String scheduledTime;
  final String actualTime;
  final String breakTime;

  @override
  Widget build(BuildContext context) {
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
              AppBadge(text: statusLabel, variant: AppBadgeVariant.active),
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
        ],
      ),
    );
  }
}
