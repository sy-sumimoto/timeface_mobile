/// 承認ステータス。TimeFace2の有給休暇申請フローに合わせた3値
/// (1次・2次承認の詳細は持たず、モバイル版は単純化して扱う)。
enum PaidHolidayApprovalStatus { pending, approved, rejected }

/// 企業管理者が承認・差し戻しを行う有給休暇申請1件分。
/// 従業員側の `PaidHolidayRequest`(employee/models/paid_holiday.dart)に
/// 申請者名(employeeName)を加えたもの。TimeFace2の
/// `Company\PaidHolidayRequestController` に対応する。
class PaidHolidayApproval {
  const PaidHolidayApproval({
    required this.id,
    required this.employeeName,
    required this.periodLabel,
    required this.typeLabel,
    required this.daysLabel,
    required this.appliedDate,
    required this.status,
    this.note,
  });

  final String id;
  final String employeeName;
  final String periodLabel;
  final String typeLabel;
  final String daysLabel;
  final String appliedDate;
  final PaidHolidayApprovalStatus status;
  final String? note;

  PaidHolidayApproval copyWith({PaidHolidayApprovalStatus? status, String? note}) {
    return PaidHolidayApproval(
      id: id,
      employeeName: employeeName,
      periodLabel: periodLabel,
      typeLabel: typeLabel,
      daysLabel: daysLabel,
      appliedDate: appliedDate,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }
}
