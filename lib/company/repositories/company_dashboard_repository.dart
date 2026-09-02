import '../models/company_dashboard_summary.dart';

/// 企業管理者ダッシュボードのKPI取得口。
abstract class CompanyDashboardRepository {
  Future<CompanyDashboardSummary> fetchSummary();
}

class MockCompanyDashboardRepository implements CompanyDashboardRepository {
  @override
  Future<CompanyDashboardSummary> fetchSummary() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return const CompanyDashboardSummary(
      employeeCount: 32,
      workingNowCount: 18,
      pendingPaidHolidayCount: 3,
      officeCount: 2,
    );
  }
}
