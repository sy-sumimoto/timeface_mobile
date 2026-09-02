import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum KpiIconColor { blue, orange, green, purple }

/// マイページ・勤怠・有給休暇タブで使う、指標1件分のカード
/// (アイコン・値・補足テキストのセット)。
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.delta,
    required this.icon,
    required this.iconColor,
    this.onTap,
    this.compact = false,
    this.dense = false,
  });

  final String label;
  final String value;
  final String delta;
  final IconData icon;
  final KpiIconColor iconColor;
  final VoidCallback? onTap;

  /// 3枚以上を横並びの狭いグリッドに詰め込む場合向けの、一回り小さい見た目。
  final bool compact;

  /// 4枚以上を横並びにする等、[compact]よりさらに縦を詰めたい場合向け。
  /// (`compact: true`と併用する)
  final bool dense;

  Color get _iconBg {
    switch (iconColor) {
      case KpiIconColor.blue:
        return AppColors.kpiIconBlueBg;
      case KpiIconColor.orange:
        return AppColors.kpiIconOrangeBg;
      case KpiIconColor.green:
        return AppColors.kpiIconGreenBg;
      case KpiIconColor.purple:
        return AppColors.kpiIconPurpleBg;
    }
  }

  Color get _iconFg {
    switch (iconColor) {
      case KpiIconColor.blue:
        return AppColors.primary;
      case KpiIconColor.orange:
        return AppColors.badgeWarningText;
      case KpiIconColor.green:
        return AppColors.badgeActiveText;
      case KpiIconColor.purple:
        return AppColors.kpiIconPurpleFg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.all(dense ? 10 : (compact ? 8 : 14)),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: dense ? 9 : (compact ? 10 : 11.5),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  Container(
                    width: dense ? 16 : (compact ? 20 : 24),
                    height: dense ? 16 : (compact ? 20 : 24),
                    decoration: BoxDecoration(
                      color: _iconBg,
                      borderRadius: BorderRadius.circular(dense ? 5 : 7),
                    ),
                    child: Icon(
                      icon,
                      size: dense ? 9 : (compact ? 11 : 13),
                      color: _iconFg,
                    ),
                  ),
                ],
              ),
              SizedBox(height: dense ? 5 : (compact ? 5 : 8)),
              Text(
                value,
                style: TextStyle(
                  fontSize: dense ? 13 : (compact ? 15 : 17),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: dense ? 4 : (compact ? 4 : 6)),
              Text(
                delta,
                style: TextStyle(
                  fontSize: dense ? 9 : (compact ? 10 : 11),
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
