/// [id, label]の単純な選択肢。TimeFace2側の`[id => label]`形式の選択肢配列に対応する。
class IdLabelOption {
  const IdLabelOption({required this.id, required this.label});

  final String id;
  final String label;

  factory IdLabelOption.fromJson(Map<String, dynamic> json) {
    return IdLabelOption(id: json['id'].toString(), label: json['label'] as String);
  }
}

/// 在籍状況の選択肢。退職日フィールドの表示切替に使う`requiresEndDate`を持つ点が
/// [IdLabelOption]と異なる。
class EmploymentStatusOption {
  const EmploymentStatusOption({required this.id, required this.label, required this.requiresEndDate});

  final String id;
  final String label;
  final bool requiresEndDate;

  factory EmploymentStatusOption.fromJson(Map<String, dynamic> json) {
    return EmploymentStatusOption(
      id: json['id'].toString(),
      label: json['label'] as String,
      requiresEndDate: json['requires_end_date'] as bool,
    );
  }
}

/// 従業員登録・編集フォームの選択肢一式(+編集時は現在値)。TimeFace2の
/// `Api\Company\EmployeeController@formOptions`(`EmployeeAppService::getEdit()`)に対応する。
class EmployeeFormOptions {
  const EmployeeFormOptions({
    required this.genderOptions,
    required this.employeeDivisionOptions,
    required this.employmentStatusOptions,
    required this.postOptions,
    required this.officeOptions,
    required this.departmentOptions,
    required this.roleOptions,
    required this.roleScopeTypes,
    required this.workPatternOptions,
  });

  final List<IdLabelOption> genderOptions;
  final List<IdLabelOption> employeeDivisionOptions;
  final List<EmploymentStatusOption> employmentStatusOptions;
  final List<IdLabelOption> postOptions;
  final List<IdLabelOption> officeOptions;
  final List<IdLabelOption> departmentOptions;
  final List<IdLabelOption> roleOptions;

  /// ロールID(文字列)→適用範囲(1:全社 2:事業所限定)のマップ。
  final Map<String, int> roleScopeTypes;
  final List<IdLabelOption> workPatternOptions;

  factory EmployeeFormOptions.fromJson(Map<String, dynamic> json) {
    List<IdLabelOption> options(String key) =>
        (json[key] as List).map((e) => IdLabelOption.fromJson(e as Map<String, dynamic>)).toList();

    return EmployeeFormOptions(
      genderOptions: options('gender_options'),
      employeeDivisionOptions: options('employee_division_options'),
      employmentStatusOptions: (json['employment_status_options'] as List)
          .map((e) => EmploymentStatusOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      postOptions: options('post_options'),
      officeOptions: options('office_options'),
      departmentOptions: options('department_options'),
      roleOptions: options('role_options'),
      roleScopeTypes: (json['role_scope_types'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value as int),
      ),
      workPatternOptions: options('work_pattern_options'),
    );
  }
}
