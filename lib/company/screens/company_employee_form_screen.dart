import 'package:flutter/material.dart';
import '../../common/api/api_exception.dart';
import '../../common/theme/app_colors.dart';
import '../../common/utils/date_format.dart';
import '../../common/widgets/app_back_bar.dart';
import '../../common/widgets/labeled_checkbox.dart';
import '../../common/widgets/labeled_field.dart';
import '../../common/widgets/sticky_form_footer.dart';
import '../models/employee_form_options.dart';
import '../models/managed_employee.dart';
import '../repositories/company_repositories.dart';

/// [Iterable.firstWhere]のnull安全版(該当が無ければnullを返す)。
T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T) test) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return null;
}

/// 従業員の新規登録・編集フォーム。TimeFace2の
/// `Api\Company\EmployeeController@formOptions`(表示)/`@save`(保存)に対応する。
/// employeeがnullなら新規登録、指定があれば編集。
class CompanyEmployeeFormScreen extends StatefulWidget {
  const CompanyEmployeeFormScreen({super.key, required this.repositories, this.employee});

  final CompanyRepositories repositories;
  final ManagedEmployee? employee;

  @override
  State<CompanyEmployeeFormScreen> createState() => _CompanyEmployeeFormScreenState();
}

class _CompanyEmployeeFormScreenState extends State<CompanyEmployeeFormScreen> {
  late final _employeeNumberController = TextEditingController(text: widget.employee?.employeeNumber ?? '');
  late final _lastNameController = TextEditingController(text: widget.employee?.lastName ?? '');
  late final _firstNameController = TextEditingController(text: widget.employee?.firstName ?? '');
  late final _lastNameKanaController = TextEditingController(text: widget.employee?.lastNameKana ?? '');
  late final _firstNameKanaController = TextEditingController(text: widget.employee?.firstNameKana ?? '');
  late final _emailController = TextEditingController(text: widget.employee?.email ?? '');

  EmployeeFormOptions? _options;
  IdLabelOption? _selectedOffice;
  IdLabelOption? _selectedDepartment;
  IdLabelOption? _selectedGender;
  IdLabelOption? _selectedEmployeeDivision;
  IdLabelOption? _selectedPost;
  IdLabelOption? _selectedRole;
  IdLabelOption? _selectedWorkPattern;
  EmploymentStatusOption? _selectedEnrollmentStatus;
  DateTime? _birthDay;
  DateTime? _hireDate;
  bool _isAdmin = false;

  String? _employeeNumberError;
  String? _lastNameError;
  String? _firstNameError;
  String? _lastNameKanaError;
  String? _firstNameKanaError;
  String? _emailError;
  String? _officeError;
  String? _birthDayError;
  String? _genderError;
  String? _hireDateError;
  String? _employeeDivisionError;
  String? _postError;
  String? _roleError;
  String? _workPatternError;

  bool _loadingOptions = true;
  bool _loadingDepartments = false;
  bool _submitting = false;

  bool get _isEdit => widget.employee != null;

  @override
  void initState() {
    super.initState();
    if (widget.employee?.hireDate.isNotEmpty ?? false) {
      _hireDate = DateTime.tryParse(widget.employee!.hireDate);
    }
    if (widget.employee?.birthDay != null) {
      _birthDay = DateTime.tryParse(widget.employee!.birthDay!);
    }
    _isAdmin = widget.employee?.isAdmin ?? false;
    _loadOptions();
  }

  @override
  void dispose() {
    _employeeNumberController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _lastNameKanaController.dispose();
    _firstNameKanaController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// フォームの選択肢一式(+編集時は現在値)を読み込み、既存従業員の値を選択状態にする。
  ///
  /// 新規登録時、TimeFace2側は「事業所未選択」扱いで部署選択肢を空で返す
  /// (Web版と同じくAjaxで事業所選択後に取り直す設計)。この画面は最初の事業所を
  /// 自動選択するため、その事業所に紐づく部署をここで明示的に取り直しておく。
  Future<void> _loadOptions() async {
    final options = await widget.repositories.employee.fetchFormOptions(id: widget.employee?.id);
    if (!mounted) return;

    final selectedOffice = _firstWhereOrNull(options.officeOptions, (o) => o.id == widget.employee?.officeId) ??
        (options.officeOptions.isNotEmpty ? options.officeOptions.first : null);

    setState(() {
      _options = options;
      _selectedOffice = selectedOffice;
      _selectedDepartment = _firstWhereOrNull(options.departmentOptions, (d) => d.id == widget.employee?.departmentId);
      _selectedGender = _firstWhereOrNull(options.genderOptions, (g) => g.id == widget.employee?.gender?.toString());
      _selectedEmployeeDivision =
          _firstWhereOrNull(options.employeeDivisionOptions, (d) => d.id == widget.employee?.employeeDivisionId);
      _selectedPost = _firstWhereOrNull(options.postOptions, (p) => p.id == widget.employee?.postId);
      _selectedRole = _firstWhereOrNull(options.roleOptions, (r) => r.id == widget.employee?.roleId);
      _selectedWorkPattern =
          _firstWhereOrNull(options.workPatternOptions, (w) => w.id == widget.employee?.workPatternId);
      _selectedEnrollmentStatus = options.employmentStatusOptions.isEmpty
          ? null
          : options.employmentStatusOptions.first;
      _loadingOptions = false;
    });

    // 新規登録時、自動選択した事業所に紐づく部署を取り直す(編集時はformOptionsが
    // 既にselectedOfficeId基準の部署一覧を返しているため不要)。
    if (!_isEdit && selectedOffice != null) {
      await _reloadDepartmentOptions(selectedOffice.id);
    }
  }

  /// 事業所選択が変わった際、その事業所に属する部署の選択肢を取り直す。
  Future<void> _handleOfficeChanged(IdLabelOption? office) async {
    setState(() {
      _selectedOffice = office;
      _selectedDepartment = null;
      _loadingDepartments = office != null;
    });
    if (office == null) return;
    await _reloadDepartmentOptions(office.id);
  }

  Future<void> _reloadDepartmentOptions(String officeId) async {
    setState(() => _loadingDepartments = true);
    final departments = await widget.repositories.employee.fetchDepartmentOptions(officeId: officeId);
    if (!mounted) return;
    setState(() {
      _options = EmployeeFormOptions(
        genderOptions: _options!.genderOptions,
        employeeDivisionOptions: _options!.employeeDivisionOptions,
        employmentStatusOptions: _options!.employmentStatusOptions,
        postOptions: _options!.postOptions,
        officeOptions: _options!.officeOptions,
        departmentOptions: departments,
        roleOptions: _options!.roleOptions,
        roleScopeTypes: _options!.roleScopeTypes,
        workPatternOptions: _options!.workPatternOptions,
      );
      _loadingDepartments = false;
    });
  }

  bool _validate() {
    final email = _emailController.text.trim();

    setState(() {
      _employeeNumberError = _employeeNumberController.text.trim().isEmpty ? '従業員番号を入力してください' : null;
      _lastNameError = _lastNameController.text.trim().isEmpty ? '姓を入力してください' : null;
      _firstNameError = _firstNameController.text.trim().isEmpty ? '名を入力してください' : null;
      _lastNameKanaError = _lastNameKanaController.text.trim().isEmpty ? '姓(カナ)を入力してください' : null;
      _firstNameKanaError = _firstNameKanaController.text.trim().isEmpty ? '名(カナ)を入力してください' : null;
      _emailError = email.isEmpty
          ? 'メールアドレスを入力してください'
          : (!email.contains('@') ? 'メールアドレスの形式が正しくありません' : null);
      _officeError = _selectedOffice == null ? '事業所を選択してください' : null;
      _birthDayError = _birthDay == null ? '生年月日を選択してください' : null;
      _genderError = _selectedGender == null ? '性別を選択してください' : null;
      _hireDateError = _hireDate == null ? '入社日を選択してください' : null;
      _employeeDivisionError = _selectedEmployeeDivision == null ? '従業員区分を選択してください' : null;
      _postError = _selectedPost == null ? '役職を選択してください' : null;
      _roleError = _selectedRole == null ? '権限ロールを選択してください' : null;
      _workPatternError = _selectedWorkPattern == null ? '勤務パターンを選択してください' : null;
    });

    return _employeeNumberError == null &&
        _lastNameError == null &&
        _firstNameError == null &&
        _lastNameKanaError == null &&
        _firstNameKanaError == null &&
        _emailError == null &&
        _officeError == null &&
        _birthDayError == null &&
        _genderError == null &&
        _hireDateError == null &&
        _employeeDivisionError == null &&
        _postError == null &&
        _roleError == null &&
        _workPatternError == null;
  }

  Future<void> _pickBirthDay() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDay ?? DateTime(now.year - 30),
      firstDate: DateTime(now.year - 80),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() => _birthDay = picked);
  }

  Future<void> _pickHireDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _hireDate ?? now,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year + 1),
    );
    if (picked == null) return;
    setState(() => _hireDate = picked);
  }

  Future<void> _handleSubmit() async {
    if (!_validate()) return;
    setState(() => _submitting = true);
    try {
      await widget.repositories.employee.save(
        id: widget.employee?.id,
        officeId: _selectedOffice!.id,
        departmentId: _selectedDepartment?.id,
        employeeNumber: _employeeNumberController.text.trim(),
        lastName: _lastNameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastNameKana: _lastNameKanaController.text.trim(),
        firstNameKana: _firstNameKanaController.text.trim(),
        birthDay: formatIsoDate(_birthDay!),
        gender: int.parse(_selectedGender!.id),
        hireDate: formatIsoDate(_hireDate!),
        employeeDivisionId: _selectedEmployeeDivision!.id,
        enrollmentStatusId: _isEdit ? _selectedEnrollmentStatus?.id : null,
        email: _emailController.text.trim(),
        postId: _selectedPost!.id,
        roleId: _selectedRole!.id,
        workPatternId: _selectedWorkPattern!.id,
        isAdmin: _isAdmin,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEdit ? '従業員情報を更新しました' : '従業員を登録しました')),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      setState(() {
        _employeeNumberError = e.errorFor('employeeNumber') ?? _employeeNumberError;
        _lastNameError = e.errorFor('lastName') ?? _lastNameError;
        _firstNameError = e.errorFor('firstName') ?? _firstNameError;
        _lastNameKanaError = e.errorFor('lastNameKana') ?? _lastNameKanaError;
        _firstNameKanaError = e.errorFor('firstNameKana') ?? _firstNameKanaError;
        _emailError = e.errorFor('email') ?? _emailError;
        _officeError = e.errorFor('officeId') ?? _officeError;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bodyBg,
      appBar: AppBackBar(title: _isEdit ? '従業員を編集' : '従業員を登録', onBack: () => Navigator.of(context).pop()),
      body: _loadingOptions
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppLabel(text: '従業員番号', required: true),
                  TextField(controller: _employeeNumberController, decoration: appInputDecoration(hintText: '例: 1001')),
                  _errorText(_employeeNumberError),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppLabel(text: '姓', required: true),
                            TextField(controller: _lastNameController, decoration: appInputDecoration(hintText: '山田')),
                            _errorText(_lastNameError),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppLabel(text: '名', required: true),
                            TextField(controller: _firstNameController, decoration: appInputDecoration(hintText: '太郎')),
                            _errorText(_firstNameError),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppLabel(text: '姓(カナ)', required: true),
                            TextField(
                              controller: _lastNameKanaController,
                              decoration: appInputDecoration(hintText: 'ヤマダ'),
                            ),
                            _errorText(_lastNameKanaError),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppLabel(text: '名(カナ)', required: true),
                            TextField(
                              controller: _firstNameKanaController,
                              decoration: appInputDecoration(hintText: 'タロウ'),
                            ),
                            _errorText(_firstNameKanaError),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const AppLabel(text: 'メールアドレス', required: true),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: appInputDecoration(hintText: 'yamada@example.co.jp'),
                  ),
                  _errorText(_emailError),
                  const SizedBox(height: 20),
                  const AppLabel(text: '生年月日', required: true),
                  AppMockField(
                    text: _birthDay != null ? formatSlashDate(_birthDay!) : null,
                    hint: 'yyyy/m/d',
                    onTap: _pickBirthDay,
                  ),
                  _errorText(_birthDayError),
                  const SizedBox(height: 20),
                  const AppLabel(text: '性別', required: true),
                  DropdownButtonFormField<IdLabelOption>(
                    initialValue: _selectedGender,
                    decoration: appInputDecoration(hintText: '選択してください'),
                    items: _options!.genderOptions
                        .map((g) => DropdownMenuItem(value: g, child: Text(g.label)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedGender = value),
                  ),
                  _errorText(_genderError),
                  const SizedBox(height: 20),
                  const AppLabel(text: '事業所', required: true),
                  DropdownButtonFormField<IdLabelOption>(
                    initialValue: _selectedOffice,
                    decoration: appInputDecoration(),
                    items: _options!.officeOptions
                        .map((o) => DropdownMenuItem(value: o, child: Text(o.label)))
                        .toList(),
                    onChanged: _handleOfficeChanged,
                  ),
                  _errorText(_officeError),
                  const SizedBox(height: 20),
                  const AppLabel(text: '部署'),
                  DropdownButtonFormField<IdLabelOption>(
                    initialValue: _selectedDepartment,
                    decoration: appInputDecoration(hintText: _loadingDepartments ? '読み込み中…' : '部署を選択'),
                    items: _options!.departmentOptions
                        .map((d) => DropdownMenuItem(value: d, child: Text(d.label)))
                        .toList(),
                    onChanged: _loadingDepartments ? null : (value) => setState(() => _selectedDepartment = value),
                  ),
                  const SizedBox(height: 20),
                  const AppLabel(text: '従業員区分', required: true),
                  DropdownButtonFormField<IdLabelOption>(
                    initialValue: _selectedEmployeeDivision,
                    decoration: appInputDecoration(hintText: '選択してください'),
                    items: _options!.employeeDivisionOptions
                        .map((d) => DropdownMenuItem(value: d, child: Text(d.label)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedEmployeeDivision = value),
                  ),
                  _errorText(_employeeDivisionError),
                  const SizedBox(height: 20),
                  const AppLabel(text: '役職', required: true),
                  DropdownButtonFormField<IdLabelOption>(
                    initialValue: _selectedPost,
                    decoration: appInputDecoration(hintText: '選択してください'),
                    items: _options!.postOptions
                        .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedPost = value),
                  ),
                  _errorText(_postError),
                  const SizedBox(height: 20),
                  const AppLabel(text: '権限ロール', required: true),
                  DropdownButtonFormField<IdLabelOption>(
                    initialValue: _selectedRole,
                    decoration: appInputDecoration(hintText: '選択してください'),
                    items: _options!.roleOptions
                        .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedRole = value),
                  ),
                  _errorText(_roleError),
                  const SizedBox(height: 20),
                  const AppLabel(text: '勤務パターン', required: true),
                  DropdownButtonFormField<IdLabelOption>(
                    initialValue: _selectedWorkPattern,
                    decoration: appInputDecoration(hintText: '選択してください'),
                    items: _options!.workPatternOptions
                        .map((w) => DropdownMenuItem(value: w, child: Text(w.label)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedWorkPattern = value),
                  ),
                  _errorText(_workPatternError),
                  if (_isEdit && _options!.employmentStatusOptions.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const AppLabel(text: '在籍状況', required: true),
                    DropdownButtonFormField<EmploymentStatusOption>(
                      initialValue: _selectedEnrollmentStatus,
                      decoration: appInputDecoration(),
                      items: _options!.employmentStatusOptions
                          .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedEnrollmentStatus = value),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const AppLabel(text: '入社日', required: true),
                  AppMockField(
                    text: _hireDate != null ? formatSlashDate(_hireDate!) : null,
                    hint: 'yyyy/m/d',
                    onTap: _pickHireDate,
                  ),
                  _errorText(_hireDateError),
                  const SizedBox(height: 20),
                  LabeledCheckbox(
                    label: '企業管理者にする',
                    value: _isAdmin,
                    onChanged: (value) => setState(() => _isAdmin = value),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _loadingOptions
          ? null
          : StickyFormFooter(
              buttonLabel: _submitting ? '送信中…' : (_isEdit ? '更新する' : '登録する'),
              linkLabel: 'キャンセルして一覧に戻る',
              onSubmit: _submitting ? null : _handleSubmit,
              onCancel: () => Navigator.of(context).pop(),
            ),
    );
  }

  Widget _errorText(String? message) {
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(message, style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
    );
  }
}
