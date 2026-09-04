import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeface_mobile/employee/models/announcement.dart';
import 'package:timeface_mobile/employee/repositories/announcement_repository.dart';
import 'package:timeface_mobile/employee/screens/announcements_screen.dart';

/// お知らせ一覧の無限スクロール（page + pagination）を検証する。

class _FakeAnnouncementRepository implements AnnouncementRepository {
  _FakeAnnouncementRepository(this.pages);

  /// page 番号(1始まり) -> そのページの items
  final Map<int, List<Announcement>> pages;
  final List<int> fetchedPages = [];

  int get _lastPage => pages.keys.isEmpty ? 1 : pages.keys.reduce((a, b) => a > b ? a : b);

  @override
  Future<AnnouncementPage> fetchPage(int page) async {
    fetchedPages.add(page);
    return (
      items: pages[page] ?? const <Announcement>[],
      currentPage: page,
      lastPage: _lastPage,
    );
  }

  @override
  Future<Announcement> fetchDetail(String id) async =>
      pages.values.expand((e) => e).firstWhere((e) => e.id == id);
}

Announcement _a(int id) => Announcement(
      id: '$id',
      title: 'お知らせ$id',
      date: '2026-08-${id.toString().padLeft(2, '0')}',
      body: '',
      isNew: false,
    );

Future<_FakeAnnouncementRepository> _pump(
  WidgetTester tester,
  Map<int, List<Announcement>> pages,
) async {
  final repo = _FakeAnnouncementRepository(pages);
  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: AnnouncementsScreen(repository: repo))),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  testWidgets('1ページ目を表示する', (tester) async {
    final repo = await _pump(tester, {
      1: [_a(1), _a(2), _a(3)],
    });

    expect(repo.fetchedPages, [1]);
    expect(find.text('お知らせ1'), findsOneWidget);
    expect(find.text('お知らせ3'), findsOneWidget);
    expect(find.text('会社から届いたお知らせの一覧です'), findsOneWidget);
  });

  testWidgets('末尾までスクロールすると次ページを読み足す', (tester) async {
    final repo = await _pump(tester, {
      1: List.generate(10, (i) => _a(i + 1)),
      2: [_a(11), _a(12)],
    });

    expect(repo.fetchedPages, [1]);
    expect(find.text('お知らせ11'), findsNothing);

    // 末尾までスクロール → 次ページ取得
    await tester.drag(find.byType(Scrollable), const Offset(0, -4000));
    await tester.pumpAndSettle();
    expect(repo.fetchedPages, [1, 2]);

    // 追加ぶんが見える位置までさらにスクロール
    await tester.drag(find.byType(Scrollable), const Offset(0, -4000));
    await tester.pumpAndSettle();
    expect(find.text('お知らせ11'), findsOneWidget);
    expect(find.text('お知らせ12'), findsOneWidget);
  });

  testWidgets('最終ページに達したらそれ以上読み足さない', (tester) async {
    final repo = await _pump(tester, {
      1: List.generate(5, (i) => _a(i + 1)), // lastPage=1
    });

    await tester.drag(find.byType(Scrollable), const Offset(0, -4000));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable), const Offset(0, -4000));
    await tester.pumpAndSettle();

    expect(repo.fetchedPages, [1]);
  });
}
