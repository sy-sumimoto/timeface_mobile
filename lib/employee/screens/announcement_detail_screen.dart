import 'package:flutter/material.dart';
import '../models/announcement.dart';
import '../repositories/announcement_repository.dart';
import '../../common/theme/app_colors.dart';
import '../../common/utils/html_text.dart';
import '../../common/widgets/app_back_bar.dart';
import '../../common/widgets/badge.dart';

/// お知らせ詳細画面。一覧タップ時点の[Announcement](本文なし)をまず表示し、
/// 詳細API(`GET /api/mobile/announcements/{id}`)を呼んで本文を取得する。
/// この取得によりサーバー側で既読になるため、一覧はこの画面から戻ったタイミングで
/// 再取得される([AnnouncementsScreen._openDetail]参照)。
class AnnouncementDetailScreen extends StatefulWidget {
  const AnnouncementDetailScreen({super.key, required this.repository, required this.announcement});

  final AnnouncementRepository repository;
  final Announcement announcement;

  @override
  State<AnnouncementDetailScreen> createState() => _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  late Announcement _announcement = widget.announcement;
  bool _loadingBody = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final detail = await widget.repository.fetchDetail(widget.announcement.id);
    if (!mounted) return;
    setState(() {
      _announcement = detail;
      _loadingBody = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bodyBg,
      appBar: AppBackBar(title: 'お知らせ', onBack: () => Navigator.of(context).pop()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(_announcement.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                ),
                if (_announcement.isNew) ...[
                  const SizedBox(width: 8),
                  const AppBadge(text: 'NEW', variant: AppBadgeVariant.accent),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Text('投稿日: ${_announcement.date}', style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
            const SizedBox(height: 16),
            _loadingBody
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : SelectableText(
                    // message はサニタイズ済みHTML。HTMLレンダラを持たないため
                    // プレーンテキスト化して表示する。
                    htmlToPlainText(_announcement.body),
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
          ],
        ),
      ),
    );
  }
}
