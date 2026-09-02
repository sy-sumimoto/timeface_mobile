/// ログイン中の企業管理者。TimeFace2側の`Company`モデル(企業アカウント本体)に対応する。
/// 従業員(Employee)とは異なり、企業そのものがログイン主体である点に注意
/// (employee/models/app_user.dart の AppUser とは別モデル)。
class CompanyUser {
  const CompanyUser({required this.companyName, required this.email, required this.initial});

  final String companyName;
  final String email;
  final String initial;
}
