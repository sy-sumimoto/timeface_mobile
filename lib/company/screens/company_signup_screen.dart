import 'package:flutter/material.dart';

import '../../common/api/api_exception.dart';
import '../../common/theme/app_colors.dart';
import '../../common/widgets/accent_button.dart';
import '../../common/widgets/app_logo.dart';
import '../../common/widgets/labeled_field.dart';
import '../repositories/company_repositories.dart';
import 'company_signup_verify_code_screen.dart';

/// 「無料で始める」申込フォーム。[契約・プラン申込フロー](../../../../flows/契約・プラン申込フロー.md)の
/// 1.に相当し、姓・名・メールアドレス・パスワードのみを聞く軽量フォーム
/// (会社名やプラン選択はここでは聞かない)。
///
/// 送信すると[CompanySignupRepository.requestSignUpCode]でTimeFace2の実API
/// (`Api\Company\SignupController`)を叩いて認証コードを送信し、
/// [CompanySignUpVerifyCodeScreen]へ遷移する。
class CompanySignUpScreen extends StatefulWidget {
  const CompanySignUpScreen({super.key, required this.repositories});

  final CompanyRepositories repositories;

  @override
  State<CompanySignUpScreen> createState() => _CompanySignUpScreenState();
}

class _CompanySignUpScreenState extends State<CompanySignUpScreen> {
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  bool _submitting = false;
  String? _lastNameError;
  String? _firstNameError;
  String? _emailError;
  String? _passwordError;
  String? _passwordConfirmError;
  String? _termsError;

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  /// サーバーに送る前のクライアント側簡易バリデーション(未入力・文字数・メール形式のみ)。
  /// 詳細なチェック(メール重複確認等)はTimeFace2側で行い、
  /// 失敗時は [ApiException] として返ってくる(_handleSubmit参照)。
  bool _validate() {
    final lastName = _lastNameController.text.trim();
    final firstName = _firstNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final passwordConfirm = _passwordConfirmController.text;

    String? lastNameError;
    String? firstNameError;
    String? emailError;
    String? passwordError;
    String? passwordConfirmError;
    String? termsError;

    if (lastName.isEmpty) {
      lastNameError = '姓を入力してください';
    } else if (lastName.length > 255) {
      lastNameError = '姓は255文字以内で入力してください';
    }

    if (firstName.isEmpty) {
      firstNameError = '名を入力してください';
    } else if (firstName.length > 255) {
      firstNameError = '名は255文字以内で入力してください';
    }

    if (email.isEmpty || !email.contains('@') || email.length > 255) {
      emailError = '有効なメールアドレスを入力してください';
    }

    if (password.isEmpty) {
      passwordError = 'パスワードを入力してください';
    } else if (password.length > 255) {
      passwordError = 'パスワードは255文字以内で入力してください';
    }

    if (passwordError == null && password != passwordConfirm) {
      passwordConfirmError = 'パスワードが一致しません';
    }

    if (!_agreedToTerms) {
      termsError = '利用規約とプライバシーポリシーへの同意が必要です';
    }

    setState(() {
      _lastNameError = lastNameError;
      _firstNameError = firstNameError;
      _emailError = emailError;
      _passwordError = passwordError;
      _passwordConfirmError = passwordConfirmError;
      _termsError = termsError;
    });

    return lastNameError == null &&
        firstNameError == null &&
        emailError == null &&
        passwordError == null &&
        passwordConfirmError == null &&
        termsError == null;
  }

  Future<void> _handleSubmit() async {
    if (!_validate()) return;

    setState(() => _submitting = true);
    try {
      await widget.repositories.signup.requestSignUpCode(
        lastName: _lastNameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CompanySignUpVerifyCodeScreen(
            repositories: widget.repositories,
            email: _emailController.text.trim(),
            lastName: _lastNameController.text.trim(),
            firstName: _firstNameController.text.trim(),
          ),
        ),
      );
    } on ApiException catch (e) {
      setState(() {
        _lastNameError = e.errorFor('last_name');
        _firstNameError = e.errorFor('first_name');
        _emailError = e.errorFor('email') ?? e.message;
        _passwordError = e.errorFor('password');
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bodyBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Align(
                          alignment: Alignment.center,
                          child: AppLogo(),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '無料で始める',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'クレジットカード登録は不要です。今すぐご利用いただけます。',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const AppLabel(text: '姓', required: true),
                                  TextField(
                                    controller: _lastNameController,
                                    decoration: appInputDecoration(
                                      hintText: '山田',
                                    ),
                                  ),
                                  if (_lastNameError != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      _lastNameError!,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626)),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const AppLabel(text: '名', required: true),
                                  TextField(
                                    controller: _firstNameController,
                                    decoration: appInputDecoration(
                                      hintText: '太郎',
                                    ),
                                  ),
                                  if (_firstNameError != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      _firstNameError!,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626)),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const AppLabel(text: 'メールアドレス', required: true),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: appInputDecoration(
                            hintText: 'you@example.co.jp',
                          ),
                        ),
                        if (_emailError != null) ...[
                          const SizedBox(height: 4),
                          Text(_emailError!, style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
                        ],
                        const SizedBox(height: 16),
                        const AppLabel(text: 'パスワード', required: true),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: appInputDecoration(hintText: '8文字以上の半角英数')
                              .copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 18,
                                    color: AppColors.textSubtle,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                              ),
                        ),
                        if (_passwordError != null) ...[
                          const SizedBox(height: 4),
                          Text(_passwordError!, style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
                        ],
                        const SizedBox(height: 16),
                        const AppLabel(text: 'パスワード(確認)', required: true),
                        TextField(
                          controller: _passwordConfirmController,
                          obscureText: true,
                          onSubmitted: (_) => _handleSubmit(),
                          decoration: appInputDecoration(
                            hintText: '8文字以上の半角英数',
                          ),
                        ),
                        if (_passwordConfirmError != null) ...[
                          const SizedBox(height: 4),
                          Text(_passwordConfirmError!, style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
                        ],
                        const SizedBox(height: 16),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () =>
                              setState(() => _agreedToTerms = !_agreedToTerms),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: Checkbox(
                                  value: _agreedToTerms,
                                  onChanged: (value) => setState(
                                    () => _agreedToTerms = value ?? false,
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Text.rich(
                                    TextSpan(
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textBase,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '利用規約',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        TextSpan(text: 'および'),
                                        TextSpan(
                                          text: 'プライバシーポリシー',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        TextSpan(text: 'に同意する'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_termsError != null) ...[
                          const SizedBox(height: 4),
                          Text(_termsError!, style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
                        ],
                        const SizedBox(height: 20),
                        _submitting
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 13),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              )
                            : AccentButton(
                                label: '無料で始める',
                                onPressed: _handleSubmit,
                                expand: true,
                              ),
                        const SizedBox(height: 10),
                        GhostButton(
                          label: 'アカウントをお持ちの方はこちら',
                          onPressed: () => Navigator.of(context).maybePop(),
                          expand: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                '© 2026 TimeFace. All rights reserved.',
                style: TextStyle(fontSize: 12, color: AppColors.textSubtle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
