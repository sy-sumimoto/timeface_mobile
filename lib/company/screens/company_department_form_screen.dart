import 'package:flutter/material.dart';
import '../../common/theme/app_colors.dart';
import '../../common/widgets/app_back_bar.dart';
import '../../common/widgets/labeled_field.dart';
import '../../common/widgets/sticky_form_footer.dart';
import '../models/department.dart';
import '../models/office.dart';
import '../repositories/company_repositories.dart';

/// 部署の新規登録・編集フォーム。TimeFace2の
/// `Company\DepartmentController@form`/`@save`に対応する。
/// 部署は必ずどこか1つの事業所に属するため、事業所の選択が必須。
class CompanyDepartmentFormScreen extends StatefulWidget {
  const CompanyDepartmentFormScreen({super.key, required this.repositories, required this.offices, this.department});

  final CompanyRepositories repositories;
  final List<Office> offices;
  final Department? department;

  @override
  State<CompanyDepartmentFormScreen> createState() => _CompanyDepartmentFormScreenState();
}

class _CompanyDepartmentFormScreenState extends State<CompanyDepartmentFormScreen> {
  late final _nameController = TextEditingController(text: widget.department?.name ?? '');
  Office? _selectedOffice;

  String? _nameError;
  String? _officeError;
  bool _submitting = false;

  bool get _isEdit => widget.department != null;

  @override
  void initState() {
    super.initState();
    final officeId = widget.department?.officeId;
    for (final office in widget.offices) {
      if (office.id == officeId) {
        _selectedOffice = office;
        break;
      }
    }
    _selectedOffice ??= widget.offices.isNotEmpty ? widget.offices.first : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool _validate() {
    String? nameError;
    String? officeError;
    if (_nameController.text.trim().isEmpty) nameError = '部署名を入力してください';
    if (_selectedOffice == null) officeError = '事業所を選択してください';
    setState(() {
      _nameError = nameError;
      _officeError = officeError;
    });
    return nameError == null && officeError == null;
  }

  Future<void> _handleSubmit() async {
    if (!_validate()) return;
    setState(() => _submitting = true);
    try {
      await widget.repositories.department.save(
        id: widget.department?.id,
        name: _nameController.text.trim(),
        officeId: _selectedOffice!.id,
        officeName: _selectedOffice!.name,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEdit ? '部署情報を更新しました' : '部署を登録しました')),
      );
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bodyBg,
      appBar: AppBackBar(title: _isEdit ? '部署を編集' : '部署を登録', onBack: () => Navigator.of(context).pop()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppLabel(text: '部署名', required: true),
            TextField(controller: _nameController, decoration: appInputDecoration(hintText: '総務部')),
            if (_nameError != null) ...[
              const SizedBox(height: 4),
              Text(_nameError!, style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
            ],
            const SizedBox(height: 20),
            const AppLabel(text: '事業所', required: true),
            DropdownButtonFormField<Office>(
              initialValue: _selectedOffice,
              decoration: appInputDecoration(),
              items: widget.offices.map((o) => DropdownMenuItem(value: o, child: Text(o.name))).toList(),
              onChanged: (value) => setState(() => _selectedOffice = value),
            ),
            if (_officeError != null) ...[
              const SizedBox(height: 4),
              Text(_officeError!, style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
            ],
          ],
        ),
      ),
      bottomNavigationBar: StickyFormFooter(
        buttonLabel: _submitting ? '送信中…' : (_isEdit ? '更新する' : '登録する'),
        linkLabel: 'キャンセルして一覧に戻る',
        onSubmit: _submitting ? null : _handleSubmit,
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }
}
