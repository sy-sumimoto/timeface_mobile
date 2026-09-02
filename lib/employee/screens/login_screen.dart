import 'package:flutter/material.dart';

import '../../common/api/api_exception.dart';
import '../employee_shell.dart';
import '../repositories/employee_repositories.dart';
import '../../common/theme/app_colors.dart';
import '../../common/widgets/accent_button.dart';
import '../../common/widgets/app_logo.dart';
import '../../common/widgets/labeled_checkbox.dart';
import '../../common/widgets/labeled_field.dart';
import 'forgot_password_screen.dart';

/// ログイン画面。TimeFace2の `POST /login`(AuthController@login)を叩き、
/// 成功したら[EmployeeShell](ホーム画面)へ遷移する。
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.repositories,
    this.showPasswordResetSuccess = false,
  });

  final EmployeeRepositories repositories;

  /// パスワード再設定フロー([ResetPasswordScreen])から戻ってきた際に、
  /// 完了バナーを表示するかどうか。
  final bool showPasswordResetSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _submitting = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// サーバーに送る前のクライアント側簡易バリデーション(未入力・メール形式のみ)。
  /// 詳細なチェック(存在確認・パスワード一致等)はTimeFace2側で行い、
  /// 失敗時は [ApiException] として返ってくる(_handleSubmit参照)。
  bool _validate() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    String? emailError;
    String? passwordError;

    if (email.isEmpty) {
      emailError = 'メールアドレスを入力してください';
    } else if (!email.contains('@')) {
      emailError = 'メールアドレスの形式が正しくありません';
    }
    if (password.isEmpty) {
      passwordError = 'パスワードを入力してください';
    }

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });
    return emailError == null && passwordError == null;
  }

  Future<void> _handleSubmit() async {
    if (!_validate()) return;
    setState(() => _submitting = true);
    try {
      await widget.repositories.auth.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      // ログイン画面には戻れないようにpushReplacementで置き換える
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => EmployeeShell(repositories: widget.repositories),
        ),
      );
    } on ApiException catch (e) {
      // TimeFace2側は「メールアドレスまたはパスワードが違います」を422で返すのみで
      // フィールド単位のerrorsは付かないため、メッセージ本文をパスワード欄に出す
      setState(() {
        _emailError = e.errorFor('email');
        _passwordError =
            e.errorFor('password') ?? (_emailError == null ? e.message : null);
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
                            '従業員ログイン',
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
                            '従業員アカウントでサインインしてください',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        if (widget.showPasswordResetSuccess) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.badgeActiveBg,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Text(
                              'パスワードを変更しました。新しいパスワードでログインしてください。',
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.5,
                                color: AppColors.badgeActiveText,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                        const AppLabel(text: 'メールアドレス', required: true),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: appInputDecoration(
                            hintText: 'yamada@example.co.jp',
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
                        const SizedBox(height: 16),
                        const AppLabel(text: 'パスワード', required: true),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onSubmitted: (_) => _handleSubmit(),
                          decoration: appInputDecoration(hintText: 'パスワード')
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
                        LabeledCheckbox(
                          label: 'ログイン状態を保持',
                          value: _rememberMe,
                          onChanged: (value) =>
                              setState(() => _rememberMe = value),
                        ),
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
                                label: 'ログイン',
                                onPressed: _handleSubmit,
                                expand: true,
                              ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ForgotPasswordScreen(
                                  repositories: widget.repositories,
                                ),
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                            ),
                            child: const Text(
                              'パスワードをお忘れですか?',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
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
