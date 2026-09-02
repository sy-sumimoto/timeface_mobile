/// ログイン中のシステム管理者。TimeFace2側の`Admin`モデル(DDDsystem運営側の
/// 管理者アカウント)に対応する。
class AdminUser {
  const AdminUser({required this.name, required this.email, required this.initial});

  final String name;
  final String email;
  final String initial;
}
