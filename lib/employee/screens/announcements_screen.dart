import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../repositories/announcement_repository.dart';
import '../../common/theme/app_colors.dart';
import '../widgets/announcement_card.dart';
import 'announcement_detail_screen.dart';

/// お知らせタブ。一覧をタップすると[AnnouncementDetailScreen]に遷移する。
/// 一覧は `GET /api/mobile/announcements?page=`(1ページ10件)を、
/// 末尾までスクロールするたびに次ページを読み足す。
///
/// プッシュ通知が無いため、[isActive]がfalse→trueになったとき(このタブを選び直した)と、
/// アプリがフォアグラウンドに復帰したときに1ページ目を取り直して最新化する。
class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({
    super.key,
    required this.repository,
    this.onListRefreshed,
    this.isActive = true,
  });

  final AnnouncementRepository repository;

  /// 1ページ目の取得が完了するたびに呼ばれる(初回・詳細から戻った直後・再取得時)。
  /// 親(EmployeeShell)が未読バッジを取り直すために使う。
  final VoidCallback? onListRefreshed;

  /// このタブが現在選択され画面に表示されているか。
  /// EmployeeShellはIndexedStackで全タブを一括生成するため、falseからtrueに
  /// 変わった(=このタブが選び直された)タイミングで1ページ目を取り直す。
  final bool isActive;

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen>
    with WidgetsBindingObserver {
  final _scrollController = ScrollController();
  final List<Announcement> _items = [];
  int _currentPage = 0;
  int _lastPage = 1;
  bool _initialLoaded = false;
  bool _loadingMore = false;
  bool _reloading = false;

  bool get _hasMore => _currentPage < _lastPage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    _loadFirst();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnnouncementsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // お知らせタブが選び直されたら最新化する
    if (widget.isActive && !oldWidget.isActive) {
      _loadFirst();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // お知らせタブを表示したままフォアグラウンド復帰したら最新化する
    if (state == AppLifecycleState.resumed && widget.isActive && _initialLoaded) {
      _loadFirst();
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  /// 1ページ目を取得する（初回・詳細から戻ったとき・タブ再選択/復帰時のリフレッシュ）。
  /// 多重呼び出し(タブ切替とライフサイクルが重なる等)は先着1件だけ実行する。
  Future<void> _loadFirst() async {
    if (_reloading) return;
    _reloading = true;
    try {
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
      widget.onListRefreshed?.call();
    } finally {
      _reloading = false;
    }
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
