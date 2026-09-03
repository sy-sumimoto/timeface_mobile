import '../models/app_user.dart';

/// 従業員ログイン/ログアウトの取得口。TimeFace2側は
/// Sanctumトークン認証(`POST /login` でトークン発行、`POST /logout` で無効化)。
abstract class AuthRepository {
  /// ログイン済みユーザー情報。未ログイン時は呼び出し禁止(login後にのみ参照する)。
  AppUser get currentUser;

  Future<AppUser> login({required String email, required String password});

  /// ログイン中の従業員情報を `GET /api/mobile/me` から取得し直す。
  /// [currentUser] を最新化して返す(氏名・メール・社員番号・会社名など)。
  Future<AppUser> me();

  /// アプリ起動時に、端末に保存済みのアクセストークンからログイン状態を復元する。
  /// 復元できたら[currentUser]を埋めて[AppUser]を返す。保存済みトークンが
  /// 無ければ null を返す(呼び出し側はログイン画面へ遷移する)。
  Future<AppUser?> restoreSession();

  Future<void> logout();
}

/// モック実装。実際のAPIに差し替える際は、この実装だけを
/// HTTPクライアントを叩く実装に置き換える(呼び出し側のコードは変更不要)。
class MockAuthRepository implements AuthRepository {
  final AppUser _user = const AppUser(
    name: '中村陽子',
    email: 'nakamura@example.co.jp',
    initial: '中',
    employeeNumber: '0001',
    companyName: 'モックカンパニー株式会社',
  );

  @override
  AppUser get currentUser => _user;

  @override
  Future<AppUser> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _user;
  }

  @override
  Future<AppUser> me() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _user;
  }

  @override
  Future<AppUser?> restoreSession() async {
    // モックでは常に未ログイン扱い(毎回ログイン画面から始める)
    await Future.delayed(const Duration(milliseconds: 200));
    return null;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
