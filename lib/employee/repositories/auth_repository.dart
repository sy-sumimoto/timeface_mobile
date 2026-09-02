import '../models/app_user.dart';

/// 従業員ログイン/ログアウトの取得口。TimeFace2側は
/// Sanctumトークン認証(`POST /login` でトークン発行、`POST /logout` で無効化)。
abstract class AuthRepository {
  /// ログイン済みユーザー情報。未ログイン時は呼び出し禁止(login後にのみ参照する)。
  AppUser get currentUser;

  Future<AppUser> login({required String email, required String password});

  Future<void> logout();
}

/// モック実装。実際のAPIに差し替える際は、この実装だけを
/// HTTPクライアントを叩く実装に置き換える(呼び出し側のコードは変更不要)。
class MockAuthRepository implements AuthRepository {
  final AppUser _user = const AppUser(
    name: '中村陽子',
    email: 'nakamura@example.co.jp',
    initial: '中',
  );

  @override
  AppUser get currentUser => _user;

  @override
  Future<AppUser> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _user;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
