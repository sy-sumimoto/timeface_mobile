import 'package:flutter/material.dart';

import '../../common/api/api_exception.dart';
import '../../common/theme/app_colors.dart';
import '../../common/widgets/accent_button.dart';
import '../../common/widgets/app_logo.dart';
import '../../common/widgets/labeled_field.dart';
import '../repositories/employee_repositories.dart';
import 'reset_password_screen.dart';

/// 認証コード入力画面。HTMLモック
/// (`employee/forgot-password/verify-code.html`)に対応する。
///
/// [ForgotPasswordScreen]で送信した6桁の認証コードを検証し、
/// [ResetPasswordScreen]へ遷移する。
class ForgotPasswordVerifyCodeScreen extends StatefulWidget {
  const ForgotPasswordVerifyCodeScreen({
    super.key,
    required this.repositories,
    required this.email,
  });

  final EmployeeRepositories repositories;
  final String email;

  @override
  State<ForgotPasswordVerifyCodeScreen> createState() =>
      _ForgotPasswordVerifyCodeScreenState();
}

class _ForgotPasswordVerifyCodeScreenState
    extends State<ForgotPasswordVerifyCodeScreen> {
  final _codeController = TextEditingController();
  bool _verifying = false;
  String? _codeError;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  bool _validate() {
    final code = _codeController.text.trim();
    String? codeError;
    if (code.isEmpty) {
      codeError = '認証コードを入力してください';
    } else if (code.length != 6) {
      codeError = '認証コードは6桁で入力してください';
    }
    setState(() => _codeError = codeError);
    return codeError == null;
  }

  Future<void> _handleSubmit() async {
    if (!_validate()) return;
    setState(() => _verifying = true);
    try {
      final code = _codeController.text.trim();
      await widget.repositories.passwordReset.verifyCode(
        email: widget.email,
        code: code,
      );
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
            repositories: widget.repositories,
            email: widget.email,
            code: code,
          ),
        ),
      );
    } on ApiException catch (e) {
      setState(() => _codeError = e.errorFor('code') ?? e.message);
    } finally {
      if (mounted) setState(() => _verifying = false);
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
                            '認証コードの入力',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            '${widget.email} 宛に送信した6桁の認証コードを入力してください。',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const AppLabel(text: '認証コード', required: true),
                        TextField(
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          onSubmitted: (_) => _handleSubmit(),
                          decoration: appInputDecoration(hintText: '123456')
                              .copyWith(counterText: ''),
                          style: const TextStyle(
                            fontSize: 22,
                            fontFamily: 'Inter',
                            letterSpacing: 10,
                          ),
                        ),
                        if (_codeError != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _codeError!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        _verifying
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
                                label: '次へ',
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
