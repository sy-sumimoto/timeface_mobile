import '../../common/api/api_client.dart';
import '../../common/api/api_exception.dart';
import '../../common/utils/device_name.dart';
import '../models/app_user.dart';
import 'auth_repository.dart';
import 'token_storage.dart';

/// TimeFace2 (`POST /api/mobile/login` `GET /api/mobile/me` `POST /api/mobile/logout`) を叩く実装。
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

    // レスポンスの employee は EmployeeResource(lastName/firstName/fullName/employeeNumber/companyName 等)
    final employee = data['employee'] as Map<String, dynamic>;
    _applyEmployee(employee);

    // アプリ再起動後もログイン状態を復元できるよう、
    // 発行されたアクセストークンと表示用の従業員情報を端末のセキュアストレージへ保存する
    await tokenStorage.saveAccessToken(token);
    await _persistProfile();

    return _currentUser;
  }

  @override
  Future<AppUser> me() async {
    // AuthController@me: 認証済みトークンから現在の従業員情報を返す。
    final data = await client.get('/me');
    final employee = data['employee'] as Map<String, dynamic>;
    _applyEmployee(employee);

    // 取得できた最新情報でローカルのプロフィールも更新しておく
    // (オフライン起動時のフォールバック表示を最新に保つ)。
    await _persistProfile();

    return _currentUser;
  }

  @override
  Future<AppUser?> restoreSession() async {
    final String? token;
    final StoredUserProfile? profile;
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

    // まずキャッシュ済みプロフィールで即時に表示を埋める
    // (この後の /me 取得が成功すれば最新値で上書きされる)
    if (profile != null) _applyStoredProfile(profile);

    try {
      // サーバーから最新の従業員情報を取得する。ついでにトークンの有効性検証も兼ねる。
      return await me();
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        // トークンが失効・無効化されていた場合はローカルの認証情報を破棄してログイン画面へ
        client.setToken(null);
        client.setUserProfile(name: null, email: null);
        await tokenStorage.deleteAccessToken();
        await tokenStorage.deleteUserProfile();
        return null;
      }
      // 401以外(サーバーエラー等)はキャッシュ済みプロフィールのままログイン状態を維持する
      return profile != null ? _currentUser : null;
    } catch (_) {
      // オフライン等で /me を叩けない場合もキャッシュ済みプロフィールで続行する
      return profile != null ? _currentUser : null;
    }
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

  /// API の employee(EmployeeResource)から [_currentUser] を組み立てる。
  /// employee には name フィールドは無く lastName/firstName/fullName を持つ。
  void _applyEmployee(Map<String, dynamic> employee) {
    final name = employee['fullName'] as String? ?? '';
    final email = employee['email'] as String? ?? '';
    _currentUser = AppUser(
      name: name,
      email: email,
      initial: name.isNotEmpty ? name.substring(0, 1) : '?',
      employeeNumber: employee['employeeNumber'] as String?,
      companyName: employee['companyName'] as String?,
    );
    // 認証付きアクセスのログに氏名・メールを出せるよう ApiClient にも渡す
    client.setUserProfile(name: name, email: email);
  }

  /// ローカル保存済みプロフィールから [_currentUser] を組み立てる。
  void _applyStoredProfile(StoredUserProfile profile) {
    _currentUser = AppUser(
      name: profile.name,
      email: profile.email,
      initial: profile.name.isNotEmpty ? profile.name.substring(0, 1) : '?',
      employeeNumber: profile.employeeNumber,
      companyName: profile.companyName,
    );
    client.setUserProfile(name: profile.name, email: profile.email);
  }

  /// 現在の [_currentUser] を端末のセキュアストレージへ書き出す。
  Future<void> _persistProfile() {
    return tokenStorage.saveUserProfile((
      name: _currentUser.name,
      email: _currentUser.email,
      employeeNumber: _currentUser.employeeNumber,
      companyName: _currentUser.companyName,
    ));
  }
}
