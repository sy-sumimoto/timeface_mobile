import 'package:flutter/material.dart';

import '../../common/theme/app_colors.dart';
import '../../common/widgets/accent_button.dart';
import '../../common/widgets/app_logo.dart';
import '../../common/widgets/labeled_field.dart';
import '../company_shell.dart';
import '../repositories/company_repositories.dart';
import 'company_login_screen.dart';

const _closingDayOptions = ['1日', '20日', '末日'];
const _prefectureOptions = ['東京都', '大阪府', '愛知県', '福岡県'];

/// 事業所情報登録画面。[契約・プラン申込フロー](../../../../flows/契約・プラン申込フロー.md)の3〜5.に相当し、
/// メール確認が済んだ直後にサイドバー無しの単独レイアウトで表示する
/// (事業所登録が終わるまでは通常のサイドバー付きアプリ画面には進めない)。
///
/// 送信すると本来は企業・事業所(1件目)・契約(フリープラン)・従業員(申込者本人、
/// プロフィール未完成状態)が同時に作成される想定だが、そのAPI呼び出しは未実装。
/// 現状は入力内容を確認せず[CompanyShell]へ遷移するだけのモック。
class CompanyOnboardingScreen extends StatefulWidget {
  const CompanyOnboardingScreen({
    super.key,
    required this.repositories,
    required this.userName,
  });

  final CompanyRepositories repositories;
  final String userName;

  @override
  State<CompanyOnboardingScreen> createState() =>
      _CompanyOnboardingScreenState();
}

class _CompanyOnboardingScreenState extends State<CompanyOnboardingScreen> {
  final _companyNameController = TextEditingController();
  final _companyNameKanaController = TextEditingController();
  final _representativeNameController = TextEditingController();
  final _representativeNameKanaController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _faxController = TextEditingController();
  String _closingDay = _closingDayOptions[1];
  String _prefecture = _prefectureOptions.first;

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyNameKanaController.dispose();
    _representativeNameController.dispose();
    _representativeNameKanaController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _faxController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    // TODO: 会社情報・事業所情報のバリデーションと、企業/事業所/契約/従業員を
    // 同時に作成するAPI呼び出しをここに実装する。
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => CompanyShell(repositories: widget.repositories),
      ),
      (route) => false,
    );
  }

  Future<void> _handleLogout() async {
    await widget.repositories.auth.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => CompanyLoginScreen(repositories: widget.repositories),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bodyBg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppLogo(height: 22),
                  Row(
                    children: [
                      Text(
                        '${widget.userName}さん',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: _handleLogout,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                        ),
                        child: const Text(
                          'ログアウト',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '事業所情報を登録してください',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '最後に、会社と事業所の情報を登録すると利用を開始できます。あとから変更できます。',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 26,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '会社情報',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _gridRow(
                                _field(
                                  label: '会社名',
                                  controller: _companyNameController,
                                  hintText: '株式会社サンプル',
                                ),
                                _field(
                                  label: '会社名(カナ)',
                                  controller: _companyNameKanaController,
                                  hintText: 'カブシキガイシャサンプル',
                                ),
                              ),
                              const SizedBox(height: 20),
                              _gridRow(
                                _field(
                                  label: '代表者名',
                                  controller: _representativeNameController,
                                  hintText: '山田太郎',
                                ),
                                _field(
                                  label: '代表者名(カナ)',
                                  controller: _representativeNameKanaController,
                                  hintText: 'ヤマダタロウ',
                                ),
                              ),
                              const SizedBox(height: 20),
                              AppLabel(text: '勤怠締め日', required: true),
                              DropdownButtonFormField<String>(
                                initialValue: _closingDay,
                                decoration: appInputDecoration(),
                                items: [
                                  for (final option in _closingDayOptions)
                                    DropdownMenuItem(
                                      value: option,
                                      child: Text(option),
                                    ),
                                ],
                                onChanged: (value) => setState(
                                  () => _closingDay = value ?? _closingDay,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                '給与計算のための勤怠締めサイクルの基準日です。あとから変更できます。',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 28),
                              const Divider(height: 1, color: AppColors.border),
                              const SizedBox(height: 24),
                              const Text(
                                '所在地・連絡先',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                '最初の事業所(本社)の情報として登録されます。事業所は後から追加・編集できます。',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _gridRow(
                                _field(
                                  label: '郵便番号',
                                  controller: _postalCodeController,
                                  hintText: '150-0001',
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const AppLabel(
                                      text: '都道府県',
                                      required: true,
                                    ),
                                    DropdownButtonFormField<String>(
                                      initialValue: _prefecture,
                                      decoration: appInputDecoration(),
                                      items: [
                                        for (final option in _prefectureOptions)
                                          DropdownMenuItem(
                                            value: option,
                                            child: Text(option),
                                          ),
                                      ],
                                      onChanged: (value) => setState(
                                        () =>
                                            _prefecture = value ?? _prefecture,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              _field(
                                label: '市町村区',
                                controller: _cityController,
                                hintText: '渋谷区神宮前',
                              ),
                              const SizedBox(height: 20),
                              _field(
                                label: '番地・建物名・号室等',
                                controller: _addressController,
                                hintText: '1-2-3 サンプルビル5F',
                              ),
                              const SizedBox(height: 20),
                              _gridRow(
                                _field(
                                  label: '電話番号',
                                  controller: _phoneController,
                                  hintText: '03-1234-5678',
                                  keyboardType: TextInputType.phone,
                                ),
                                _field(
                                  label: 'FAX',
                                  controller: _faxController,
                                  hintText: '03-1234-5679',
                                  keyboardType: TextInputType.phone,
                                  required: false,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(top: 20),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: AppColors.border),
                                  ),
                                ),
                                child: AccentButton(
                                  label: '登録して利用を開始する',
                                  onPressed: _handleSubmit,
                                  expand: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gridRow(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 20),
        Expanded(child: right),
      ],
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? hintText,
    TextInputType? keyboardType,
    bool required = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppLabel(text: label, required: required),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: appInputDecoration(hintText: hintText),
        ),
      ],
    );
  }
}
