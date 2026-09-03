import 'package:flutter/material.dart';

import '../../common/theme/app_colors.dart';
import '../../common/widgets/app_logo.dart';
import '../employee_shell.dart';
import '../repositories/employee_repositories.dart';
import 'login_screen.dart';

/// アプリ起動時に最初に表示する画面。
///
/// 端末のセキュアストレージに保存済みのアクセストークンがあれば
/// ログイン状態を復元して[EmployeeShell]へ、無ければ[LoginScreen]へ遷移する。
/// 判定中はロゴとローディングインジケータだけを表示する。
class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key, required this.repositories});

  final EmployeeRepositories repositories;

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // 保存済みトークンからログイン状態の復元を試みる
    final user = await widget.repositories.auth.restoreSession();
    if (!mounted) return;

    // 復元できなければログイン画面、できればホーム画面へ差し替える
    // (pushReplacementでこの起動画面には戻れないようにする)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => user == null
            ? LoginScreen(repositories: widget.repositories)
            : EmployeeShell(repositories: widget.repositories),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bodyBg,
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(height: 30),
            SizedBox(height: 24),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}
