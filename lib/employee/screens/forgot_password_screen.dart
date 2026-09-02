import 'package:flutter/material.dart';

import '../../common/api/api_exception.dart';
import '../../common/theme/app_colors.dart';
import '../../common/widgets/accent_button.dart';
import '../../common/widgets/app_logo.dart';
import '../../common/widgets/labeled_field.dart';
import '../repositories/employee_repositories.dart';
import 'forgot_password_verify_code_screen.dart';

/// パスワードをお忘れの方向けの入口画面。HTMLモック
/// (`employee/forgot-password/index.html`)に対応する。
///
/// 登録済みメールアドレス宛に6桁の認証コードを送信し、
/// [ForgotPasswordVerifyCodeScreen]へ遷移する。
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, required this.repositories});

  final EmployeeRepositories repositories;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _submitting = false;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _validate() {
    final email = _emailController.text.trim();
    String? emailError;
    if (email.isEmpty) {
      emailError = 'メールアドレスを入力してください';
    } else if (!email.contains('@')) {
      emailError = 'メールアドレスの形式が正しくありません';
    }
    setState(() => _emailError = emailError);
    return emailError == null;
  }

  Future<void> _handleSubmit() async {
    if (!_validate()) return;
    setState(() => _submitting = true);
    try {
      final email = _emailController.text.trim();
      await widget.repositories.passwordReset.requestReset(email: email);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ForgotPasswordVerifyCodeScreen(
            repositories: widget.repositories,
            email: email,
          ),
        ),
      );
    } on ApiException catch (e) {
      setState(() => _emailError = e.errorFor('email') ?? e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _handleBackToLogin() {
    Navigator.of(context).popUntil((route) => route.isFirst);
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
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Align(
                          alignment: Alignment.center,
                          child: AppLogo(height: 30),
                        ),
                        const SizedBox(height: 28),
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'パスワードをお忘れの方',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            '登録済みのメールアドレスを入力してください。認証コードを送信します。',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const AppLabel(text: 'メールアドレス', required: true),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          onSubmitted: (_) => _handleSubmit(),
                          decoration: appInputDecoration(
                            hintText: 'you@example.co.jp',
                          ),
                        ),
                        if (_emailError != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _emailError!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        _submitting
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 13),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              )
                            : AccentButton(
                                label: '認証コードを送信',
                                onPressed: _handleSubmit,
                                expand: true,
                              ),
                        const SizedBox(height: 10),
                        GhostButton(
                          label: 'ログインに戻る',
                          onPressed: _handleBackToLogin,
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
