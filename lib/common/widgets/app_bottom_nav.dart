import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// [AppBottomNav]の1タブ分(アイコン+ラベル)。各ロールのShellがタブ構成を決める。
class AppBottomNavItem {
  const AppBottomNavItem({
    required this.icon,
    required this.label,
    this.badgeCount = 0,
  });
  final IconData icon;
  final String label;

  /// アイコン右上に出す未読バッジの件数。0 のときはバッジを表示しない。
  final int badgeCount;
}

/// ロール共通の下部タブナビゲーション。表示するタブ(items)は呼び出し側
/// (EmployeeShell/CompanyShell/AdminShell)が渡す(5タブ固定だったものを汎用化)。
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.items, required this.currentIndex, this.onTap});

  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.sidebarBg,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = index == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap?.call(index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _IconWithBadge(
                          icon: item.icon,
                          isActive: isActive,
                          badgeCount: item.badgeCount,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: isActive ? 1 : 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// タブアイコンに未読バッジ(赤丸+件数)を重ねる。件数が0のときはアイコンのみ。
class _IconWithBadge extends StatelessWidget {
  const _IconWithBadge({
    required this.icon,
    required this.isActive,
    required this.badgeCount,
  });

  final IconData icon;
  final bool isActive;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      size: 22,
      color: Colors.white.withValues(alpha: isActive ? 1 : 0.65),
    );
    if (badgeCount <= 0) return iconWidget;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        iconWidget,
        Positioned(
          right: -6,
          top: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            constraints: const BoxConstraints(minWidth: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.sidebarBg, width: 1.5),
            ),
            child: Text(
              badgeCount > 9 ? '9+' : '$badgeCount',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
