/// 勤怠(月別一覧)の1日分。TimeFace2の `AttendanceController@index` が
/// `records` として返す1要素に対応する(出勤日のみ。休日は[AttendanceRestDay]側)。
class AttendanceRecord {
  const AttendanceRecord({
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
}

/// 勤怠記録の無い休日1日分(法定休日/所定休日)。
/// TimeFace2側では法定休日=Holiday(祝日等)、所定休日=CompanyHoliday(会社独自の休日)
/// テーブルの日付を突き合わせて判定している(`rest_days`)。
class AttendanceRestDay {
  const AttendanceRestDay({required this.date, required this.label});

  final String date;
  final String label;
}

/// 月別勤怠画面1画面分の表示データ。TimeFace2の
/// `GET /attendances?year=&month=`(AttendanceController@index)のレスポンスに対応する。
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
}
