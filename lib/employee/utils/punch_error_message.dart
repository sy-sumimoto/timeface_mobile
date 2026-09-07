import '../../common/api/api_exception.dart';

/// 打刻APIで [ApiException] が返ったときに画面へ出す文言を組み立てる。
///
/// - Laravel のバリデーションエラー(`errors`)があれば、その最初のメッセージを優先する
/// - 404(退勤/休憩操作の前提となる「出勤中の勤怠」が存在しない)は分かりやすい定型文にする
/// - それ以外はサーバーの `message` をそのまま出す(空なら汎用文言)
///
/// 401(トークン失効)はメッセージ表示ではなくログイン画面遷移で扱うため、ここには来ない想定。
String punchErrorMessage(ApiException e) {
  final fieldError = e.errors?.values
      .expand((messages) => messages)
      .cast<String?>()
      .firstWhere((m) => m != null && m.isNotEmpty, orElse: () => null);
  if (fieldError != null) return fieldError;

  if (e.statusCode == 404) {
    return '打刻対象の勤怠が見つかりませんでした。画面を更新して状態をご確認ください。';
  }

  return e.message.isNotEmpty ? e.message : 'エラーが発生しました。';
}

/// 打刻APIで [ApiException] 以外の例外(通信断など)が返ったときの汎用文言。
const String punchGenericErrorMessage = '通信エラーが発生しました。時間をおいて再度お試しください。';
