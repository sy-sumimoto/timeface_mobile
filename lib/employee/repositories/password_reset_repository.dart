/// 「パスワードをお忘れの方」フロー(メール認証コードでのパスワード再設定)の取得口。
/// HTMLモック(`employee/forgot-password/`)の3画面
/// (メールアドレス入力 → 認証コード入力 → 新しいパスワードの設定)に対応する。
///
/// TimeFace2側に対応する実APIがまだ無いため、当面
/// [MockPasswordResetRepository]のまま(実API追加時はこの実装だけ差し替える)。
abstract class PasswordResetRepository {
  /// メールアドレス宛に6桁の認証コードを送信する。
  Future<void> requestReset({required String email});

  /// 送信済みの認証コードを検証する(不一致・期限切れ等は[ApiException]で返る想定)。
  Future<void> verifyCode({required String email, required String code});

  /// 検証済みの認証コードと新しいパスワードで、パスワードを再設定する。
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  });
}

class MockPasswordResetRepository implements PasswordResetRepository {
  @override
  Future<void> requestReset({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> verifyCode({required String email, required String code}) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }
}
