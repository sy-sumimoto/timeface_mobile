import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage_provider.g.dart';

/// アプリ全体で共有するセキュアストレージのサービス層。
///
/// [FlutterSecureStorage]の生APIを直接公開せず、setValue/getValue等の
/// メソッド越しに操作させることで、キー命名の一元管理や
/// 実装差し替え(暗号化方式の変更・テスト用モック等)をしやすくする。
///
/// 各ロール(従業員/企業管理者/システム管理者)の認証状態Notifierは、
/// ここを経由してアクセストークン等を読み書きする想定。
///
/// TODO: 保存するキーの命名規則(例: `employee_token` / `company_token`)は
/// 実装時にここか呼び出し側で決める。
@riverpod
class FlutterSecureStorageController extends _$FlutterSecureStorageController {
  late final FlutterSecureStorage storage;

  @override
  void build() {
    storage = const FlutterSecureStorage();
  }

  Future<void> setValue({required String key, required String value}) async {
    await storage.write(key: key, value: value);
  }

  Future<String?> getValue({required String key}) async {
    return await storage.read(key: key);
  }

  Future<Map<String, String>> getAllValue() async {
    return await storage.readAll();
  }

  Future<void> deleteValue({required String key}) async {
    await storage.delete(key: key);
  }

  Future<void> deleteAllValue() async {
    await storage.deleteAll();
  }
}
