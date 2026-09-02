/// システム管理者アカウント1件分。TimeFace2の`Admin\AdminController`
/// (管理者管理。ログイン中の管理者が他の管理者を管理する)に対応する。
class AdminAccount {
  const AdminAccount({required this.id, required this.name, required this.email});

  final String id;
  final String name;
  final String email;

  AdminAccount copyWith({String? name, String? email}) {
    return AdminAccount(id: id, name: name ?? this.name, email: email ?? this.email);
  }
}
