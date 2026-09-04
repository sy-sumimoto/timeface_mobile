import '../models/announcement.dart';

/// お知らせ一覧・詳細の取得口。
abstract class AnnouncementRepository {
  /// 公開中のお知らせを指定ページ分だけ取得する(1ページ10件・本文(body)は含まれない)。
  /// 戻り値の [AnnouncementPage.currentPage] / [AnnouncementPage.lastPage] で
  /// 続きのページがあるか判定できる。
  Future<AnnouncementPage> fetchPage(int page);

  /// お知らせ詳細を取得する。取得と同時にサーバー側で既読になる。
  Future<Announcement> fetchDetail(String id);
}

/// 固定のお知らせを返すモック実装。1ページ10件でページングする。
class MockAnnouncementRepository implements AnnouncementRepository {
  static const int _perPage = 10;

  final List<Announcement> _items = const [
    Announcement(
      id: 'a1',
      title: '夏季休業期間のお知らせ',
      date: '2026-08-05',
      isNew: true,
      body: '平素より TimeFace をご利用いただきありがとうございます。\n'
          '下記の期間を夏季休業とさせていただきます。休業期間中の勤怠打刻・お問い合わせ対応は休止いたします。\n\n'
          '休業期間: 2026年8月13日(木) 〜 8月16日(日)\n\n'
          'ご不便をおかけしますが、何卒よろしくお願いいたします。',
    ),
    Announcement(
      id: 'a2',
      title: '健康診断の実施について(10月)',
      date: '2026-08-20',
      body: '本年度の定期健康診断を下記日程で実施します。対象者には別途、受診票を配布しますので、\n'
          '期日までに必要事項を記入のうえ、人事部までご提出ください。\n\n'
          '実施予定: 2026年10月中(部署ごとに日程調整)\n\n'
          'ご不明な点があれば人事部までお問い合わせください。',
    ),
  ];

  int get _lastPage => (_items.length / _perPage).ceil().clamp(1, 1 << 30);

  @override
  Future<AnnouncementPage> fetchPage(int page) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final start = (page - 1) * _perPage;
    final items = start >= _items.length
        ? const <Announcement>[]
        : _items.sublist(start, (start + _perPage).clamp(0, _items.length));
    return (items: items, currentPage: page, lastPage: _lastPage);
  }

  @override
  Future<Announcement> fetchDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _items.firstWhere((e) => e.id == id, orElse: () => _items.first);
  }
}
