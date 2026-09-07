import '../../common/api/api_client.dart';
import '../../common/utils/location.dart';
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
  HttpPunchRepository({
    required this.client,
    required this.auth,
    this.locationResolver = resolveCurrentLocation,
  });

  final ApiClient client;
  final AuthRepository auth;

  /// 出勤打刻時にサーバーへ送る現在地(緯度・経度)を解決する関数。
  /// 既定は実機のGPS等から取得する [resolveCurrentLocation]。テストでは固定値を返す関数へ差し替える。
  final LocationResolver locationResolver;

  @override
  Future<PunchState> fetchState() async {
    final data = await client.get('/attendance/today');
    return _fromStatus(data['status'] as Map<String, dynamic>);
  }

  @override
  Future<PunchResult> clockIn() async {
    // 現在地を取得して緯度・経度を打刻パラメータに載せる。
    // 位置情報が取れない場合は location が null になり、従来どおりボディ無しで送る。
    final location = await locationResolver();
    final data = await client.post('/attendance/start-work', location?.toJson());
    return (state: await fetchState(), message: _messageOf(data));
  }

  @override
  Future<PunchResult> clockOut() async {
    final data = await client.post('/attendance/finish-work');
    return (state: await fetchState(), message: _messageOf(data));
  }

  @override
  Future<PunchResult> startBreak() async {
    final data = await client.post('/attendance/start-break');
    return (state: await fetchState(), message: _messageOf(data));
  }

  @override
  Future<PunchResult> endBreak() async {
    final data = await client.post('/attendance/finish-break');
    return (state: await fetchState(), message: _messageOf(data));
  }

  /// 打刻APIのレスポンス `{"message": "..."}` からメッセージを取り出す。
  /// バックエンドは "既に出勤中です" / "出勤から時間が経ちすぎている..." 等の業務エラーも
  /// HTTP 200 のまま `message` で返すため、成功・失敗を問わずそのまま拾う。
  String _messageOf(Map<String, dynamic> data) => data['message'] as String? ?? '';

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
