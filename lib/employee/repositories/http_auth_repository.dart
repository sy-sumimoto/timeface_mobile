import '../../common/api/api_client.dart';
import '../models/app_user.dart';
import 'auth_repository.dart';

/// TimeFace2 (`POST /api/mobile/login` `POST /api/mobile/logout`) を叩く実装。
class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository({required this.client});

  final ApiClient client;

  AppUser _currentUser = const AppUser(name: '', email: '', initial: '?');

  @override
  AppUser get currentUser => _currentUser;

  @override
  Future<AppUser> login({required String email, required String password}) async {
    // AuthController@login: 認証成功時にSanctumトークンと employee 情報を返す
    final data = await client.post('/login', {
      'email': email,
      'password': password,
    });

    // 以降のリクエストは ApiClient がこのトークンを Authorization ヘッダに付与する
    client.setToken(data['token'] as String);

    // レスポンスの employee は lastName/firstName/fullName のみを持ち、name フィールドは無い
    final employee = data['employee'] as Map<String, dynamic>;
    final name = employee['fullName'] as String;
    _currentUser = AppUser(
      name: name,
      email: employee['email'] as String,
      initial: name.isNotEmpty ? name.substring(0, 1) : '?',
    );
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    try {
      // AuthController@logout: 現在のトークンをサーバー側で無効化する
      await client.post('/logout');
    } finally {
      // サーバー側の呼び出しが失敗してもローカルのトークンは必ず破棄する
      client.setToken(null);
    }
  }
}
