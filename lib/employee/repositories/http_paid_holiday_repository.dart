import '../../common/api/api_client.dart';
import '../models/paid_holiday.dart';
import '../../common/utils/date_format.dart';
import 'paid_holiday_repository.dart';

/// TimeFace2 (`/api/mobile/paid-holidays` 系)を叩く実装。
class HttpPaidHolidayRepository implements PaidHolidayRepository {
  HttpPaidHolidayRepository({required this.client});

  final ApiClient client;

  @override
  Future<PaidHolidaySummary> fetchSummary() async {
    final data = await client.get('/paid-holidays/balance');
    return _summaryFrom(data['balance'] as Map<String, dynamic>);
  }

  @override
  Future<List<PaidHolidayRequest>> fetchPending() async {
    // GET /paid-holidays は pending/processed を1回のレスポンスで両方返すが、
    // fetchPending/fetchProcessedが独立して呼ばれる既存のインターフェースに
    // 合わせているため、ここでは pending 側だけを使う(2回叩くことになる点は許容)。
    final data = await client.get('/paid-holidays');
    final items = (data['pending'] as Map<String, dynamic>)['items'] as List;
    return items.map((e) => _requestFrom(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<PaidHolidayRequest>> fetchProcessed() async {
    final data = await client.get('/paid-holidays');
    final items = (data['processed'] as Map<String, dynamic>)['items'] as List;
    return items.map((e) => _requestFrom(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<String> calculateEndDate({
    required DateTime startDate,
    required PaidHolidayType type,
    required double usedDays,
  }) async {
    // PaidHolidayController@calculateEndDate: 会社休日等を考慮した終了日をサーバー側で算出
    final data = await client.post('/paid-holidays/calculate-end-date', {
      'holiday_type': type == PaidHolidayType.fullDay ? 1 : 2,
      'paid_holiday_start_date': formatSlashDate(startDate),
      'used_paid_holidays': usedDays,
    });
    return data['value'] as String;
  }

  @override
  Future<PaidHolidayRequest> submitCreate({
    required DateTime startDate,
    required String computedEndDate,
    required PaidHolidayType type,
    required double usedDays,
    String? note,
  }) async {
    // PaidHolidayController@store(新規申請)。1次承認者への通知はサーバー側で行われる
    await client.post('/paid-holidays', _savePayload(startDate, computedEndDate, type, usedDays, note));

    return PaidHolidayRequest(
      id: 'pending',
      startDate: startDate,
      endDate: parseSlashDate(computedEndDate),
      type: type,
      usedDays: usedDays,
      status: PaidHolidayStatus.pending,
      appliedDate: formatIsoDate(DateTime.now()),
      note: note,
    );
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
    // 新規・再申請は同一エンドポイント(POST /paid-holidays)で、idを含めると再申請扱いになる
    final payload = _savePayload(startDate, computedEndDate, type, usedDays, note);
    payload['id'] = int.parse(id);
    await client.post('/paid-holidays', payload);

    return PaidHolidayRequest(
      id: id,
      startDate: startDate,
      endDate: parseSlashDate(computedEndDate),
      type: type,
      usedDays: usedDays,
      status: PaidHolidayStatus.pending,
      appliedDate: formatIsoDate(DateTime.now()),
      note: note,
    );
  }

  Map<String, dynamic> _savePayload(
    DateTime startDate,
    String computedEndDate,
    PaidHolidayType type,
    double usedDays,
    String? note,
  ) {
    return {
      'holiday_type': type == PaidHolidayType.fullDay ? 1 : 2,
      'paid_holiday_start_date': formatSlashDate(startDate),
      'paid_holiday_end_date': computedEndDate,
      'used_paid_holidays': usedDays,
      'extra_info': note,
    };
  }

  PaidHolidaySummary _summaryFrom(Map<String, dynamic> balance) {
    return PaidHolidaySummary(
      remainingDays: '${balance['totalRemainingDays']}日',
      // 消化予定(承認済み未取得分)を返すAPIが無いため未対応のまま
      plannedDays: '-',
      nextGrantDate: (balance['nextScheduledGrantedDate'] as String?) ?? '未定',
    );
  }

  PaidHolidayRequest _requestFrom(Map<String, dynamic> item) {
    return PaidHolidayRequest(
      id: item['id'].toString(),
      startDate: parseSlashDate(item['paidHolidayStartDate'] as String),
      endDate: parseSlashDate(item['paidHolidayEndDate'] as String),
      type: item['holidayType'] == 2 ? PaidHolidayType.halfDay : PaidHolidayType.fullDay,
      usedDays: double.parse(item['usedPaidHolidays'].toString()),
      status: _statusFrom(item['requestStatus'] as int),
      appliedDate: formatIsoDate(parseSlashDate(item['requestedDate'] as String)),
      rejectionNote: item['rejectionReason'] as String?,
      approverInfo: item['approverName'] as String?,
      processedAt: item['processedAtLabel'] as String?,
    );
  }

  /// TimeFace2の実際の申請ステータス(1:申請中 2:承認済み 3:却下 4:差し戻し 5:消化済み 6:取消済み)を
  /// アプリ内の表示用ステータス(pending/rejected/approvedの3値)へ丸めて使う。
  ///
  /// - 1(申請中) → pending
  /// - 4(差し戻し。要再申請、申請中タブに含まれる) → rejected
  /// - 3(却下)・6(取消済み。いずれも処理済みタブに含まれ、再申請ボタンは出ない) → rejected
  ///   (バッジ文言は「差し戻し」のまま流用しており、却下/取消済みでも同じ表示になる簡略化がある)
  /// - 2(承認済み)・5(消化済み) → approved
  PaidHolidayStatus _statusFrom(int requestStatus) {
    switch (requestStatus) {
      case 1:
        return PaidHolidayStatus.pending;
      case 3:
      case 4:
      case 6:
        return PaidHolidayStatus.rejected;
      default:
        return PaidHolidayStatus.approved;
    }
  }
}
