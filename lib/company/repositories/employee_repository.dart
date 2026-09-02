import '../models/employee_form_options.dart';
import '../models/managed_employee.dart';

/// 従業員管理(一覧・登録・編集)の取得口。TimeFace2の
/// `Api\Company\EmployeeController`(index/formOptions/save)に対応する。
abstract class EmployeeRepository {
  Future<List<ManagedEmployee>> fetchAll();

  Future<ManagedEmployee> fetchById(String id);

  /// 登録・編集フォームの選択肢一式(+編集時は現在値)を取得する。
  /// idを省略すると新規登録用(現在値は空)になる。
  Future<EmployeeFormOptions> fetchFormOptions({String? id});

  /// 事業所選択が変わった際に、その事業所に属する部署の選択肢を再取得する。
  Future<List<IdLabelOption>> fetchDepartmentOptions({required String officeId});

  /// idがnullなら新規登録、指定があれば更新。TimeFace2側の`save`が
  /// 新規・更新を1つのアクションで担っているのに合わせている。
  Future<void> save({
    String? id,
    required String officeId,
    String? departmentId,
    required String employeeNumber,
    required String lastName,
    required String firstName,
    required String lastNameKana,
    required String firstNameKana,
    required String birthDay,
    required int gender,
    required String hireDate,
    required String employeeDivisionId,
    String? enrollmentStatusId,
    required String email,
    required String postId,
    required String roleId,
    required String workPatternId,
    required bool isAdmin,
  });
}

/// モック実装。インメモリの一覧を直接書き換えるため、一覧画面に戻ると結果が反映される。
class MockEmployeeRepository implements EmployeeRepository {
  int _nextId = 4;

  final List<ManagedEmployee> _items = [
    const ManagedEmployee(
      id: 'e1',
      lastName: '中村',
      firstName: '陽子',
      email: 'nakamura@example.co.jp',
      officeName: '本社オフィス',
      departmentName: '総務部',
      enrollmentStatusLabel: '在職',
      hireDate: '2021/4/1',
    ),
    const ManagedEmployee(
      id: 'e2',
      lastName: '佐藤',
      firstName: '花子',
      email: 'sato@example.co.jp',
      officeName: '本社オフィス',
      departmentName: '営業部',
      enrollmentStatusLabel: '在職',
      hireDate: '2019/10/1',
    ),
    const ManagedEmployee(
      id: 'e3',
      lastName: '鈴木',
      firstName: '一郎',
      email: 'suzuki@example.co.jp',
      officeName: '大阪支店',
      departmentName: '営業部',
      enrollmentStatusLabel: '休職',
      hireDate: '2022/7/1',
    ),
  ];

  static const _mockOptions = EmployeeFormOptions(
    genderOptions: [
      IdLabelOption(id: '1', label: '男性'),
      IdLabelOption(id: '2', label: '女性'),
      IdLabelOption(id: '3', label: 'その他'),
    ],
    employeeDivisionOptions: [IdLabelOption(id: 'd1', label: '正社員')],
    employmentStatusOptions: [
      EmploymentStatusOption(id: 's1', label: '在職', requiresEndDate: false),
      EmploymentStatusOption(id: 's2', label: '休職', requiresEndDate: false),
      EmploymentStatusOption(id: 's3', label: '退職', requiresEndDate: true),
    ],
    postOptions: [IdLabelOption(id: 'p1', label: '一般社員')],
    officeOptions: [IdLabelOption(id: 'o1', label: '本社オフィス')],
    departmentOptions: [IdLabelOption(id: 'dp1', label: '総務部')],
    roleOptions: [IdLabelOption(id: 'r1', label: '一般権限')],
    roleScopeTypes: {'r1': 1},
    workPatternOptions: [IdLabelOption(id: 'w1', label: '標準勤務')],
  );

  @override
  Future<List<ManagedEmployee>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_items);
  }

  @override
  Future<ManagedEmployee> fetchById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _items.firstWhere((e) => e.id == id);
  }

  @override
  Future<EmployeeFormOptions> fetchFormOptions({String? id}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _mockOptions;
  }

  @override
  Future<List<IdLabelOption>> fetchDepartmentOptions({required String officeId}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockOptions.departmentOptions;
  }

  @override
  Future<void> save({
    String? id,
    required String officeId,
    String? departmentId,
    required String employeeNumber,
    required String lastName,
    required String firstName,
    required String lastNameKana,
    required String firstNameKana,
    required String birthDay,
    required int gender,
    required String hireDate,
    required String employeeDivisionId,
    String? enrollmentStatusId,
    required String email,
    required String postId,
    required String roleId,
    required String workPatternId,
    required bool isAdmin,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final officeName = _mockOptions.officeOptions.firstWhere((o) => o.id == officeId).label;
    final matchedDepartments = _mockOptions.departmentOptions.where((d) => d.id == departmentId);
    final departmentName = matchedDepartments.isEmpty ? '-' : matchedDepartments.first.label;

    final saved = ManagedEmployee(
      id: id ?? 'e${_nextId++}',
      lastName: lastName,
      firstName: firstName,
      email: email,
      officeName: officeName,
      departmentName: departmentName,
      enrollmentStatusLabel: '在職',
      hireDate: hireDate,
      employeeNumber: employeeNumber,
      lastNameKana: lastNameKana,
      firstNameKana: firstNameKana,
      officeId: officeId,
      departmentId: departmentId,
      birthDay: birthDay,
      gender: gender,
      employeeDivisionId: employeeDivisionId,
      postId: postId,
      roleId: roleId,
      workPatternId: workPatternId,
      isAdmin: isAdmin,
    );

    if (id == null) {
      _items.insert(0, saved);
      return;
    }
    final index = _items.indexWhere((e) => e.id == id);
    _items[index] = saved;
  }
}
