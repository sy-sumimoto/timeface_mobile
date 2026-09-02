/// ログイン中の従業員情報。TimeFace2側の `employee`(Employeeモデル)の一部を保持する。
/// `initial` はアイコン表示用に氏名の先頭1文字をアプリ側で切り出したもの
/// (HttpAuthRepository.login参照。TimeFace2のレスポンス自体には含まれない)。
class AppUser {
  const AppUser({required this.name, required this.email, required this.initial});

  final String name;
  final String email;
  final String initial;
}
