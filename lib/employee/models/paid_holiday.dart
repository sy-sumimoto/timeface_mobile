import '../../common/utils/date_format.dart';

/// TimeFace2の `holiday_type`(1:全休 2:半休)に対応。
enum PaidHolidayType { fullDay, halfDay }

/// アプリ内表示用の申請ステータス。
///
/// TimeFace2の `requestStatus`(1:申請中 2:承認済み 3:却下 4:差し戻し 5:消化済み 6:取消済み)を
/// [HttpPaidHolidayRepository._statusFrom] で pending/rejected/approved の3値に丸めて使う。
/// 詳細な対応関係は同メソッドのコメントを参照。
enum PaidHolidayStatus { pending, rejected, approved }

/// 有給休暇の残日数サマリー。TimeFace の `GET /api/mobile/paid-holidays/balance`
/// のレスポンス(`balance` = PaidHolidayBalanceDto)に対応する。
class PaidHolidaySummary {
  const PaidHolidaySummary({
    required this.remainingDays,
    required this.plannedDays,
    required this.nextGrantDate,
    this.previousPeriodDays,
    this.currentPeriodDays,
    this.hasExpiringSoon = false,
    this.expiringSoonDays,
    this.expiringSoonDate,
  });

  final String remainingDays;
  final String plannedDays;
  final String nextGrantDate;

  /// 前期付与ぶんの残日数(`previousPeriodRemainingDays`)。取得できなければ null。
  final String? previousPeriodDays;

  /// 今期付与ぶんの残日数(`currentPeriodRemainingDays`)。取得できなければ null。
  final String? currentPeriodDays;

  /// 失効が近い(既定3ヶ月以内)付与があるか(`hasExpiringSoon`)。
  final bool hasExpiringSoon;

  /// 失効が近い付与の残日数ラベル(`expiringSoonDaysLabel`。例: "8.5日")。
  final String? expiringSoonDays;

  /// 失効が近い付与の有効期限ラベル(`expiringSoonDateLabel`。例: "2026/9/30")。
  final String? expiringSoonDate;
}

/// 有給休暇の申請1件分。TimeFace2の有給休暇申請(PaidHolidayRequest)テーブルの
/// 1レコードに対応する。
class PaidHolidayRequest {
  const PaidHolidayRequest({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.usedDays,
    required this.status,
    required this.appliedDate,
    this.note,
    this.rejectionNote,
    this.approverInfo,
    this.processedAt,
  });

  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final PaidHolidayType type;

  /// 取得日数(TimeFace2の `used_paid_holidays`。全休は1以上の整数、半休は0.5)
  final double usedDays;
  final PaidHolidayStatus status;
  final String appliedDate;
  final String? note;
  final String? rejectionNote;
  final String? approverInfo;
  final String? processedAt;

  /// 開始日〜終了日を表示用文字列に整形する(単日の場合は開始日のみ)。
  String get periodLabel {
    final start = formatIsoDate(startDate);
    if (isSameDay(startDate, endDate)) return start;
    return '$start〜${formatIsoDate(endDate)}';
  }

  /// 取得日数の表示用文字列(整数なら小数点なし、半休(0.5)ならそのまま表示)。
  String get daysLabel {
    if (usedDays == usedDays.roundToDouble()) {
      return '${usedDays.toInt()}日';
    }
    return '$usedDays日';
  }

  String get typeLabel => type == PaidHolidayType.fullDay ? '全休' : '半休';

  /// 再申請フォーム(PaidHolidayEditScreen)向けに、指定フィールドだけ差し替えた
  /// 新しいインスタンスを作る。rejectionNote等はnullを明示的に渡せるよう
  /// センチネル値([_unset])で「未指定」と「nullを設定」を区別している。
  PaidHolidayRequest copyWith({
    DateTime? startDate,
    DateTime? endDate,
    PaidHolidayType? type,
    double? usedDays,
    PaidHolidayStatus? status,
    String? appliedDate,
    String? note,
    Object? rejectionNote = _unset,
    Object? approverInfo = _unset,
    Object? processedAt = _unset,
  }) {
    return PaidHolidayRequest(
      id: id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      type: type ?? this.type,
      usedDays: usedDays ?? this.usedDays,
      status: status ?? this.status,
      appliedDate: appliedDate ?? this.appliedDate,
      note: note ?? this.note,
      rejectionNote: identical(rejectionNote, _unset) ? this.rejectionNote : rejectionNote as String?,
      approverInfo: identical(approverInfo, _unset) ? this.approverInfo : approverInfo as String?,
      processedAt: identical(processedAt, _unset) ? this.processedAt : processedAt as String?,
    );
  }
}

const _unset = Object();
