import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 選択状態を表示するだけの静的なラジオボタン。
/// 実際の選択切り替えは呼び出し側の状態管理で実装する。
class AppRadioOption extends StatelessWidget {
  const AppRadioOption({super.key, required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioGroup<bool>(
            groupValue: selected ? true : null,
            onChanged: (_) {},
            child: const Radio<bool>(
              value: true,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 2),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
