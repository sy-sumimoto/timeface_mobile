import 'package:flutter/material.dart';
import '../../common/theme/app_colors.dart';
import '../../common/widgets/app_back_bar.dart';
import '../../common/widgets/labeled_field.dart';
import '../../common/widgets/sticky_form_footer.dart';
import '../models/office.dart';
import '../repositories/company_repositories.dart';

/// 事業所の新規登録・編集フォーム。TimeFace2の
/// `Company\OfficeController@form`/`@save`に対応する。
class CompanyOfficeFormScreen extends StatefulWidget {
  const CompanyOfficeFormScreen({super.key, required this.repositories, this.office});

  final CompanyRepositories repositories;
  final Office? office;

  @override
  State<CompanyOfficeFormScreen> createState() => _CompanyOfficeFormScreenState();
}

class _CompanyOfficeFormScreenState extends State<CompanyOfficeFormScreen> {
  late final _nameController = TextEditingController(text: widget.office?.name ?? '');
  late final _addressController = TextEditingController(text: widget.office?.address ?? '');
  late final _telController = TextEditingController(text: widget.office?.tel ?? '');

  String? _nameError;
  String? _addressError;
  bool _submitting = false;

  bool get _isEdit => widget.office != null;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _telController.dispose();
    super.dispose();
  }

  bool _validate() {
    String? nameError;
    String? addressError;
    if (_nameController.text.trim().isEmpty) nameError = '事業所名を入力してください';
    if (_addressController.text.trim().isEmpty) addressError = '住所を入力してください';
    setState(() {
      _nameError = nameError;
      _addressError = addressError;
    });
    return nameError == null && addressError == null;
  }

  Future<void> _handleSubmit() async {
    if (!_validate()) return;
    setState(() => _submitting = true);
    try {
      await widget.repositories.office.save(
        id: widget.office?.id,
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        tel: _telController.text.trim().isEmpty ? null : _telController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEdit ? '事業所情報を更新しました' : '事業所を登録しました')),
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
      appBar: AppBackBar(title: _isEdit ? '事業所を編集' : '事業所を登録', onBack: () => Navigator.of(context).pop()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppLabel(text: '事業所名', required: true),
            TextField(controller: _nameController, decoration: appInputDecoration(hintText: '本社オフィス')),
            if (_nameError != null) ...[
              const SizedBox(height: 4),
              Text(_nameError!, style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
            ],
            const SizedBox(height: 20),
            const AppLabel(text: '住所', required: true),
            TextField(controller: _addressController, decoration: appInputDecoration(hintText: '東京都千代田区1-1-1')),
            if (_addressError != null) ...[
              const SizedBox(height: 4),
              Text(_addressError!, style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
            ],
            const SizedBox(height: 20),
            const AppLabel(text: '電話番号'),
            TextField(
              controller: _telController,
              keyboardType: TextInputType.phone,
              decoration: appInputDecoration(hintText: '03-1234-5678'),
            ),
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
