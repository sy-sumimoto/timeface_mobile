import '../models/company_user.dart';

/// 企業管理者ログイン/ログアウトの取得口。TimeFace2側は`auth:company`ガードで
/// 企業アカウント自体が認証主体になる。モバイル向けAPIはまだ無いため、
/// 現状は[MockCompanyAuthRepository]のみ存在する。
abstract class CompanyAuthRepository {
  CompanyUser get currentUser;

  Future<CompanyUser> login({required String email, required String password});

  Future<void> logout();
}

/// モック実装。入力チェックのみ行い、資格情報が空でなければ常にログイン成功とする
/// (実APIが無いため失敗ケースは再現しない)。
class MockCompanyAuthRepository implements CompanyAuthRepository {
  CompanyUser _user = const CompanyUser(companyName: '株式会社サンプル', email: '', initial: '?');

  @override
  CompanyUser get currentUser => _user;

  @override
  Future<CompanyUser> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _user = CompanyUser(companyName: '株式会社サンプル', email: email, initial: 'S');
    return _user;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
