import '../../common/api/api_client.dart';
import '../models/punch_state.dart';
import 'auth_repository.dart';
import 'punch_repository.dart';

/// TimeFace2 (`/api/mobile/attendance/*`) を叩く実装。
///
/// 実際のバックエンドは「出勤中(退勤未打刻)か」「休憩中か」の2つの真偽値しか返さないため、
/// HTMLモックにあった「本日は退勤済みで全ボタン非活性」という4状態目は表現できない
/// (退勤後にもう一度出勤ボタンを押すこと自体はバックエンド側で禁止されていない)。
///
/// 出勤/退勤/休憩の各打刻APIは `{"message": "..."}` のみを返し最新状態を含まないため、
/// 打刻後は毎回 `/attendance/today` を呼び直して状態を取得している。
/// 氏名も打刻系レスポンスには含まれないため、ログイン時に取得済みの
/// [AuthRepository.currentUser] から借用する。
class HttpPunchRepository implements PunchRepository {
  HttpPunchRepository({required this.client, required this.auth});

  final ApiClient client;
  final AuthRepository auth;

  @override
  Future<PunchState> fetchState() async {
    final data = await client.get('/attendance/today');
    return _fromStatus(data['status'] as Map<String, dynamic>);
  }

  @override
  Future<PunchState> clockIn() async {
    await client.post('/attendance/start-work');
    return fetchState();
  }

  @override
  Future<PunchState> clockOut() async {
    await client.post('/attendance/finish-work');
    return fetchState();
  }

  @override
  Future<PunchState> startBreak() async {
    await client.post('/attendance/start-break');
    return fetchState();
  }

  @override
  Future<PunchState> endBreak() async {
    await client.post('/attendance/finish-break');
    return fetchState();
  }

  /// `/attendance/today` の status(isWorking/isOnBreak)からPunchStateを組み立てる。
  PunchState _fromStatus(Map<String, dynamic> status) {
    final isWorking = status['isWorking'] as bool;
    final isOnBreak = status['isOnBreak'] as bool;

    return PunchState(
      // 事業所名を返すAPIが無いため、当面は固定文言のまま
      location: '本社オフィス',
      employeeName: auth.currentUser.name,
      statusLabel: isOnBreak ? '休憩中' : (isWorking ? '出勤中' : '未出勤'),
      clockInTime: null,
      canClockIn: !isWorking,
      canClockOut: isWorking && !isOnBreak,
      canStartBreak: isWorking && !isOnBreak,
      canEndBreak: isOnBreak,
    );
  }
}
