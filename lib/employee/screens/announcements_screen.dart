import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../repositories/announcement_repository.dart';
import '../../common/theme/app_colors.dart';
import '../widgets/announcement_card.dart';
import 'announcement_detail_screen.dart';

/// お知らせタブ。一覧をタップすると[AnnouncementDetailScreen]に遷移する。
class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key, required this.repository});

  final AnnouncementRepository repository;

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  List<Announcement>? _items;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await widget.repository.fetchAll();
    if (!mounted) return;
    setState(() => _items = items);
  }

  /// 詳細画面は開いた時点でサーバー側の既読状態が変わるため、
  /// 戻ってきたら一覧を再取得してNEWバッジを最新化する。
  Future<void> _openDetail(Announcement announcement) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnnouncementDetailScreen(
          repository: widget.repository,
          announcement: announcement,
        ),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (items == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '会社から届いたお知らせの一覧です',
            style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          for (final item in items)
            AnnouncementCard(
              title: item.title,
              date: item.date,
              isNew: item.isNew,
              onTap: () => _openDetail(item),
              flat: true,
            ),
        ],
      ),
    );
  }
}
