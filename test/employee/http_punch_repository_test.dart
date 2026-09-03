import 'package:flutter_test/flutter_test.dart';
import 'package:timeface_mobile/common/api/api_client.dart';
import 'package:timeface_mobile/common/api/api_exception.dart';
import 'package:timeface_mobile/common/utils/location.dart';
import 'package:timeface_mobile/employee/models/app_user.dart';
import 'package:timeface_mobile/employee/repositories/auth_repository.dart';
import 'package:timeface_mobile/employee/repositories/http_punch_repository.dart';

/// 単体テスト仕様書(ユーザー_打刻画面) のうち、リポジトリ層で自動化できるケースを検証する。
/// 対応ケース番号は各 test の説明に [No.x] で示す。
void main() {
  group('HttpPunchRepository.clockIn - 出勤打刻の位置情報パラメータ', () {
    test('[No.10] GPS取得成功時: /attendance/start-work に latitude/longitude を付けて送信する', () async {
      final api = _FakeApiClient();
      final repo = HttpPunchRepository(
        client: api,
        auth: _StubAuth(),
        locationResolver: () async =>
            const GeoLocation(latitude: 35.6812, longitude: 139.7671),
      );

      await repo.clockIn();

      expect(api.posts.single.path, '/attendance/start-work');
      expect(api.posts.single.body, {'latitude': 35.6812, 'longitude': 139.7671});
    });

    test('[No.11] 送信値の形式: キーは latitude/longitude、値は数値(小数)であること', () async {
      final api = _FakeApiClient();
      final repo = HttpPunchRepository(
        client: api,
        auth: _StubAuth(),
        locationResolver: () async =>
            const GeoLocation(latitude: 35.6812, longitude: 139.7671),
      );

      await repo.clockIn();

      final body = api.posts.single.body!;
      expect(body.keys.toSet(), {'latitude', 'longitude'});
      expect(body['latitude'], isA<double>());
      expect(body['longitude'], isA<double>());
      expect(body['latitude'], isNot(isA<String>()));
    });

    test('[No.12/13/14/15] 位置情報が取得できない時(権限拒否/サービスOFF/タイムアウト)はボディ無しで送信し、打刻は成功する', () async {
      final api = _FakeApiClient();
      final repo = HttpPunchRepository(
        client: api,
        auth: _StubAuth(),
        // resolveCurrentLocation は失敗時に null を返す契約
        locationResolver: () async => null,
      );

      final state = await repo.clockIn();

      expect(api.posts.single.path, '/attendance/start-work');
      expect(api.posts.single.body, isNull);
      // 位置情報が無くても打刻自体は完了する
      expect(state.statusLabel, '未出勤'); // FakeのtodayステータスがisWorking=false
    });

    test('[No.17] 既に出勤中でもサーバー応答を受けて画面状態が崩れない', () async {
      final api = _FakeApiClient(
        postMessage: '既に出勤中です',
        todayStatus: {'isWorking': true, 'isOnBreak': false},
      );
      final repo = HttpPunchRepository(
        client: api,
        auth: _StubAuth(),
        locationResolver: () async => null,
      );

      final state = await repo.clockIn();

      expect(state.statusLabel, '出勤中');
      expect(state.canClockIn, isFalse);
      expect(state.canClockOut, isTrue);
    });

    test('[No.18] 打刻後に /attendance/today を呼び直し、最新状態を返す(POST → GET の順)', () async {
      final api = _FakeApiClient(
        todayStatus: {'isWorking': true, 'isOnBreak': false},
      );
      final repo = HttpPunchRepository(
        client: api,
        auth: _StubAuth(),
        locationResolver: () async =>
            const GeoLocation(latitude: 1, longitude: 2),
      );

      final state = await repo.clockIn();

      expect(api.calls, ['POST /attendance/start-work', 'GET /attendance/today']);
      expect(state.statusLabel, '出勤中');
      expect(state.employeeName, '中村陽子'); // auth.currentUser から借用
    });

    test('[No.23] 通信/バリデーションエラー時は ApiException を送出する', () async {
      final api = _FakeApiClient(
        postError: ApiException(statusCode: 422, message: '緯度は数値で指定してください。'),
      );
      final repo = HttpPunchRepository(
        client: api,
        auth: _StubAuth(),
        locationResolver: () async =>
            const GeoLocation(latitude: 35.6812, longitude: 139.7671),
      );

      await expectLater(
        repo.clockIn(),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 422)),
      );
    });
  });

  group('HttpPunchRepository - 退勤・休憩打刻は位置情報を送らない', () {
    test('[No.20] 退勤打刻: /attendance/finish-work をボディ無しで送信し、位置情報リゾルバを呼ばない', () async {
      final api = _FakeApiClient();
      var resolverCalls = 0;
      final repo = HttpPunchRepository(
        client: api,
        auth: _StubAuth(),
        locationResolver: () async {
          resolverCalls++;
          return null;
        },
      );

      await repo.clockOut();

      expect(api.posts.single.path, '/attendance/finish-work');
      expect(api.posts.single.body, isNull);
      expect(resolverCalls, 0);
    });

    test('[No.21] 休憩開始: /attendance/start-break をボディ無しで送信する', () async {
      final api = _FakeApiClient();
      final repo = HttpPunchRepository(
        client: api,
        auth: _StubAuth(),
        locationResolver: () async => null,
      );

      await repo.startBreak();

      expect(api.posts.single.path, '/attendance/start-break');
      expect(api.posts.single.body, isNull);
    });

    test('[No.22] 休憩終了: /attendance/finish-break をボディ無しで送信する', () async {
      final api = _FakeApiClient();
      final repo = HttpPunchRepository(
        client: api,
        auth: _StubAuth(),
        locationResolver: () async => null,
      );

      await repo.endBreak();

      expect(api.posts.single.path, '/attendance/finish-break');
      expect(api.posts.single.body, isNull);
    });
  });

  group('GeoLocation', () {
    test('toJson は latitude/longitude キーの数値マップを返す', () {
      const loc = GeoLocation(latitude: 35.6812, longitude: 139.7671);
      expect(loc.toJson(), {'latitude': 35.6812, 'longitude': 139.7671});
    });
  });
}

/// ApiClient を継承し、HTTP通信を行わずに呼び出し内容を記録するテスト用フェイク。
class _FakeApiClient extends ApiClient {
  _FakeApiClient({
    Map<String, dynamic>? todayStatus,
    this.postMessage = '出勤しました',
    this.postError,
  })  : todayStatus = todayStatus ?? {'isWorking': false, 'isOnBreak': false},
        super(baseUrl: 'http://test.local/api/mobile');

  final Map<String, dynamic> todayStatus;
  final String postMessage;
  final Object? postError;

  final List<({String path, Map<String, dynamic>? body})> posts = [];
  final List<String> calls = [];

  @override
  Future<Map<String, dynamic>> post(String path, [Map<String, dynamic>? body]) async {
    posts.add((path: path, body: body));
    calls.add('POST $path');
    if (postError != null) throw postError!;
    return {'message': postMessage};
  }

  @override
  Future<Map<String, dynamic>> get(String path) async {
    calls.add('GET $path');
    return {'status': todayStatus};
  }
}

class _StubAuth implements AuthRepository {
  @override
  AppUser get currentUser =>
      const AppUser(name: '中村陽子', email: 'nakamura@example.co.jp', initial: '中');

  @override
  Future<AppUser> login({required String email, required String password}) async =>
      currentUser;

  @override
  Future<AppUser> me() async => currentUser;

  @override
  Future<AppUser?> restoreSession() async => currentUser;

  @override
  Future<void> logout() async {}
}
