import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// フォーム入力欄の上に置くラベル(必須項目には赤い"*"を付ける)。
class AppLabel extends StatelessWidget {
  const AppLabel({super.key, required this.text, this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textMuted),
          children: [
            TextSpan(text: text),
            if (required) const TextSpan(text: ' *', style: TextStyle(color: Color(0xFFDC2626))),
          ],
        ),
      ),
    );
  }
}

/// フォーム全体で共通の入力欄デザイン(角丸・枠線・フォーカス時の強調)。
InputDecoration appInputDecoration({String? hintText}) {
  return InputDecoration(
    hintText: hintText,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
  );
}

/// 日付選択などピッカー連携が前提のフィールドを、非活性な見た目だけの箱として表示する。
/// 実際のタップ時の挙動(showDatePicker呼び出し等)は呼び出し側で実装する。
class AppMockField extends StatelessWidget {
  const AppMockField({super.key, this.text, this.hint, this.onTap});

  final String? text;
  final String? hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          text ?? hint ?? '',
          style: TextStyle(fontSize: 14, color: text != null ? AppColors.textBase : AppColors.textSubtle),
        ),
      ),
    );
  }
}
