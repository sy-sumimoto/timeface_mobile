/// 契約状況。TimeFace2の`Contract.contract_status`に対応する。
enum ContractStatus { active, ended }

/// 企業一覧の1件分。TimeFace2の`Company`+`Contract`モデルから
/// 一覧表示に必要な項目のみ持つ。詳細は[CompanyContractDetail]を参照。
class CompanySummary {
  const CompanySummary({
    required this.id,
    required this.companyName,
    required this.presidentName,
    required this.planName,
    required this.contractStatus,
    required this.employeeCount,
  });

  final String id;
  final String companyName;
  final String presidentName;
  final String planName;
  final ContractStatus contractStatus;
  final int employeeCount;

  String get contractStatusLabel => contractStatus == ContractStatus.active ? '契約中' : '契約終了';
}
