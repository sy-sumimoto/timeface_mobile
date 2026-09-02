/// TimeFace2 APIからのエラーレスポンスを表す例外
class ApiException implements Exception {
  ApiException({required this.statusCode, required this.message, this.errors});

  final int statusCode;
  final String message;

  /// フィールド単位のバリデーションエラー(Laravelの `errors` オブジェクト)
  final Map<String, List<String>>? errors;

  String? errorFor(String field) => errors?[field]?.first;

  @override
  String toString() => message;
}
