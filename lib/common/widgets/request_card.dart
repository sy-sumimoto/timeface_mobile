import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'badge.dart';

/// 有給休暇申請一覧の1件分のカード。ステータスバッジ・付帯情報(申請日/承認者等)・
/// 差し戻し理由・再申請ボタンをまとめて表示する(不要な部分はnullで省略可能)。
class RequestCard extends StatelessWidget {
  const RequestCard({
    super.key,
    required this.period,
    required this.type,
    required this.days,
    required this.statusLabel,
    required this.statusVariant,
    required this.metaLines,
    this.noteText,
    this.footerActionLabel,
    this.onFooterActionTap,
    this.trailingActionLabel,
    this.onTrailingActionTap,
  });

  final String period;
  final String type;
  final String days;
  final String statusLabel;
  final AppBadgeVariant statusVariant;
  final List<String> metaLines;
  final String? noteText;

  /// 控えめな枠線ボタン(例: 修正して再申請、差し戻す)。
  final String? footerActionLabel;
  final VoidCallback? onFooterActionTap;

  /// 強調表示のプライマリボタン(例: 承認する)。footerActionLabelと併用すると
  /// 左に控えめボタン・右に強調ボタンが並ぶ(承認/差し戻しの2択操作を想定)。
  final String? trailingActionLabel;
  final VoidCallback? onTrailingActionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(period, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(type, style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(days, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppBadge(text: statusLabel, variant: statusVariant),
              ...metaLines.map((m) => Text(m, style: const TextStyle(fontSize: 12.5, color: AppColors.textSubtle))),
            ],
          ),
          if (noteText != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: AppColors.badgeDangerBg, borderRadius: BorderRadius.circular(10)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 16, color: Color(0xFFB42318)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(noteText!, style: const TextStyle(fontSize: 12.5, color: Color(0xFFB42318), height: 1.5)),
                  ),
                ],
              ),
            ),
          ],
          if (footerActionLabel != null || trailingActionLabel != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (footerActionLabel != null)
                  OutlinedButton(
                    onPressed: onFooterActionTap,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                    ),
                    child: Text(footerActionLabel!, style: const TextStyle(fontSize: 12.5, color: Color(0xFF374151), fontWeight: FontWeight.w600)),
                  ),
                if (footerActionLabel != null && trailingActionLabel != null) const SizedBox(width: 8),
                if (trailingActionLabel != null)
                  ElevatedButton(
                    onPressed: onTrailingActionTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                    ),
                    child: Text(trailingActionLabel!, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
