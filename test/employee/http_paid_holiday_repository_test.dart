import 'package:flutter_test/flutter_test.dart';
import 'package:timeface_mobile/common/api/api_client.dart';
import 'package:timeface_mobile/employee/models/paid_holiday.dart';
import 'package:timeface_mobile/employee/repositories/http_paid_holiday_repository.dart';

/// GET /api/mobile/paid-holidays/balance の未使用だったレスポンス項目
/// (前期/今期内訳・失効間近アラート)の取り込みと、
/// GET /api/mobile/paid-holidays を1回だけ叩いて両リストを返すことを検証する。

Map<String, dynamic> _balance(Map<String, dynamic> overrides) => {
      'hireAt': '2023/4/1',
      'nextScheduledGrantedDate': null,
      'previousPeriodRemainingDays': null,
      'currentPeriodRemainingDays': '10.0',
      'totalRemainingDays': '10',
      'hasExpiringSoon': false,
      'expiringSoonDaysLabel': null,
      'expiringSoonDateLabel': null,
      ...overrides,
    };

void main() {
  test('前期/今期内訳と失効間近アラートを PaidHolidaySummary に取り込む', () async {
    final api = _FakeApiClient({
      'balance': _balance({
        'previousPeriodRemainingDays': '3.0',
        'currentPeriodRemainingDays': '5.5',
        'totalRemainingDays': '8.5',
        'hasExpiringSoon': true,
        'expiringSoonDaysLabel': '3.0日',
        'expiringSoonDateLabel': '2026/9/30',
      }),
    });
    final repo = HttpPaidHolidayRepository(client: api);

    final s = await repo.fetchSummary();

    expect(api.lastPath, '/paid-holidays/balance');
    expect(s.remainingDays, '8.5日');
    expect(s.previousPeriodDays, '3日'); // "3.0" → 末尾 .0 を落とす
    expect(s.currentPeriodDays, '5.5日');
    expect(s.hasExpiringSoon, isTrue);
    expect(s.expiringSoonDays, '3.0日');
    expect(s.expiringSoonDate, '2026/9/30');
  });

  test('前期残・失効情報が null のときは null / false のまま読める', () async {
    final api = _FakeApiClient({'balance': _balance({})});
    final repo = HttpPaidHolidayRepository(client: api);

    final s = await repo.fetchSummary();

    expect(s.previousPeriodDays, isNull);
    expect(s.currentPeriodDays, '10日'); // "10.0" → "10日"
    expect(s.hasExpiringSoon, isFalse);
    expect(s.expiringSoonDays, isNull);
    expect(s.expiringSoonDate, isNull);
  });

  test('hasExpiringSoon キー自体が無い旧レスポンスでも false になる', () async {
    final api = _FakeApiClient({
      'balance': {
        'totalRemainingDays': '10',
        'nextScheduledGrantedDate': null,
        'currentPeriodRemainingDays': null,
        'previousPeriodRemainingDays': null,
      },
    });
    final repo = HttpPaidHolidayRepository(client: api);

    final s = await repo.fetchSummary();

    expect(s.hasExpiringSoon, isFalse);
    expect(s.remainingDays, '10日');
  });

  group('fetchRequests', () {
    Map<String, dynamic> item(int id, int requestStatus) => {
          'id': id,
          'paidHolidayStartDate': '2026/8/12',
          'paidHolidayEndDate': '2026/8/13',
          'holidayType': 1,
          'usedPaidHolidays': 2,
          'requestStatus': requestStatus,
          'requestedDate': '2026/8/3',
        };

    test('GET /paid-holidays を1回だけ叩いて pending / processed 両方を返す', () async {
      final api = _FakeApiClient({
        'pending': {
          'items': [item(1, 1), item(2, 4)],
          'pagination': {'currentPage': 1, 'lastPage': 1, 'perPage': 15, 'total': 2},
        },
        'processed': {
          'items': [item(3, 2)],
          'pagination': {'currentPage': 1, 'lastPage': 1, 'perPage': 15, 'total': 1},
        },
      });
      final repo = HttpPaidHolidayRepository(client: api);

      final lists = await repo.fetchRequests();

      // 修正の要点: 同じエンドポイントを2回叩かない
      expect(api.getPaths, ['/paid-holidays']);
      expect(lists.pending.map((e) => e.id), ['1', '2']);
      expect(lists.processed.map((e) => e.id), ['3']);
      expect(lists.pending[1].status, PaidHolidayStatus.rejected); // requestStatus 4
      expect(lists.processed[0].status, PaidHolidayStatus.approved); // requestStatus 2
    });

    test('items が空でも空リストを返す', () async {
      final api = _FakeApiClient({
        'pending': {'items': <dynamic>[], 'pagination': {}},
        'processed': {'items': <dynamic>[], 'pagination': {}},
      });
      final repo = HttpPaidHolidayRepository(client: api);

      final lists = await repo.fetchRequests();

      expect(lists.pending, isEmpty);
      expect(lists.processed, isEmpty);
      expect(api.getPaths, ['/paid-holidays']);
    });
  });
}

class _FakeApiClient extends ApiClient {
  _FakeApiClient(this.response) : super(baseUrl: 'http://test.local/api/mobile');

  final Map<String, dynamic> response;
  final List<String> getPaths = [];

  String? get lastPath => getPaths.isEmpty ? null : getPaths.last;

  @override
  Future<Map<String, dynamic>> get(String path) async {
    getPaths.add(path);
    return response;
  }
}
