import 'package:flutter_test/flutter_test.dart';
import 'package:timeface_mobile/common/api/api_client.dart';
import 'package:timeface_mobile/employee/repositories/http_announcement_repository.dart';

/// GET /api/mobile/announcements の `page` クエリ + `pagination` の取り込みを検証する。

Map<String, dynamic> _item(int id) => {
      'id': id,
      'title': 'お知らせ$id',
      'postedAtLabel': '2026-08-${id.toString().padLeft(2, '0')}',
      'isNew': id == 1,
    };

void main() {
  test('fetchPage は page クエリ付きで叩き、items と pagination を返す', () async {
    final api = _FakeApiClient({
      'items': [_item(1), _item(2), _item(3)],
      'pagination': {
        'currentPage': 1,
        'lastPage': 3,
        'perPage': 10,
        'total': 25,
      },
    });
    final repo = HttpAnnouncementRepository(client: api);

    final page = await repo.fetchPage(1);

    expect(api.getPaths, ['/announcements?page=1']);
    expect(page.items.map((e) => e.id), ['1', '2', '3']);
    expect(page.items.first.isNew, isTrue);
    expect(page.currentPage, 1);
    expect(page.lastPage, 3);
  });

  test('2ページ目は page=2 で叩く', () async {
    final api = _FakeApiClient({
      'items': [_item(11)],
      'pagination': {
        'currentPage': 2,
        'lastPage': 2,
        'perPage': 10,
        'total': 11,
      },
    });
    final repo = HttpAnnouncementRepository(client: api);

    final page = await repo.fetchPage(2);

    expect(api.getPaths, ['/announcements?page=2']);
    expect(page.currentPage, 2);
    expect(page.lastPage, 2);
  });

  test('fetchDetail は page クエリを付けない', () async {
    final api = _FakeApiClient({
      'announcement': {
        'id': 5,
        'title': '本文つき',
        'postedAtLabel': '2026-08-27',
        'message': '本文です',
        'isNew': false,
      },
    });
    final repo = HttpAnnouncementRepository(client: api);

    final a = await repo.fetchDetail('5');

    expect(api.getPaths, ['/announcements/5']);
    expect(a.body, '本文です');
  });
}

class _FakeApiClient extends ApiClient {
  _FakeApiClient(this.response) : super(baseUrl: 'http://test.local/api/mobile');

  final Map<String, dynamic> response;
  final List<String> getPaths = [];

  @override
  Future<Map<String, dynamic>> get(String path) async {
    getPaths.add(path);
    return response;
  }
}
