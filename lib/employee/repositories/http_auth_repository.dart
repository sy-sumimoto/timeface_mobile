import '../../common/api/api_client.dart';
import '../../common/utils/device_name.dart';
import '../models/app_user.dart';
import 'auth_repository.dart';
import 'token_storage.dart';

/// TimeFace2 (`POST /api/mobile/login` `POST /api/mobile/logout`) を叩く実装。
class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository({
    required this.client,
    required this.tokenStorage,
    this.deviceNameResolver = resolveDeviceName,
  });

  final ApiClient client;

  /// ログイン時に発行されたアクセストークン等をローカルへ永続化するための保存口。
  /// 実体は端末のセキュアストレージ(flutter_secure_storage)。
  final TokenStorage tokenStorage;

  /// ログイン時にサーバーへ送る端末名(`device_name`)を解決する関数。
  /// 既定は実機の機種名等を返す [resolveDeviceName]。テストでは固定値を返す関数へ差し替える。
  final DeviceNameResolver deviceNameResolver;

  AppUser _currentUser = const AppUser(name: '', email: '', initial: '?');

  @override
  AppUser get currentUser => _currentUser;

  @override
  Future<AppUser> login({required String email, required String password}) async {
    // 端末名を取得する(取得失敗時も resolveDeviceName 側で 'mobile-app' にフォールバックする)
    final deviceName = await deviceNameResolver();

    // AuthController@login: 認証成功時にSanctumトークンと employee 情報を返す。
    // device_name はサーバー側でトークン名として保存され、端末別のログアウト管理に使われる。
    final data = await client.post('/login', {
      'email': email,
      'password': password,
      'device_name': deviceName,
    });

    final token = data['token'] as String;

    // 以降のリクエストは ApiClient がこのトークンを Authorization ヘッダに付与する
    client.setToken(token);

    // レスポンスの employee は lastName/firstName/fullName のみを持ち、name フィールドは無い
    final employee = data['employee'] as Map<String, dynamic>;
    final name = employee['fullName'] as String;
    final userEmail = employee['email'] as String;
    _currentUser = AppUser(
      name: name,
      email: userEmail,
      initial: name.isNotEmpty ? name.substring(0, 1) : '?',
    );
    // 認証付きアクセスのログに氏名・メールを出せるよう ApiClient にも渡す
    client.setUserProfile(name: name, email: userEmail);

    // アプリ再起動後もログイン状態を復元できるよう、
    // 発行されたアクセストークンと表示用の従業員情報を端末のセキュアストレージへ保存する
    await tokenStorage.saveAccessToken(token);
    await tokenStorage.saveUserProfile(name: name, email: userEmail);

    return _currentUser;
  }

  @override
  Future<AppUser?> restoreSession() async {
    final String? token;
    final ({String name, String email})? profile;
    try {
      token = await tokenStorage.readAccessToken();
      profile = await tokenStorage.readUserProfile();
    } catch (_) {
      // セキュアストレージの読み出しに失敗した場合は未ログイン扱いにフォールバックする
      return null;
    }

    // 保存済みのアクセストークンが無ければ未ログイン扱い(ログイン画面へ)
    if (token == null || token.isEmpty) return null;

    // 以降のリクエストで保存済みトークンを使う
    client.setToken(token);

    // 表示用の従業員情報を復元する(トークンとは別に保存してある)
    if (profile != null) {
      _currentUser = AppUser(
        name: profile.name,
        email: profile.email,
        initial: profile.name.isNotEmpty ? profile.name.substring(0, 1) : '?',
      );
      // 認証付きアクセスのログに氏名・メールを出せるよう ApiClient にも渡す
      client.setUserProfile(name: profile.name, email: profile.email);
    }
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    try {
      // AuthController@logout: 現在のトークンをサーバー側で無効化する
      await client.post('/logout');
    } finally {
      // サーバー側の呼び出しが失敗してもローカルのトークン・従業員情報は必ず破棄する
      client.setToken(null);
      client.setUserProfile(name: null, email: null);
      await tokenStorage.deleteAccessToken();
      await tokenStorage.deleteUserProfile();
    }
  }
}
