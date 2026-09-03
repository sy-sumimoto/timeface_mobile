/// ログイン時に発行されたアクセストークンと、自動ログイン復元時に
/// 画面へ表示する従業員情報(氏名・メール)を、端末ローカルへ
/// 永続化するための保存口(セーブ/読み出し/削除)。
///
/// 実体は端末のセキュアストレージ(iOS: Keychain / Android: 暗号化SharedPreferences)だが、
/// リポジトリ層をパッケージ非依存に保つため、ここではインターフェースのみを定義する。
/// flutter_secure_storage への依存は上位(Provider層)のアダプタに閉じ込める。
abstract class TokenStorage {
  /// アクセストークンを保存する(既存の値があれば上書き)。
  Future<void> saveAccessToken(String token);

  /// 保存済みのアクセストークンを返す。未保存なら null。
  Future<String?> readAccessToken();

  /// 保存済みのアクセストークンを削除する(ログアウト時に使用)。
  Future<void> deleteAccessToken();

  /// 自動ログイン復元時に表示するための従業員情報(氏名・メール)を保存する。
  /// TimeFace2のモバイルAPIには従業員情報を単体で返す口が無いため、
  /// ログイン時にアクセストークンと対で保存しておく。
  Future<void> saveUserProfile({required String name, required String email});

  /// 保存済みの従業員情報を返す。未保存なら null。
  Future<({String name, String email})?> readUserProfile();

  /// 保存済みの従業員情報を削除する(ログアウト時に使用)。
  Future<void> deleteUserProfile();
}

/// メモリ上にだけ保持するダミー実装。
///
/// テストや、セキュアストレージを差し込まずに [EmployeeRepositories] を
/// 直接生成した場合のフォールバック。アプリ本体では
/// Provider経由でセキュアストレージ実装が注入される。
class InMemoryTokenStorage implements TokenStorage {
  String? _token;
  ({String name, String email})? _profile;

  @override
  Future<void> saveAccessToken(String token) async => _token = token;

  @override
  Future<String?> readAccessToken() async => _token;

  @override
  Future<void> deleteAccessToken() async => _token = null;

  @override
  Future<void> saveUserProfile({required String name, required String email}) async =>
      _profile = (name: name, email: email);

  @override
  Future<({String name, String email})?> readUserProfile() async => _profile;

  @override
  Future<void> deleteUserProfile() async => _profile = null;
}
