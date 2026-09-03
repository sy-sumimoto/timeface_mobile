/// ログイン中の従業員情報。TimeFace側の `employee`(Employeeモデル)の一部を保持する。
/// `initial` はアイコン表示用に氏名の先頭1文字をアプリ側で切り出したもの
/// (HttpAuthRepository.login参照。TimeFace2のレスポンス自体には含まれない)。
///
/// [employeeNumber] / [companyName] は `GET /api/mobile/me` で取得できる付加情報。
/// ログインレスポンスにも含まれるが、古いキャッシュから復元した場合は
/// 取得できないことがあるため null 許容にしている。
class AppUser {
  const AppUser({
    required this.name,
    required this.email,
    required this.initial,
    this.employeeNumber,
    this.companyName,
  });

  final String name;
  final String email;
  final String initial;
  final String? employeeNumber;
  final String? companyName;
}
