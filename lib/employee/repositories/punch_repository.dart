import '../models/punch_state.dart';

/// 打刻(出勤・退勤・休憩開始/終了)の取得口。TimeFace2側の
/// `/api/mobile/attendance/*` エンドポイント(Api\Mobile\AttendanceController)にそれぞれ対応する。
abstract class PunchRepository {
  /// 本日の打刻状況を取得する(画面初期表示・タブ切り替え時に呼ぶ)。
  Future<PunchState> fetchState();

  /// 出勤打刻。
  Future<PunchState> clockIn();

  /// 退勤打刻。
  Future<PunchState> clockOut();

  /// 休憩開始打刻。
  Future<PunchState> startBreak();

  /// 休憩終了(復帰)打刻。
  Future<PunchState> endBreak();
}

enum _PunchPhase { notStarted, working, onBreak, finished }

/// モック実装。実データはアプリ内メモリのみで保持し、画面を離れても
/// (同一セッション内なら)状態を保つ。実APIに差し替える際はこのクラスだけを置き換える。
class MockPunchRepository implements PunchRepository {
  _PunchPhase _phase = _PunchPhase.working;
  final String _clockInTime = '09:02';

  @override
  Future<PunchState> fetchState() async => _stateFor(_phase);

  @override
  Future<PunchState> clockIn() => _transition(_PunchPhase.working);

  @override
  Future<PunchState> clockOut() => _transition(_PunchPhase.finished);

  @override
  Future<PunchState> startBreak() => _transition(_PunchPhase.onBreak);

  @override
  Future<PunchState> endBreak() => _transition(_PunchPhase.working);

  Future<PunchState> _transition(_PunchPhase next) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _phase = next;
    return _stateFor(_phase);
  }

  PunchState _stateFor(_PunchPhase phase) {
    const location = '本社オフィス';
    const employeeName = '中村陽子';
    switch (phase) {
      case _PunchPhase.notStarted:
        return const PunchState(
          location: location,
          employeeName: employeeName,
          statusLabel: '未出勤',
          clockInTime: null,
          canClockIn: true,
          canClockOut: false,
          canStartBreak: false,
          canEndBreak: false,
        );
      case _PunchPhase.working:
        return PunchState(
          location: location,
          employeeName: employeeName,
          statusLabel: '出勤中',
          clockInTime: _clockInTime,
          canClockIn: false,
          canClockOut: true,
          canStartBreak: true,
          canEndBreak: false,
        );
      case _PunchPhase.onBreak:
        return PunchState(
          location: location,
          employeeName: employeeName,
          statusLabel: '休憩中',
          clockInTime: _clockInTime,
          canClockIn: false,
          canClockOut: false,
          canStartBreak: false,
          canEndBreak: true,
        );
      case _PunchPhase.finished:
        return PunchState(
          location: location,
          employeeName: employeeName,
          statusLabel: '退勤済み',
          clockInTime: _clockInTime,
          canClockIn: false,
          canClockOut: false,
          canStartBreak: false,
          canEndBreak: false,
        );
    }
  }
}
