import 'package:flutter/material.dart';

import '../../common/theme/app_colors.dart';
import '../../common/widgets/badge.dart';

/// お知らせ一覧・マイページで使う、お知らせ1件分のカード表示。
class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.title,
    required this.date,
    this.isNew = false,
    this.onTap,
    this.flat = false,
  });

  final String title;
  final String date;
  final bool isNew;
  final VoidCallback? onTap;

  /// お知らせ一覧のように何件も連続で並べる場合向けの、枠なし+下線区切りの見た目。
  /// falseの場合は従来通り白背景・ボーダー・角丸の「カード」として表示する。
  final bool flat;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isNew) ...[
              const AppBadge(text: 'NEW', variant: AppBadgeVariant.accent),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF14151A),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          date,
          style: const TextStyle(fontSize: 12, color: AppColors.textSubtle),
        ),
      ],
    );

    if (flat) {
      return InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: content,
        ),
      );
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: content,
        ),
      ),
    );
  }
}
