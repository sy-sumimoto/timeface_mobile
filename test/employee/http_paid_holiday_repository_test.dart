import 'package:flutter_test/flutter_test.dart';
import 'package:timeface_mobile/common/api/api_client.dart';
import 'package:timeface_mobile/employee/repositories/http_paid_holiday_repository.dart';

/// GET /api/mobile/paid-holidays/balance の未使用だったレスポンス項目
/// (前期/今期内訳・失効間近アラート)の取り込みを検証する。

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
}

class _FakeApiClient extends ApiClient {
  _FakeApiClient(this.response) : super(baseUrl: 'http://test.local/api/mobile');

  final Map<String, dynamic> response;
  String? lastPath;

  @override
  Future<Map<String, dynamic>> get(String path) async {
    lastPath = path;
    return response;
  }
}
