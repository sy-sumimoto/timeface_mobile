import '../models/attendance.dart';

/// 月別勤怠一覧の取得口。実装は[HttpAttendanceRepository](実API)と
/// [MockAttendanceRepository](オフライン確認用)の2種類がある。
abstract class AttendanceRepository {
  /// 指定した月(年・月のみ使用)の勤怠サマリーを取得する。
  Future<AttendanceSummary> fetchSummary(DateTime month);
}

/// モック実装。2026年8月のみサンプルデータを返し、それ以外の月は空データを返す
/// (前月/次月ボタンの遷移自体は動作することを確認できるようにするため)。
class MockAttendanceRepository implements AttendanceRepository {
  @override
  Future<AttendanceSummary> fetchSummary(DateTime month) async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (month.year == 2026 && month.month == 8) {
      return AttendanceSummary(
        month: month,
        workDays: '6日',
        absentDays: '0日',
        lateEarlyText: '遅刻(0) 早退(0)',
        totalWorkTime: '49時間30分',
        overtimeText: 'うち残業 3時間30分',
        unapprovedCount: '0件',
        hasUnresolvableDay: true,
        records: const [
          AttendanceRecord(date: '8月3日(月)', workType: '通常勤務', statusLabel: '出勤', scheduledTime: '9:00〜18:00', actualTime: '9:00〜18:02', breakTime: '1時間00分', workedTime: '8時間00分', overtime: '0時間00分', holidayWork: '0時間00分', midnight: '0時間00分', approvalLabel: '承認済み'),
          AttendanceRecord(date: '8月4日(火)', workType: '通常勤務', statusLabel: '出勤', scheduledTime: '9:00〜18:00', actualTime: '8:58〜18:03', breakTime: '1時間00分', workedTime: '8時間00分', overtime: '0時間00分', holidayWork: '0時間00分', midnight: '0時間00分', approvalLabel: '承認済み', note: '直行', noteFull: '直行のため事業所到着は10時'),
          AttendanceRecord(date: '8月5日(水)', workType: '通常勤務', statusLabel: '出勤', scheduledTime: '9:00〜18:00', actualTime: '9:01〜18:00', breakTime: '1時間00分', workedTime: '7時間59分', overtime: '0時間00分', holidayWork: '0時間00分', midnight: '0時間00分', approvalLabel: '承認済み'),
          AttendanceRecord(date: '8月6日(木)', workType: '通常勤務', statusLabel: '出勤', scheduledTime: '9:00〜19:30', actualTime: '8:59〜19:35', breakTime: '1時間00分', workedTime: '9時間36分', overtime: '1時間36分', holidayWork: '0時間00分', midnight: '0時間00分', approvalLabel: '申請中'),
          AttendanceRecord(date: '8月7日(金)', workType: '通常勤務', statusLabel: '出勤', scheduledTime: '9:00〜19:30', actualTime: '8:57〜19:33', breakTime: '1時間00分', workedTime: '9時間36分', overtime: '判定不可', holidayWork: '判定不可', midnight: '1時間30分', midnightIsEstimate: true, isUnresolvable: true, approvalLabel: '申請中'),
        ],
        restDays: const [
          AttendanceRestDay(date: '8月8日(土)', label: '所定休日'),
          AttendanceRestDay(date: '8月9日(日)', label: '法定休日'),
        ],
      );
    }
    return AttendanceSummary(
      month: month,
      workDays: '0日',
      absentDays: '0日',
      lateEarlyText: '遅刻(0) 早退(0)',
      totalWorkTime: '0時間00分',
      overtimeText: 'うち残業 0時間00分',
      unapprovedCount: '0件',
      records: const [],
      restDays: const [],
    );
  }
}
