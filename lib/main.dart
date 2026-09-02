import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'common/theme/app_colors.dart';
import 'employee/providers/employee_repositories_provider.dart';
import 'employee/screens/login_screen.dart';

void main() {
  runApp(
    // Riverpodの状態を保持するルートコンテナ。
    // これより下のWidgetツリーであればどこでも ref.watch/read できる。
    const ProviderScope(child: MyApp()),
  );
}

/// アプリのルートWidget。テーマ設定と、最初に表示する画面(ログイン画面)を決める。
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 従業員ログイン画面の動作確認用に、起点を一時的に従業員ログインへ
    // 切り替えている。従業員・企業管理者・システム管理者向けのロール選択画面
    // (RoleSelectScreen)が実装できたら、そちらを起点に戻す。
    final employeeRepositories = ref.watch(employeeRepositoriesProvider);

    return MaterialApp(
      title: 'TimeFace',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.bodyBg,
      ),
      home: LoginScreen(repositories: employeeRepositories),
    );
  }
}
