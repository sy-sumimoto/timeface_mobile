import 'package:flutter/material.dart';

/// アプリ全体の配色定義。HTMLモック(TimeFace2の管理画面デザイン)の
/// カラーパレットを踏襲している。
class AppColors {
  AppColors._();

  static const primary = Color(0xFF4568D6);
  static const primaryHover = Color(0xFF37549F);
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF5645BB), Color(0xFF4568D6)],
  );
  static const sidebarBg = Color(0xFF101A2C);
  static const bodyBg = Color(0xFFF5F6F8);

  static const textBase = Color(0xFF111827);
  static const textMuted = Color(0xFF6B7280);
  static const textSubtle = Color(0xFF9AA0AE);
  static const border = Color(0xFFE5E7EB);

  static const badgeActiveBg = Color(0xFFE3F8EC);
  static const badgeActiveText = Color(0xFF0F7A4A);
  static const badgeWarningBg = Color(0xFFFEF0C7);
  static const badgeWarningText = Color(0xFFB45309);
  static const badgeDangerBg = Color(0xFFFEF2F2);
  static const badgeDangerText = Color(0xFFDC2626);
  static const badgeNeutralBg = Color(0xFFF1F2F4);
  static const badgeAccentBg = Color(0xFFE6E9FB);

  static const kpiIconBlueBg = Color(0xFFE6E9FB);
  static const kpiIconOrangeBg = Color(0xFFFEF0C7);
  static const kpiIconGreenBg = Color(0xFFE3F8EC);
  static const kpiIconPurpleBg = Color(0xFFF1ECFB);
  static const kpiIconPurpleFg = Color(0xFF8A5CC7);
}
