/// 端末ローカルに保存する従業員の表示用プロフィール(氏名・メール・社員番号・会社名)。
/// オフライン起動時など `GET /me` が叩けない場合のフォールバック表示に使う。
typedef StoredUserProfile = ({
  String name,
  String email,
  String? employeeNumber,
  String? companyName,
});

/// ログイン時に発行されたアクセストークンと、自動ログイン復元時に
/// 画面へ表示する従業員情報を、端末ローカルへ永続化するための保存口
/// (セーブ/読み出し/削除)。
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

  /// 自動ログイン復元時に表示するための従業員情報を保存する。
  /// ログイン時と `GET /me` 成功時に、アクセストークンと対で更新する。
  Future<void> saveUserProfile(StoredUserProfile profile);

  /// 保存済みの従業員情報を返す。未保存なら null。
  Future<StoredUserProfile?> readUserProfile();

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
  StoredUserProfile? _profile;

  @override
  Future<void> saveAccessToken(String token) async => _token = token;

  @override
  Future<String?> readAccessToken() async => _token;

  @override
  Future<void> deleteAccessToken() async => _token = null;

  @override
  Future<void> saveUserProfile(StoredUserProfile profile) async => _profile = profile;

  @override
  Future<StoredUserProfile?> readUserProfile() async => _profile;

  @override
  Future<void> deleteUserProfile() async => _profile = null;
}
