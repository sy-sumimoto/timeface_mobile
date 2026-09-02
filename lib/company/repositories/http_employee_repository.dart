import '../../common/api/api_client.dart';
import '../models/employee_form_options.dart';
import '../models/managed_employee.dart';
import 'employee_repository.dart';

/// TimeFace2 (`/api/company/employees` 系)を叩く実装。
class HttpEmployeeRepository implements EmployeeRepository {
  HttpEmployeeRepository({required this.client});

  final ApiClient client;

  @override
  Future<List<ManagedEmployee>> fetchAll() async {
    final data = await client.get('/employees');
    final list = data['employees'] as List;
    return list.map((e) => _employeeFromListJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<ManagedEmployee> fetchById(String id) async {
    final data = await client.get('/employees/form-options/$id');
    return _employeeFromDetailJson(data['employee'] as Map<String, dynamic>);
  }

  @override
  Future<EmployeeFormOptions> fetchFormOptions({String? id}) async {
    final path = id == null ? '/employees/form-options' : '/employees/form-options/$id';
    final data = await client.get(path);
    return EmployeeFormOptions.fromJson(data);
  }

  @override
  Future<List<IdLabelOption>> fetchDepartmentOptions({required String officeId}) async {
    final data = await client.get('/employees/department-options?office_id=$officeId');
    return (data['department_options'] as List)
        .map((e) => IdLabelOption.fromJson(e as Map<String, dynamic>))
        .toList();
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
    // EmployeeController@save(TimeFace2側): idがnullなら新規登録、指定があれば更新
    await client.post('/employees', {
      'id': ?id,
      'officeId': officeId,
      'departmentId': departmentId,
      'employeeNumber': employeeNumber,
      'lastName': lastName,
      'firstName': firstName,
      'lastNameKana': lastNameKana,
      'firstNameKana': firstNameKana,
      'birthDay': birthDay,
      'gender': gender,
      'hireAt': hireDate,
      'employeeDivision': employeeDivisionId,
      'enrollmentStatusId': ?enrollmentStatusId,
      'email': email,
      'postId': postId,
      'roleId': roleId,
      'workPatternId': workPatternId,
      'isAdmin': isAdmin,
    });
  }

  ManagedEmployee _employeeFromListJson(Map<String, dynamic> item) {
    return ManagedEmployee(
      id: item['id'].toString(),
      lastName: item['last_name'] as String,
      firstName: item['first_name'] as String,
      email: item['email'] as String,
      officeName: item['office_name'] as String,
      departmentName: item['department_name'] as String,
      enrollmentStatusLabel: item['enrollment_status_name'] as String,
      hireDate: item['hire_at_label'] as String,
      employeeNumber: item['employee_number'] as String,
      lastNameKana: item['last_name_kana'] as String? ?? '',
      firstNameKana: item['first_name_kana'] as String? ?? '',
    );
  }

  ManagedEmployee _employeeFromDetailJson(Map<String, dynamic> item) {
    return ManagedEmployee(
      id: item['id'].toString(),
      lastName: item['last_name'] as String? ?? '',
      firstName: item['first_name'] as String? ?? '',
      email: item['email'] as String? ?? '',
      officeName: '',
      departmentName: '',
      enrollmentStatusLabel: '',
      hireDate: item['hire_at'] as String? ?? '',
      employeeNumber: item['employee_number'] as String? ?? '',
      lastNameKana: item['last_name_kana'] as String? ?? '',
      firstNameKana: item['first_name_kana'] as String? ?? '',
      officeId: item['office_id']?.toString(),
      departmentId: item['department_id']?.toString(),
      birthDay: item['birth_day'] as String?,
      gender: item['gender'] as int?,
      employeeDivisionId: item['employee_division']?.toString(),
      postId: item['post_id']?.toString(),
      roleId: item['role_id']?.toString(),
      workPatternId: item['work_pattern_id']?.toString(),
      isAdmin: item['is_admin'] as bool? ?? false,
    );
  }
}
