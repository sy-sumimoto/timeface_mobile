import 'package:flutter_test/flutter_test.dart';
import 'package:timeface_mobile/common/api/api_client.dart';
import 'package:timeface_mobile/common/api/api_exception.dart';
import 'package:timeface_mobile/employee/repositories/http_auth_repository.dart';
import 'package:timeface_mobile/employee/repositories/token_storage.dart';

/// GET /api/mobile/me の実装と、restoreSession() での利用に関する単体テスト。

Map<String, dynamic> _employee({
  String fullName = '山田太郎',
  String email = 'sumimoto-test@example.com',
  String employeeNumber = '0002',
  String companyName = 'モバイルAPI検証株式会社',
}) {
  return {
    'id': 62,
    'employeeNumber': employeeNumber,
    'lastName': '山田',
    'firstName': '太郎',
    'fullName': fullName,
    'email': email,
    'companyId': 31,
    'companyName': companyName,
  };
}

void main() {
  group('login', () {
    test('employee の付加情報(社員番号・会社名)を currentUser に取り込み、ローカルへ保存する', () async {
      final api = _FakeApiClient(
        postResponses: {
          '/login': {'token': 'tok-1', 'employee': _employee()},
        },
      );
      final storage = InMemoryTokenStorage();
      final repo = HttpAuthRepository(
        client: api,
        tokenStorage: storage,
        deviceNameResolver: () async => 'test-device',
      );

      final user = await repo.login(email: 'a@example.com', password: 'password');

      expect(user.name, '山田太郎');
      expect(user.employeeNumber, '0002');
      expect(user.companyName, 'モバイルAPI検証株式会社');
      expect(await storage.readAccessToken(), 'tok-1');
      final stored = await storage.readUserProfile();
      expect(stored?.employeeNumber, '0002');
      expect(stored?.companyName, 'モバイルAPI検証株式会社');
    });
  });

  group('me', () {
    test('GET /me を叩き、返ってきた最新の従業員情報で currentUser を更新する', () async {
      final api = _FakeApiClient(
        getResponses: {
          '/me': {'employee': _employee(fullName: '山田花子', employeeNumber: '0099')},
        },
      );
      final storage = InMemoryTokenStorage();
      final repo = HttpAuthRepository(
        client: api,
        tokenStorage: storage,
        deviceNameResolver: () async => 'test-device',
      );

      final user = await repo.me();

      expect(api.getPaths, ['/me']);
      expect(user.name, '山田花子');
      expect(user.initial, '山');
      expect(user.employeeNumber, '0099');
      // 取得した最新情報がローカルにも反映される
      expect((await storage.readUserProfile())?.name, '山田花子');
    });
  });

  group('restoreSession', () {
    test('保存済みトークンがあれば /me で最新情報を取得して返す(キャッシュより新しい値が勝つ)', () async {
      final storage = InMemoryTokenStorage();
      await storage.saveAccessToken('tok-1');
      await storage.saveUserProfile((
        name: '古い名前',
        email: 'old@example.com',
        employeeNumber: '0000',
        companyName: '旧社名',
      ));
      final api = _FakeApiClient(
        getResponses: {
          '/me': {'employee': _employee()},
        },
      );
      final repo = HttpAuthRepository(
        client: api,
        tokenStorage: storage,
        deviceNameResolver: () async => 'test-device',
      );

      final user = await repo.restoreSession();

      expect(api.getPaths, ['/me']);
      expect(user?.name, '山田太郎');
      expect(user?.companyName, 'モバイルAPI検証株式会社');
    });

    test('/me が 401 を返したらローカルの認証情報を破棄して null を返す', () async {
      final storage = InMemoryTokenStorage();
      await storage.saveAccessToken('tok-expired');
      await storage.saveUserProfile((
        name: '山田太郎',
        email: 'sumimoto-test@example.com',
        employeeNumber: '0002',
        companyName: 'モバイルAPI検証株式会社',
      ));
      final api = _FakeApiClient(
        getErrors: {'/me': ApiException(statusCode: 401, message: 'Unauthenticated.')},
      );
      final repo = HttpAuthRepository(
        client: api,
        tokenStorage: storage,
        deviceNameResolver: () async => 'test-device',
      );

      final user = await repo.restoreSession();

      expect(user, isNull);
      expect(await storage.readAccessToken(), isNull);
      expect(await storage.readUserProfile(), isNull);
    });

    test('オフライン等で /me が失敗した場合はキャッシュ済みプロフィールでログイン状態を維持する', () async {
      final storage = InMemoryTokenStorage();
      await storage.saveAccessToken('tok-1');
      await storage.saveUserProfile((
        name: '山田太郎',
        email: 'sumimoto-test@example.com',
        employeeNumber: '0002',
        companyName: 'モバイルAPI検証株式会社',
      ));
      final api = _FakeApiClient(
        getErrors: {'/me': Exception('SocketException: Failed host lookup')},
      );
      final repo = HttpAuthRepository(
        client: api,
        tokenStorage: storage,
        deviceNameResolver: () async => 'test-device',
      );

      final user = await repo.restoreSession();

      expect(user, isNotNull);
      expect(user?.name, '山田太郎');
      expect(user?.companyName, 'モバイルAPI検証株式会社');
      // トークン・プロフィールは消さない
      expect(await storage.readAccessToken(), 'tok-1');
    });

    test('保存済みトークンが無ければ /me を叩かずに null を返す', () async {
      final api = _FakeApiClient();
      final repo = HttpAuthRepository(
        client: api,
        tokenStorage: InMemoryTokenStorage(),
        deviceNameResolver: () async => 'test-device',
      );

      final user = await repo.restoreSession();

      expect(user, isNull);
      expect(api.getPaths, isEmpty);
    });
  });
}

/// ApiClient を継承し、HTTP通信の代わりに固定レスポンス/例外を返すテスト用フェイク。
class _FakeApiClient extends ApiClient {
  _FakeApiClient({
    Map<String, Map<String, dynamic>>? getResponses,
    Map<String, Map<String, dynamic>>? postResponses,
    Map<String, Object>? getErrors,
  })  : getResponses = getResponses ?? const {},
        postResponses = postResponses ?? const {},
        getErrors = getErrors ?? const {},
        super(baseUrl: 'http://test.local/api/mobile');

  final Map<String, Map<String, dynamic>> getResponses;
  final Map<String, Map<String, dynamic>> postResponses;
  final Map<String, Object> getErrors;

  final List<String> getPaths = [];
  final List<String> postPaths = [];

  @override
  Future<Map<String, dynamic>> get(String path) async {
    getPaths.add(path);
    final err = getErrors[path];
    if (err != null) throw err;
    return getResponses[path] ?? <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> post(String path, [Map<String, dynamic>? body]) async {
    postPaths.add(path);
    return postResponses[path] ?? <String, dynamic>{};
  }
}
