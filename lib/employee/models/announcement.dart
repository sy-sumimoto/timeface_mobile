/// 会社からのお知らせ1件分。
///
/// 一覧(`GET /api/mobile/announcements`)のレスポンスには本文(body)が含まれず、
/// 詳細(`GET /api/mobile/announcements/{id}`)取得時のみ埋まる。
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.date,
    required this.body,
    this.isNew = false,
  });

  final String id;
  final String title;
  final String date;
  final String body;
  final bool isNew;
}

/// お知らせ一覧の1ページ分。`GET /api/mobile/announcements?page=` の
/// `items` と `pagination`(1ページ10件)に対応する。
typedef AnnouncementPage = ({
  List<Announcement> items,
  int currentPage,
  int lastPage,
});
