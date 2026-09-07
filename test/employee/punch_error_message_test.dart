import 'package:flutter_test/flutter_test.dart';
import 'package:timeface_mobile/common/api/api_exception.dart';
import 'package:timeface_mobile/employee/utils/punch_error_message.dart';

/// 打刻エラー時に画面へ出す文言の組み立てを検証する。

void main() {
  test('errors がある場合は最初のフィールドエラーを優先する', () {
    final e = ApiException(
      statusCode: 422,
      message: 'Validation error',
      errors: {
        'latitude': ['緯度は数値で指定してください。'],
      },
    );
    expect(punchErrorMessage(e), '緯度は数値で指定してください。');
  });

  test('404 は分かりやすい定型文にする', () {
    final e = ApiException(
      statusCode: 404,
      message: 'No query results for model [App\\Models\\Attendance]',
    );
    expect(
      punchErrorMessage(e),
      '打刻対象の勤怠が見つかりませんでした。画面を更新して状態をご確認ください。',
    );
  });

  test('404 以外・errors なしはサーバーの message をそのまま出す', () {
    final e = ApiException(statusCode: 500, message: 'サーバーエラーが発生しました');
    expect(punchErrorMessage(e), 'サーバーエラーが発生しました');
  });

  test('message が空なら汎用文言にフォールバックする', () {
    final e = ApiException(statusCode: 500, message: '');
    expect(punchErrorMessage(e), 'エラーが発生しました。');
  });

  test('errors が空マップのときは message にフォールバックする', () {
    final e = ApiException(statusCode: 422, message: 'Validation error', errors: {});
    expect(punchErrorMessage(e), 'Validation error');
  });
}
