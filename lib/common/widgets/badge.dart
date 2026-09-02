import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// バッジの配色パターン。呼び出し側がステータス(出勤中/承認待ち/差し戻し等)に
/// 応じて選ぶ(例: [PaidHolidaysScreen._statusVariant]参照)。
enum AppBadgeVariant { neutral, active, warning, danger, accent }

/// 状態ラベルを表示する小さな丸型バッジ。
class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.text, this.variant = AppBadgeVariant.neutral});

  final String text;
  final AppBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    switch (variant) {
      case AppBadgeVariant.active:
        bg = AppColors.badgeActiveBg;
        fg = AppColors.badgeActiveText;
        break;
      case AppBadgeVariant.warning:
        bg = AppColors.badgeWarningBg;
        fg = AppColors.badgeWarningText;
        break;
      case AppBadgeVariant.danger:
        bg = AppColors.badgeDangerBg;
        fg = AppColors.badgeDangerText;
        break;
      case AppBadgeVariant.accent:
        bg = AppColors.badgeAccentBg;
        fg = AppColors.primary;
        break;
      case AppBadgeVariant.neutral:
        bg = AppColors.badgeNeutralBg;
        fg = AppColors.textMuted;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
