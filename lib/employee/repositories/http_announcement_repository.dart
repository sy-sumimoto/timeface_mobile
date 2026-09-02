import '../../common/api/api_client.dart';
import '../models/announcement.dart';
import 'announcement_repository.dart';

/// TimeFace2 (`/api/mobile/announcements`)を叩く実装。
class HttpAnnouncementRepository implements AnnouncementRepository {
  HttpAnnouncementRepository({required this.client});

  final ApiClient client;

  @override
  Future<List<Announcement>> fetchAll() async {
    // AnnouncementController@index: 自社向けに公開中のお知らせ一覧(1ページ目)。
    // 一覧レスポンスに本文(message)は含まれない。
    final data = await client.get('/announcements');
    final list = data['items'] as List;
    return list.map((e) => _summaryFromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Announcement> fetchDetail(String id) async {
    // AnnouncementController@show: 取得と同時にサーバー側で既読になる
    final data = await client.get('/announcements/$id');
    return _detailFromJson(data['announcement'] as Map<String, dynamic>);
  }

  Announcement _summaryFromJson(Map<String, dynamic> item) {
    return Announcement(
      id: item['id'].toString(),
      title: item['title'] as String,
      date: item['postedAtLabel'] as String,
      body: '',
      isNew: item['isNew'] as bool,
    );
  }

  Announcement _detailFromJson(Map<String, dynamic> item) {
    return Announcement(
      id: item['id'].toString(),
      title: item['title'] as String,
      date: item['postedAtLabel'] as String,
      body: item['message'] as String? ?? '',
      isNew: item['isNew'] as bool,
    );
  }
}
