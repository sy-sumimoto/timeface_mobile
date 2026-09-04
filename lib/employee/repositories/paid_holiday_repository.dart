import '../models/paid_holiday.dart';
import '../../common/utils/date_format.dart';

abstract class PaidHolidayRepository {
  Future<PaidHolidaySummary> fetchSummary();

  Future<List<PaidHolidayRequest>> fetchPending();

  Future<List<PaidHolidayRequest>> fetchProcessed();

  /// 開始日・休暇区分・取得日数から終了日を算出する(TimeFace2側で企業休日等を考慮して計算する)。
  /// 戻り値の文字列は改変せず、そのまま submitCreate/submitEdit の computedEndDate に渡すこと
  /// (サーバー側で改ざん検知のため突合される)。
  Future<String> calculateEndDate({
    required DateTime startDate,
    required PaidHolidayType type,
    required double usedDays,
  });

  Future<PaidHolidayRequest> submitCreate({
    required DateTime startDate,
    required String computedEndDate,
    required PaidHolidayType type,
    required double usedDays,
    String? note,
  });

  Future<PaidHolidayRequest> submitEdit({
    required String id,
    required DateTime startDate,
    required String computedEndDate,
    required PaidHolidayType type,
    required double usedDays,
    String? note,
  });
}

/// モック実装。作成・再申請はアプリ内メモリの一覧を実際に書き換えるため、
/// 一覧画面に戻ると結果が反映される。実APIに差し替える際はこのクラスだけを置き換える。
class MockPaidHolidayRepository implements PaidHolidayRepository {
  int _nextId = 4;

  final List<PaidHolidayRequest> _items = [
    PaidHolidayRequest(
      id: 'ph1',
      startDate: DateTime(2026, 8, 12),
      endDate: DateTime(2026, 8, 13),
      type: PaidHolidayType.fullDay,
      usedDays: 2,
      status: PaidHolidayStatus.pending,
      appliedDate: '2026-08-03',
    ),
    PaidHolidayRequest(
      id: 'ph2',
      startDate: DateTime(2026, 8, 15),
      endDate: DateTime(2026, 8, 15),
      type: PaidHolidayType.fullDay,
      usedDays: 1,
      status: PaidHolidayStatus.rejected,
      appliedDate: '2026-08-02',
      rejectionNote: '開始日が誤っていませんか?正しい日付で再提出してください',
    ),
    PaidHolidayRequest(
      id: 'ph3',
      startDate: DateTime(2026, 7, 28),
      endDate: DateTime(2026, 7, 28),
      type: PaidHolidayType.fullDay,
      usedDays: 1,
      status: PaidHolidayStatus.approved,
      appliedDate: '2026-07-21',
      approverInfo: '佐藤 花子(課長)',
      processedAt: '2026-07-21 10:05',
    ),
  ];

  @override
  Future<PaidHolidaySummary> fetchSummary() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const PaidHolidaySummary(
      remainingDays: '8.5日',
      plannedDays: '1.0日',
      nextGrantDate: '2027-01-15',
      previousPeriodDays: '3日',
      currentPeriodDays: '5.5日',
      hasExpiringSoon: true,
      expiringSoonDays: '3日',
      expiringSoonDate: '2026/9/30',
    );
  }

  @override
  Future<List<PaidHolidayRequest>> fetchPending() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _items.where((e) => e.status != PaidHolidayStatus.approved).toList();
  }

  @override
  Future<List<PaidHolidayRequest>> fetchProcessed() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _items.where((e) => e.status == PaidHolidayStatus.approved).toList();
  }

  @override
  Future<String> calculateEndDate({
    required DateTime startDate,
    required PaidHolidayType type,
    required double usedDays,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final endDate = startDate.add(Duration(days: usedDays.ceil() - 1));
    return formatSlashDate(endDate);
  }

  @override
  Future<PaidHolidayRequest> submitCreate({
    required DateTime startDate,
    required String computedEndDate,
    required PaidHolidayType type,
    required double usedDays,
    String? note,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final request = PaidHolidayRequest(
      id: 'ph${_nextId++}',
      startDate: startDate,
      endDate: parseSlashDate(computedEndDate),
      type: type,
      usedDays: usedDays,
      status: PaidHolidayStatus.pending,
      appliedDate: formatIsoDate(DateTime.now()),
      note: note,
    );
    _items.insert(0, request);
    return request;
  }

  @override
  Future<PaidHolidayRequest> submitEdit({
    required String id,
    required DateTime startDate,
    required String computedEndDate,
    required PaidHolidayType type,
    required double usedDays,
    String? note,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _items.indexWhere((e) => e.id == id);
    final updated = _items[index].copyWith(
      startDate: startDate,
      endDate: parseSlashDate(computedEndDate),
      type: type,
      usedDays: usedDays,
      note: note,
      status: PaidHolidayStatus.pending,
      appliedDate: formatIsoDate(DateTime.now()),
      rejectionNote: null,
    );
    _items[index] = updated;
    return updated;
  }
}
