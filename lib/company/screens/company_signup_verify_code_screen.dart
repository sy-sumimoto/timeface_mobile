import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../common/api/api_exception.dart';
import '../../common/theme/app_colors.dart';
import '../../common/widgets/accent_button.dart';
import '../../common/widgets/app_logo.dart';
import '../../common/widgets/labeled_field.dart';
import '../repositories/company_repositories.dart';
import 'company_onboarding_screen.dart';

/// メールアドレス確認画面。[契約・プラン申込フロー](../../../../flows/契約・プラン申込フロー.md)の2.に相当し、
/// [CompanySignUpScreen]で送信した6桁の認証コードを入力させる
/// (従業員招待フローの本人確認とは別の、自己申込み用の簡易フロー)。
///
/// 検証は[CompanySignupRepository.verifySignUpCode]、再送は
/// [CompanySignupRepository.resendSignUpCode]で実装済み。TimeFace2の
/// 実API(`Api\Company\SignupController`)を叩く。
class CompanySignUpVerifyCodeScreen extends StatefulWidget {
  const CompanySignUpVerifyCodeScreen({
    super.key,
    required this.repositories,
    required this.email,
    required this.lastName,
    required this.firstName,
  });

  final CompanyRepositories repositories;
  final String email;
  final String lastName;
  final String firstName;

  @override
  State<CompanySignUpVerifyCodeScreen> createState() =>
      _CompanySignUpVerifyCodeScreenState();
}

class _CompanySignUpVerifyCodeScreenState
    extends State<CompanySignUpVerifyCodeScreen> {
  final _codeController = TextEditingController();
  bool _resending = false;
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
      await widget.repositories.signup.verifySignUpCode(
        email: widget.email,
        code: _codeController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CompanyOnboardingScreen(
            repositories: widget.repositories,
            userName: '${widget.lastName} ${widget.firstName}',
          ),
        ),
      );
    } on ApiException catch (e) {
      setState(() => _codeError = e.errorFor('code') ?? e.message);
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _handleResend() async {
    if (_resending) return;
    setState(() => _resending = true);
    try {
      await widget.repositories.signup.resendSignUpCode(email: widget.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('認証コードを再送しました')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _resending = false);
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
                          '認証コードの入力',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${widget.email} 宛に送信した6桁の認証コードを入力してください。',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 24),
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
                          Text(_codeError!, style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
                        ],
                        const SizedBox(height: 20),
                        _verifying
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
                                label: '確認する',
                                onPressed: _handleSubmit,
                                expand: true,
                              ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text.rich(
                            TextSpan(
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textMuted,
                              ),
                              children: [
                                const TextSpan(text: 'コードが届かない場合は'),
                                TextSpan(
                                  text: _resending ? '送信中…' : '再送する',
                                  style: TextStyle(
                                    color: _resending ? AppColors.textSubtle : AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: _resending
                                      ? null
                                      : (TapGestureRecognizer()..onTap = _handleResend),
                                ),
                              ],
                            ),
                          ),
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
