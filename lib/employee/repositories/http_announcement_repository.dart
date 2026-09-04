import '../../common/api/api_client.dart';
import '../models/announcement.dart';
import 'announcement_repository.dart';

/// TimeFace (`/api/mobile/announcements`)を叩く実装。
class HttpAnnouncementRepository implements AnnouncementRepository {
  HttpAnnouncementRepository({required this.client});

  final ApiClient client;

  @override
  Future<AnnouncementPage> fetchPage(int page) async {
    // AnnouncementController@index: 自社向けに公開中のお知らせ一覧。
    // `page` クエリで1ページ10件ずつ。一覧レスポンスに本文(message)は含まれない。
    final data = await client.get('/announcements?page=$page');
    final list = data['items'] as List;
    final pagination = data['pagination'] as Map<String, dynamic>;
    return (
      items: list
          .map((e) => _summaryFromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: pagination['currentPage'] as int,
      lastPage: pagination['lastPage'] as int,
    );
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
