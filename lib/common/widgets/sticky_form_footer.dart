import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'accent_button.dart';

/// 申請フォーム画面下部に固定表示する「送信」ボタン+「キャンセル」リンク。
class StickyFormFooter extends StatelessWidget {
  const StickyFormFooter({
    super.key,
    required this.buttonLabel,
    required this.linkLabel,
    this.onSubmit,
    this.onCancel,
  });

  final String buttonLabel;
  final String linkLabel;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AccentButton(label: buttonLabel, onPressed: onSubmit, expand: true),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                  child: Text(linkLabel, style: const TextStyle(fontSize: 12.5, color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
