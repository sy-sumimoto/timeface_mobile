import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// [AppShell]共通のAppBar。タブ名の表示と、右上アイコンからの
/// ユーザー情報表示・ログアウト操作を担う。
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    required this.userInitial,
    required this.userName,
    required this.userEmail,
    this.onLogout,
  });

  final String title;
  final String userInitial;
  final String userName;
  final String userEmail;
  final VoidCallback? onLogout;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            PopupMenuButton<String>(
              offset: const Offset(0, 46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
              onSelected: (value) {
                if (value == 'logout') onLogout?.call();
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textBase)),
                      const SizedBox(height: 2),
                      Text(userEmail, style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('ログアウト', style: TextStyle(color: Color(0xFFDC2626), fontSize: 13)),
                ),
              ],
              child: CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.primary,
                child: Text(userInitial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
