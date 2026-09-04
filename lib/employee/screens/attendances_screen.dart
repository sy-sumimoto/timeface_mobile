import 'package:flutter/material.dart';

import '../models/attendance.dart';
import '../repositories/attendance_repository.dart';
import '../../common/theme/app_colors.dart';
import '../../common/utils/date_format.dart';
import '../widgets/attendance_card.dart';
import '../widgets/attendance_rest_row.dart';
import '../../common/widgets/kpi_card.dart';

/// 勤怠(月別一覧)タブ。前月/次月ボタンで表示月を切り替え、
/// TimeFace2の `GET /attendances?year=&month=` を都度呼び直す。
class AttendancesScreen extends StatefulWidget {
  const AttendancesScreen({
    super.key,
    required this.repository,
    required this.isActive,
  });

  final AttendanceRepository repository;

  /// このタブが現在選択され画面に表示されているか。
  /// EmployeeShellはIndexedStackで全タブを起動時に一括生成するため、
  /// initStateでの取得だけでは打刻タブでの出退勤操作が反映されない。
  /// falseからtrueに変わった(=このタブが選び直された)タイミングで
  /// didUpdateWidgetから再取得し、他タブでの操作結果を反映する。
  final bool isActive;

  @override
  State<AttendancesScreen> createState() => _AttendancesScreenState();
}

class _AttendancesScreenState extends State<AttendancesScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  AttendanceSummary? _summary;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant AttendancesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _load();
    }
  }

  Future<void> _load() async {
    final summary = await widget.repository.fetchSummary(_month);
    if (!mounted) return;
    setState(() => _summary = summary);
  }

  /// 前月(-1)・次月(+1)へ移動し、その月の勤怠データを取得し直す。
  /// _summaryを一旦nullに戻してローディング表示を挟む。
  void _changeMonth(int diff) {
    setState(() {
      _month = DateTime(_month.year, _month.month + diff);
      _summary = null;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: () => _changeMonth(-1),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    '‹ 前月',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF374151)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      formatJapaneseMonth(_month),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _changeMonth(1),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    '次月 ›',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF374151)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (summary == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
              childAspectRatio: 0.63,
              children: [
                KpiCard(
                  compact: true,
                  label: '出勤日数',
                  value: summary.workDays,
                  delta: '',
                  icon: Icons.calendar_month_rounded,
                  iconColor: KpiIconColor.blue,
                ),
                KpiCard(
                  compact: true,
                  label: '欠勤日数',
                  value: summary.absentDays,
                  delta: summary.lateEarlyText,
                  icon: Icons.warning_amber_rounded,
                  iconColor: KpiIconColor.orange,
                ),
                KpiCard(
                  compact: true,
                  label: '総労働時間',
                  value: summary.totalWorkTime,
                  delta: summary.overtimeText,
                  icon: Icons.schedule_rounded,
                  iconColor: KpiIconColor.green,
                ),
                KpiCard(
                  compact: true,
                  label: '未承認',
                  value: summary.unapprovedCount,
                  delta: '遅刻・早退・欠勤のうち未承認',
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: KpiIconColor.purple,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '日別勤怠',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (summary.hasUnresolvableDay) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.badgeWarningBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 15, color: AppColors.badgeWarningText),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '勤務パターン未設定などにより、残業・休日出勤を判定できない日があります。',
                        style: TextStyle(fontSize: 12, color: AppColors.badgeWarningText),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (summary.records.isEmpty && summary.restDays.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'この月の勤怠データはありません',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textSubtle,
                    ),
                  ),
                ),
              )
            else ...[
              for (final record in summary.records) ...[
                AttendanceCard(
                  date: record.date,
                  workType: record.workType,
                  statusLabel: record.statusLabel,
                  scheduledTime: record.scheduledTime,
                  actualTime: record.actualTime,
                  breakTime: record.breakTime,
                  workedTime: record.workedTime,
                  overtime: record.overtime,
                  holidayWork: record.holidayWork,
                  midnight: record.midnight,
                  midnightIsEstimate: record.midnightIsEstimate,
                  isUnresolvable: record.isUnresolvable,
                  approvalLabel: record.approvalLabel,
                  note: record.note,
                ),
                const SizedBox(height: 10),
              ],
              for (final rest in summary.restDays)
                AttendanceRestRow(date: rest.date, label: rest.label),
            ],
          ],
        ],
      ),
    );
  }
}
