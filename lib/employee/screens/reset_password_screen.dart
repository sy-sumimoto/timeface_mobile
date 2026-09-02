import 'package:flutter/material.dart';

import '../../common/api/api_exception.dart';
import '../../common/theme/app_colors.dart';
import '../../common/widgets/accent_button.dart';
import '../../common/widgets/app_logo.dart';
import '../../common/widgets/labeled_field.dart';
import '../repositories/employee_repositories.dart';
import 'login_screen.dart';

/// 新しいパスワードの設定画面。HTMLモック
/// (`employee/forgot-password/reset-password.html`)に対応する。
///
/// [ForgotPasswordVerifyCodeScreen]で検証済みの認証コードを使って
/// パスワードを再設定し、成功したら完了バナー付きのログイン画面へ戻る。
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.repositories,
    required this.email,
    required this.code,
  });

  final EmployeeRepositories repositories;
  final String email;
  final String code;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;
  String? _passwordError;
  String? _passwordConfirmError;

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  bool _validate() {
    final password = _passwordController.text;
    final passwordConfirm = _passwordConfirmController.text;
    String? passwordError;
    String? passwordConfirmError;

    if (password.isEmpty) {
      passwordError = 'パスワードを入力してください';
    } else if (password.length < 8) {
      passwordError = 'パスワードは8文字以上で入力してください';
    }

    if (passwordError == null && password != passwordConfirm) {
      passwordConfirmError = 'パスワードが一致しません';
    }

    setState(() {
      _passwordError = passwordError;
      _passwordConfirmError = passwordConfirmError;
    });
    return passwordError == null && passwordConfirmError == null;
  }

  Future<void> _handleSubmit() async {
    if (!_validate()) return;
    setState(() => _submitting = true);
    try {
      await widget.repositories.passwordReset.resetPassword(
        email: widget.email,
        code: widget.code,
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoginScreen(
            repositories: widget.repositories,
            showPasswordResetSuccess: true,
          ),
        ),
        (route) => false,
      );
    } on ApiException catch (e) {
      setState(() {
        _passwordError = e.errorFor('password') ?? e.message;
        _passwordConfirmError = e.errorFor('password_confirmation');
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
                            '新しいパスワードの設定',
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
                            '半角英数8文字以上の新しいパスワードを設定してください。',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const AppLabel(text: '新しいパスワード', required: true),
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
                          Text(
                            _passwordError!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        const AppLabel(text: '新しいパスワード(確認)', required: true),
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
                          Text(
                            _passwordConfirmError!,
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
                                label: 'パスワードを設定してログイン画面へ',
                                onPressed: _handleSubmit,
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
