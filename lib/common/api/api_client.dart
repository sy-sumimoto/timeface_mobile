import 'dart:convert';
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

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<Map<String, dynamic>> get(String path) async {
    final response = await http.get(Uri.parse('$baseUrl$path'), headers: _headers);
    return _decode(response);
  }

  Future<Map<String, dynamic>> post(String path, [Map<String, dynamic>? body]) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> put(String path, [Map<String, dynamic>? body]) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body == null ? null : jsonEncode(body),
    );
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
