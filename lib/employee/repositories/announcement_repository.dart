import '../models/announcement.dart';

/// お知らせ一覧・詳細の取得口。
abstract class AnnouncementRepository {
  /// 公開中のお知らせ一覧を取得する(1ページ目のみ。本文(body)は含まれない)。
  Future<List<Announcement>> fetchAll();

  /// お知らせ詳細を取得する。取得と同時にサーバー側で既読になる。
  Future<Announcement> fetchDetail(String id);
}

/// 固定のお知らせ2件を返すモック実装。TimeFace2側にお知らせ取得APIが
/// まだ無いため、当面はこの実装のみを使う([EmployeeRepositories]参照)。
class MockAnnouncementRepository implements AnnouncementRepository {
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

  @override
  Future<List<Announcement>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _items;
  }

  @override
  Future<Announcement> fetchDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _items.firstWhere((e) => e.id == id, orElse: () => _items.first);
  }
}
