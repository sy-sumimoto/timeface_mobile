import 'company_summary.dart';

/// 企業詳細画面の表示・編集データ。TimeFace2の`Company\CompanyController@detail`
/// (基本情報の参照 + 契約情報(`Contract`)の編集)に対応する。
/// 企業自体は企業側のセルフサーブ申込みで作成されるため、システム管理者側に
/// 新規登録画面は無い(Laravel側のコメントを踏襲)。
class CompanyContractDetail {
  const CompanyContractDetail({
    required this.id,
    required this.companyName,
    required this.presidentName,
    required this.address,
    required this.tel,
    required this.planName,
    required this.contractStatus,
    required this.contractFrom,
    required this.contractTo,
    required this.unitPriceLabel,
  });

  final String id;
  final String companyName;
  final String presidentName;
  final String address;
  final String tel;
  final String planName;
  final ContractStatus contractStatus;
  final String contractFrom;
  final String contractTo;
  final String unitPriceLabel;

  CompanyContractDetail copyWith({
    String? planName,
    ContractStatus? contractStatus,
    String? contractFrom,
    String? contractTo,
    String? unitPriceLabel,
  }) {
    return CompanyContractDetail(
      id: id,
      companyName: companyName,
      presidentName: presidentName,
      address: address,
      tel: tel,
      planName: planName ?? this.planName,
      contractStatus: contractStatus ?? this.contractStatus,
      contractFrom: contractFrom ?? this.contractFrom,
      contractTo: contractTo ?? this.contractTo,
      unitPriceLabel: unitPriceLabel ?? this.unitPriceLabel,
    );
  }
}
