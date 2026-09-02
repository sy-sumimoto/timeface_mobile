/// 打刻画面(PunchScreen)・マイページの「本日の状況」表示に使う状態。
///
/// TimeFace2の `GET /dashboard`(DashboardController@buildStatePayload)は
/// `is_working` / `is_on_break` の2つの真偽値しか返さないため、各ボタンの
/// 活性/非活性(can〜)はHttpPunchRepository側でこの2値から算出している。
class PunchState {
  const PunchState({
    required this.location,
    required this.employeeName,
    required this.statusLabel,
    required this.clockInTime,
    required this.canClockIn,
    required this.canClockOut,
    required this.canStartBreak,
    required this.canEndBreak,
  });

  final String location;
  final String employeeName;
  final String statusLabel;
  final String? clockInTime;
  final bool canClockIn;
  final bool canClockOut;
  final bool canStartBreak;
  final bool canEndBreak;
}
