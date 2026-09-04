/// 勤怠(月別一覧)の1日分。TimeFace の `AttendanceController@monthly` が
/// `days` として返す1要素のうち、出勤がある日(`hasAttendance == true`)に対応する
/// (勤怠記録の無い休日は[AttendanceRestDay]側)。
class AttendanceRecord {
  const AttendanceRecord({
    required this.date,
    required this.workType,
    required this.statusLabel,
    required this.scheduledTime,
    required this.actualTime,
    required this.breakTime,
    this.attendanceId,
    this.workedTime = '―',
    this.overtime = '―',
    this.holidayWork = '―',
    this.midnight = '―',
    this.midnightIsEstimate = false,
    this.isUnresolvable = false,
    this.approvalLabel = '―',
    this.note = '',
    this.noteFull,
  });

  final String date;
  final String workType;
  final String statusLabel;
  final String scheduledTime;
  final String actualTime;
  final String breakTime;

  /// 勤怠明細ID(`attendanceId`)。詳細画面への遷移等に使う想定。休日は null。
  final int? attendanceId;

  /// 実働時間の合計(`workedTimeLabel`)。休憩を除いた実際の労働時間。
  final String workedTime;

  /// 残業時間(`overtimeLabel`)。[isUnresolvable] が true の日は "判定不可"。
  final String overtime;

  /// 休日出勤時間(`holidayWorkLabel`)。[isUnresolvable] が true の日は "判定不可"。
  final String holidayWork;

  /// 深夜労働時間(`midnightLabel`)。22時〜翌5時の労働。
  final String midnight;

  /// 深夜労働が概算値か(`midnightIsEstimate`)。休憩の実時刻が不明な場合 true。
  final bool midnightIsEstimate;

  /// 勤務パターン未設定等で残業・休日出勤を計算できない日か(`isUnresolvable`)。
  /// true のとき [overtime] / [holidayWork] は 0 ではなく "判定不可" が入る。
  final bool isUnresolvable;

  /// 承認状況ラベル(`approvalLabel`)。対象外・未申請は "―"。
  final String approvalLabel;

  /// 備考の要約表示(`extraInfoLabel`)。無ければ空文字。
  final String note;

  /// 備考の全文(`extraInfoFull`)。無ければ null。
  final String? noteFull;
}

/// 勤怠記録の無い休日1日分(法定休日/所定休日)。
/// TimeFace 側では法定休日=Holiday(祝日等)、所定休日=CompanyHoliday(会社独自の休日)
/// テーブルの日付を突き合わせて判定している。
class AttendanceRestDay {
  const AttendanceRestDay({required this.date, required this.label});

  final String date;
  final String label;
}

/// 月別勤怠画面1画面分の表示データ。TimeFace の
/// `GET /api/mobile/attendance/monthly?year=&month=` のレスポンスに対応する。
class AttendanceSummary {
  const AttendanceSummary({
    required this.month,
    required this.workDays,
    required this.absentDays,
    required this.lateEarlyText,
    required this.totalWorkTime,
    required this.overtimeText,
    required this.unapprovedCount,
    required this.records,
    required this.restDays,
    this.hasUnresolvableDay = false,
  });

  final DateTime month;
  final String workDays;
  final String absentDays;

  /// 欠勤日数カードの補足(例: "遅刻(0) 早退(0)")
  final String lateEarlyText;
  final String totalWorkTime;
  final String overtimeText;
  final String unapprovedCount;
  final List<AttendanceRecord> records;
  final List<AttendanceRestDay> restDays;

  /// 月内に残業・休日出勤を判定できない日があるか(`summary.hasUnresolvableDay`)。
  /// true のとき画面側で注意書きを表示する。
  final bool hasUnresolvableDay;
}
