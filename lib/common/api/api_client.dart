import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_exception.dart';

/// TimeFace2 (Laravel) の従業員向けモバイルAPIを叩く薄いHTTPクライアント。
/// 認証トークン(Sanctum)の保持もここで行い、リポジトリ間で共有する。
class ApiClient {
  ApiClient({required this.baseUrl});

  /// 例: http://127.0.0.1:8123/api/employee
  /// (`php artisan serve --port=8123` で起動したTimeFace2を指す。
  /// XAMPP Apache経由にする場合は http://localhost/TimeFace2/public/api/employee に変更する)
  final String baseUrl;

  String? _token;

  void setToken(String? token) => _token = token;

  bool get isAuthenticated => _token != null;

  /// ログイン中の従業員の表示名・メール。認証付きアクセスのログ出力にだけ使う。
  /// [HttpAuthRepository] がログイン成功時・セッション復元時にセットし、
  /// ログアウト時に null へ戻す。
  String? _userName;
  String? _userEmail;

  void setUserProfile({String? name, String? email}) {
    _userName = name;
    _userEmail = email;
  }

  /// 認証トークンを付けて送るリクエストごとに、トークンと従業員情報をログへ出す。
  /// デバッグビルド限定(release/profileでは何もしない)。
  ///
  /// `debugPrint` はスロットリング(約1KB/秒)があり、画面ロード時の
  /// バースト出力だと `flutter run` コンソールで遅延・欠落することがあるため、
  /// スロットルなしで即時に stdout へ出る `print` を使う。
  /// `flutter run` のコンソールと `adb logcat -s flutter` の両方に出る。
  void _logAuthenticatedAccess(String method, String path) {
    if (!kDebugMode || _token == null) return;
    // ignore: avoid_print
    print(
      '[api.auth] $method $baseUrl$path\n'
      '  accessToken: $_token\n'
      '  name: ${_userName ?? '(未設定)'}\n'
      '  email: ${_userEmail ?? '(未設定)'}',
    );
  }

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<Map<String, dynamic>> get(String path) async {
    _logAuthenticatedAccess('GET', path);
    final response = await http.get(Uri.parse('$baseUrl$path'), headers: _headers);
    return _decode(response);
  }

  Future<Map<String, dynamic>> post(String path, [Map<String, dynamic>? body]) async {
    _logAuthenticatedAccess('POST', path);
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> put(String path, [Map<String, dynamic>? body]) async {
    _logAuthenticatedAccess('PUT', path);
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    _logAuthenticatedAccess('DELETE', path);
    final response = await http.delete(Uri.parse('$baseUrl$path'), headers: _headers);
    return _decode(response);
  }

  /// レスポンスボディをJSONにデコードし、4xx/5xxならLaravelの
  /// バリデーションエラー形式(`message` + フィールド別`errors`)を[ApiException]に変換する。
  Map<String, dynamic> _decode(http.Response response) {
    final Map<String, dynamic> data = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      final rawErrors = data['errors'];
      throw ApiException(
        statusCode: response.statusCode,
        message: data['message'] as String? ?? '通信エラーが発生しました',
        errors: rawErrors is Map
            ? rawErrors.map((key, value) => MapEntry(key as String, List<String>.from(value as List)))
            : null,
      );
    }

    return data;
  }
}
