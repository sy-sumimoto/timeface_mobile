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
  static const String _userEmployeeNumberKey = 'employee_user_employee_number';
  static const String _userCompanyNameKey = 'employee_user_company_name';

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
  Future<void> saveUserProfile(StoredUserProfile profile) async {
    await _storage.setValue(key: _userNameKey, value: profile.name);
    await _storage.setValue(key: _userEmailKey, value: profile.email);
    await _writeOptional(_userEmployeeNumberKey, profile.employeeNumber);
    await _writeOptional(_userCompanyNameKey, profile.companyName);
  }

  @override
  Future<StoredUserProfile?> readUserProfile() async {
    final name = await _storage.getValue(key: _userNameKey);
    final email = await _storage.getValue(key: _userEmailKey);
    if (name == null || email == null) return null;
    return (
      name: name,
      email: email,
      employeeNumber: await _storage.getValue(key: _userEmployeeNumberKey),
      companyName: await _storage.getValue(key: _userCompanyNameKey),
    );
  }

  @override
  Future<void> deleteUserProfile() async {
    await _storage.deleteValue(key: _userNameKey);
    await _storage.deleteValue(key: _userEmailKey);
    await _storage.deleteValue(key: _userEmployeeNumberKey);
    await _storage.deleteValue(key: _userCompanyNameKey);
  }

  /// null のときはキー自体を消しておく(古い値が残らないように)。
  Future<void> _writeOptional(String key, String? value) {
    if (value == null) return _storage.deleteValue(key: key);
    return _storage.setValue(key: key, value: value);
  }
}
