import '../../common/providers/secure_storage_provider.dart';
import '../repositories/token_storage.dart';

/// [TokenStorage] を端末のセキュアストレージ([FlutterSecureStorageController])で
/// 実装するアダプタ。
///
/// リポジトリ層(`lib/employee/repositories/`)を flutter_secure_storage や
/// Riverpod に依存させないため、パッケージへの依存はこのProvider層側に閉じ込める。
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage(this._storage);

  final FlutterSecureStorageController _storage;

  /// 従業員のアクセストークン/表示用情報を保存するキー。
  /// 企業管理者(company_*)等と混ざらないよう役割ごとに分ける。
  static const String _accessTokenKey = 'employee_access_token';
  static const String _userNameKey = 'employee_user_name';
  static const String _userEmailKey = 'employee_user_email';

  @override
  Future<void> saveAccessToken(String token) {
    return _storage.setValue(key: _accessTokenKey, value: token);
  }

  @override
  Future<String?> readAccessToken() {
    return _storage.getValue(key: _accessTokenKey);
  }

  @override
  Future<void> deleteAccessToken() {
    return _storage.deleteValue(key: _accessTokenKey);
  }

  @override
  Future<void> saveUserProfile({required String name, required String email}) async {
    await _storage.setValue(key: _userNameKey, value: name);
    await _storage.setValue(key: _userEmailKey, value: email);
  }

  @override
  Future<({String name, String email})?> readUserProfile() async {
    final name = await _storage.getValue(key: _userNameKey);
    final email = await _storage.getValue(key: _userEmailKey);
    if (name == null || email == null) return null;
    return (name: name, email: email);
  }

  @override
  Future<void> deleteUserProfile() async {
    await _storage.deleteValue(key: _userNameKey);
    await _storage.deleteValue(key: _userEmailKey);
  }
}
