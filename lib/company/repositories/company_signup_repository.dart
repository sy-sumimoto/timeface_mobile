/// 「無料で始める」フォームのメール認証(6桁コード)の取得口。
/// TimeFace2側の`Api\Company\SignupController`
/// (`POST /api/company/signup`, `/resend`, `/verify`)に対応する。
abstract class CompanySignupRepository {
  /// 「無料で始める」フォーム送信時に、入力されたメールアドレス宛に
  /// 6桁の認証コードを送信する([CompanySignUpVerifyCodeScreen]で入力させる)。
  Future<void> requestSignUpCode({
    required String lastName,
    required String firstName,
    required String email,
    required String password,
  });

  /// [CompanySignUpVerifyCodeScreen]の「再送する」から呼ぶ。
  /// 同じメールアドレス宛に認証コードを再送する。
  Future<void> resendSignUpCode({required String email});

  /// [CompanySignUpVerifyCodeScreen]の「確認する」から呼ぶ。
  /// 認証コードを検証する(不一致・期限切れ等は[ApiException]で返る)。
  Future<void> verifySignUpCode({required String email, required String code});
}
