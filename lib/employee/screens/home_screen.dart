import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../models/attendance.dart';
import '../models/paid_holiday.dart';
import '../models/punch_state.dart';
import '../repositories/employee_repositories.dart';
import '../../common/theme/app_colors.dart';
import '../../common/utils/date_format.dart';
import '../../common/widgets/accent_button.dart';
import '../widgets/announcement_card.dart';
import '../../common/widgets/badge.dart';
import '../../common/widgets/kpi_card.dart';

/// マイページ(ホームタブ)。打刻状況・当月KPI・最新のお知らせをまとめて表示する。
/// 表示データは4つのリポジトリ(勤怠・有給休暇・お知らせ・打刻)から並行ではなく
/// 順に取得している([_load]参照)。
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repositories,
    required this.punchState,
    required this.onOpenPunch,
    required this.onOpenAttendances,
    required this.onOpenPaidHolidays,
    required this.onOpenAnnouncements,
  });

  final EmployeeRepositories repositories;
  final PunchState? punchState;
  final VoidCallback onOpenPunch;
  final VoidCallback onOpenAttendances;
  final VoidCallback onOpenPaidHolidays;
  final VoidCallback onOpenAnnouncements;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DateTime _today = DateTime.now();

  AttendanceSummary? _attendanceSummary;
  PaidHolidaySummary? _paidHolidaySummary;
  bool _hasRejectedRequest = false;
  Announcement? _latestAnnouncement;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final attendance = await widget.repositories.attendance.fetchSummary(
      DateTime(_today.year, _today.month),
    );
    final paidHolidaySummary = await widget.repositories.paidHoliday
        .fetchSummary();
    final paidHolidayRequests =
        await widget.repositories.paidHoliday.fetchRequests();
    final announcements = await widget.repositories.announcement.fetchAll();
    if (!mounted) return;
    setState(() {
      _attendanceSummary = attendance;
      _paidHolidaySummary = paidHolidaySummary;
      // 差し戻し(request_status=4)は申請中(pending)側に含まれる
      _hasRejectedRequest = paidHolidayRequests.pending.any(
        (e) => e.status == PaidHolidayStatus.rejected,
      );
      _latestAnnouncement = announcements.isNotEmpty
          ? announcements.first
          : null;
    });
  }

  /// 打刻状態(出勤中/休憩中/それ以外)に応じたバッジの色を選ぶ。
  AppBadgeVariant get _punchBadgeVariant {
    switch (widget.punchState?.statusLabel) {
      case '出勤中':
        return AppBadgeVariant.active;
      case '休憩中':
        return AppBadgeVariant.warning;
      default:
        return AppBadgeVariant.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendance = _attendanceSummary;
    final paidHoliday = _paidHolidaySummary;
    final punchState = widget.punchState;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${formatJapaneseDate(_today)} 時点の状況です',
            style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
          if (_hasRejectedRequest) ...[
            const SizedBox(height: 16),
            InkWell(
              onTap: widget.onOpenPaidHolidays,
              borderRadius: BorderRadius.circular(9),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.badgeWarningBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: AppColors.badgeWarningText,
                    ),
                    children: [
                      TextSpan(text: '有給休暇の申請が差し戻されています。内容を確認して再提出してください。 '),
                      TextSpan(
                        text: '有給休暇へ',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBadge(
                      text: punchState?.statusLabel ?? '確認中',
                      variant: _punchBadgeVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      punchState?.clockInTime != null
                          ? '本日 ${punchState!.clockInTime} 出勤'
                          : '本日の打刻はまだありません',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                AccentButton(label: '打刻画面を開く', onPressed: widget.onOpenPunch),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.05,
            children: [
              KpiCard(
                compact: true,
                label: '今月の出勤日数',
                value: attendance?.workDays ?? '—',
                delta: attendance != null ? '欠勤 ${attendance.absentDays}' : '',
                icon: Icons.calendar_month_rounded,
                iconColor: KpiIconColor.blue,
                onTap: widget.onOpenAttendances,
              ),
              KpiCard(
                compact: true,
                label: '今月の総労働時間',
                value: attendance?.totalWorkTime ?? '—',
                delta: attendance?.overtimeText ?? '',
                icon: Icons.access_time_rounded,
                iconColor: KpiIconColor.orange,
                onTap: widget.onOpenAttendances,
              ),
              KpiCard(
                compact: true,
                label: '有給休暇残日数',
                value: paidHoliday?.remainingDays ?? '—',
                delta: paidHoliday != null
                    ? '次回付与: ${paidHoliday.nextGrantDate}'
                    : '',
                icon: Icons.wb_sunny_rounded,
                iconColor: KpiIconColor.green,
                onTap: widget.onOpenPaidHolidays,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'お知らせ',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: widget.onOpenAnnouncements,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: const Text(
                  'すべて表示',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_latestAnnouncement != null)
            AnnouncementCard(
              title: _latestAnnouncement!.title,
              date: _latestAnnouncement!.date,
              isNew: _latestAnnouncement!.isNew,
              onTap: widget.onOpenAnnouncements,
            ),
        ],
      ),
    );
  }
}
