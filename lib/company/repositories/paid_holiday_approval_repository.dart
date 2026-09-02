import '../models/paid_holiday_approval.dart';

/// 有給休暇申請の承認・差し戻しの取得口。TimeFace2の
/// `Company\PaidHolidayRequestController` に対応する
/// (Web版は承認自体を別画面(勤怠入力側)で行うが、モバイル版では一覧から直接操作する)。
abstract class PaidHolidayApprovalRepository {
  Future<List<PaidHolidayApproval>> fetchPending();

  Future<List<PaidHolidayApproval>> fetchProcessed();

  Future<PaidHolidayApproval> approve(String id);

  Future<PaidHolidayApproval> reject(String id, {required String note});
}

/// モック実装。承認/差し戻しでインメモリの一覧を直接書き換える。
class MockPaidHolidayApprovalRepository implements PaidHolidayApprovalRepository {
  final List<PaidHolidayApproval> _items = [
    const PaidHolidayApproval(
      id: 'a1',
      employeeName: '中村 陽子',
      periodLabel: '2026-08-12〜2026-08-13',
      typeLabel: '全休',
      daysLabel: '2日',
      appliedDate: '2026-08-03',
      status: PaidHolidayApprovalStatus.pending,
    ),
    const PaidHolidayApproval(
      id: 'a2',
      employeeName: '佐藤 花子',
      periodLabel: '2026-08-20',
      typeLabel: '半休',
      daysLabel: '0.5日',
      appliedDate: '2026-08-10',
      status: PaidHolidayApprovalStatus.pending,
    ),
    const PaidHolidayApproval(
      id: 'a3',
      employeeName: '鈴木 一郎',
      periodLabel: '2026-07-28',
      typeLabel: '全休',
      daysLabel: '1日',
      appliedDate: '2026-07-21',
      status: PaidHolidayApprovalStatus.approved,
    ),
  ];

  @override
  Future<List<PaidHolidayApproval>> fetchPending() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _items.where((e) => e.status == PaidHolidayApprovalStatus.pending).toList();
  }

  @override
  Future<List<PaidHolidayApproval>> fetchProcessed() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _items.where((e) => e.status != PaidHolidayApprovalStatus.pending).toList();
  }

  @override
  Future<PaidHolidayApproval> approve(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _items.indexWhere((e) => e.id == id);
    final updated = _items[index].copyWith(status: PaidHolidayApprovalStatus.approved);
    _items[index] = updated;
    return updated;
  }

  @override
  Future<PaidHolidayApproval> reject(String id, {required String note}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _items.indexWhere((e) => e.id == id);
    final updated = _items[index].copyWith(status: PaidHolidayApprovalStatus.rejected, note: note);
    _items[index] = updated;
    return updated;
  }
}
