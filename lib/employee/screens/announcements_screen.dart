import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../repositories/announcement_repository.dart';
import '../../common/theme/app_colors.dart';
import '../widgets/announcement_card.dart';
import 'announcement_detail_screen.dart';

/// お知らせタブ。一覧をタップすると[AnnouncementDetailScreen]に遷移する。
/// 一覧は `GET /api/mobile/announcements?page=`(1ページ10件)を、
/// 末尾までスクロールするたびに次ページを読み足す。
class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key, required this.repository});

  final AnnouncementRepository repository;

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final _scrollController = ScrollController();
  final List<Announcement> _items = [];
  int _currentPage = 0;
  int _lastPage = 1;
  bool _initialLoaded = false;
  bool _loadingMore = false;

  bool get _hasMore => _currentPage < _lastPage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFirst();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  /// 1ページ目を取得する（初回・詳細から戻ったときのリフレッシュ）。
  Future<void> _loadFirst() async {
    final page = await widget.repository.fetchPage(1);
    if (!mounted) return;
    setState(() {
      _items
        ..clear()
        ..addAll(page.items);
      _currentPage = page.currentPage;
      _lastPage = page.lastPage;
      _initialLoaded = true;
    });
  }

  /// 続きのページがあれば読み足す。
  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final page = await widget.repository.fetchPage(_currentPage + 1);
      if (!mounted) return;
      setState(() {
        _items.addAll(page.items);
        _currentPage = page.currentPage;
        _lastPage = page.lastPage;
      });
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  /// 詳細画面は開いた時点でサーバー側の既読状態が変わるため、
  /// 戻ってきたら1ページ目から取り直してNEWバッジを最新化する。
  Future<void> _openDetail(Announcement announcement) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnnouncementDetailScreen(
          repository: widget.repository,
          announcement: announcement,
        ),
      ),
    );
    _loadFirst();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      itemCount: _items.length + 2, // ヘッダー + フッター
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              '会社から届いたお知らせの一覧です',
              style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
            ),
          );
        }
        if (index == _items.length + 1) {
          if (_loadingMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (_items.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'お知らせはありません',
                  style: TextStyle(fontSize: 13.5, color: AppColors.textSubtle),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }
        final item = _items[index - 1];
        return AnnouncementCard(
          title: item.title,
          date: item.date,
          isNew: item.isNew,
          onTap: () => _openDetail(item),
          flat: true,
        );
      },
    );
  }
}
