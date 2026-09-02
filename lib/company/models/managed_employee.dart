/// 企業管理者が管理する従業員1件分。TimeFace2の`Employee`モデル
/// (`app/Models/Employee.php`)のうち、一覧・登録編集フォームで使う項目を持つ。
class ManagedEmployee {
  const ManagedEmployee({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.email,
    required this.officeName,
    required this.departmentName,
    required this.enrollmentStatusLabel,
    required this.hireDate,
    this.employeeNumber = '',
    this.lastNameKana = '',
    this.firstNameKana = '',
    this.officeId,
    this.departmentId,
    this.birthDay,
    this.gender,
    this.employeeDivisionId,
    this.postId,
    this.roleId,
    this.workPatternId,
    this.isAdmin = false,
  });

  final String id;
  final String lastName;
  final String firstName;
  final String email;
  final String officeName;
  final String departmentName;

  /// TimeFace2の `enrollment_status`(1:在職 2:休職 3:退職)の表示ラベル。
  final String enrollmentStatusLabel;

  /// TimeFace2の `hire_at`(Y/n/j形式)相当。
  final String hireDate;

  final String employeeNumber;
  final String lastNameKana;
  final String firstNameKana;
  final String? officeId;
  final String? departmentId;

  /// TimeFace2の `birth_day`(yyyy-MM-dd)相当。
  final String? birthDay;

  /// TimeFace2の `gender`(1:男性 2:女性 3:その他)選択肢のid。
  final int? gender;
  final String? employeeDivisionId;
  final String? postId;
  final String? roleId;
  final String? workPatternId;
  final bool isAdmin;

  String get fullName => '$lastName$firstName';
}
