import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeface_mobile/employee/models/announcement.dart';
import 'package:timeface_mobile/employee/repositories/announcement_repository.dart';
import 'package:timeface_mobile/employee/screens/announcement_detail_screen.dart';

/// 詳細画面が message(サニタイズ済みHTML)をプレーンテキスト化して表示することを検証する。

class _FakeAnnouncementRepository implements AnnouncementRepository {
  _FakeAnnouncementRepository(this.detail);

  final Announcement detail;

  @override
  Future<Announcement> fetchDetail(String id) async => detail;

  @override
  Future<AnnouncementPage> fetchPage(int page) async =>
      (items: const <Announcement>[], currentPage: page, lastPage: 1);
}

void main() {
  testWidgets('本文の HTML タグは表示されず、プレーンテキストで描画される', (tester) async {
    final repo = _FakeAnnouncementRepository(
      const Announcement(
        id: '1',
        title: 'テスト',
        date: '2026-08-27',
        body: '<p>1行目です。</p><p>2行目です。&amp; 記号もOK</p>',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AnnouncementDetailScreen(
          repository: repo,
          announcement: const Announcement(
            id: '1',
            title: 'テスト',
            date: '2026-08-27',
            body: '',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 生タグは出ない
    expect(find.textContaining('<p>'), findsNothing);
    // プレーンテキスト化された本文が出る
    expect(
      find.text('1行目です。\n\n2行目です。& 記号もOK'),
      findsOneWidget,
    );
  });
}
