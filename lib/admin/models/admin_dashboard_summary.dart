/// システム管理者ダッシュボードのKPIサマリー。
/// TimeFace2の`Admin\DashBoardController@index`相当(現状Web版のみ・モバイルAPIは未実装)。
class AdminDashboardSummary {
  const AdminDashboardSummary({
    required this.contractedCompanyCount,
    required this.monthlyInvoiceAmountLabel,
    required this.announcementCount,
    required this.adminCount,
  });

  final int contractedCompanyCount;
  final String monthlyInvoiceAmountLabel;
  final int announcementCount;
  final int adminCount;
}
