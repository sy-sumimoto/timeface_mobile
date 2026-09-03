import '../../common/api/api_client.dart';
import '../models/company_user.dart';
import 'company_auth_repository.dart';

/// TimeFace2 (`/api/company/login` `/api/company/logout`) を叩く実装。
///
/// 企業管理者は`employees`テーブルの is_admin=true なレコードで認証される
/// (企業アカウント自体がログイン主体ではない)。詳細は
/// `Api\Company\AuthController`(TimeFace2側)を参照。
class HttpCompanyAuthRepository implements CompanyAuthRepository {
  HttpCompanyAuthRepository({required this.client});

  final ApiClient client;

  CompanyUser _currentUser = const CompanyUser(companyName: '', email: '', initial: '?');

  @override
  CompanyUser get currentUser => _currentUser;

  @override
  Future<CompanyUser> login({required String email, required String password}) async {
    // AuthController@login: 認証成功時にSanctumトークンと employee 情報を返す
    final data = await client.post('/login', {
      'email': email,
      'password': password,
    });

    // 以降のリクエストは ApiClient がこのトークンを Authorization ヘッダに付与する
    client.setToken(data['token'] as String);

    final employee = data['employee'] as Map<String, dynamic>;
    final name = employee['name'] as String;
    final userEmail = employee['email'] as String;
    _currentUser = CompanyUser(
      companyName: employee['company_name'] as String,
      email: userEmail,
      initial: name.isNotEmpty ? name.substring(0, 1) : '?',
    );
    // 認証付きアクセスのログに氏名・メールを出せるよう ApiClient にも渡す
    client.setUserProfile(name: name, email: userEmail);
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
      client.setUserProfile(name: null, email: null);
    }
  }
}
