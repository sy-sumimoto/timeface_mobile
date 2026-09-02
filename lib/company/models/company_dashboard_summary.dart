/// 企業管理者ダッシュボードのKPIサマリー。
/// TimeFace2の `Company\DashBoardController@index` 相当(現状Web版のみ・モバイルAPIは未実装)。
class CompanyDashboardSummary {
  const CompanyDashboardSummary({
    required this.employeeCount,
    required this.workingNowCount,
    required this.pendingPaidHolidayCount,
    required this.officeCount,
  });

  final int employeeCount;
  final int workingNowCount;
  final int pendingPaidHolidayCount;
  final int officeCount;
}
