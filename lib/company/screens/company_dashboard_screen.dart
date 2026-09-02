import 'package:flutter/material.dart';
import '../../common/theme/app_colors.dart';
import '../../common/widgets/kpi_card.dart';
import '../models/company_dashboard_summary.dart';
import '../repositories/company_repositories.dart';

/// 企業管理者ホーム(ダッシュボード)。TimeFace2の
/// `Company\DashBoardController@index`に相当するKPIを表示する。
class CompanyDashboardScreen extends StatefulWidget {
  const CompanyDashboardScreen({
    super.key,
    required this.repositories,
    required this.onOpenEmployees,
    required this.onOpenPaidHolidayRequests,
    required this.onOpenOffices,
  });

  final CompanyRepositories repositories;
  final VoidCallback onOpenEmployees;
  final VoidCallback onOpenPaidHolidayRequests;
  final VoidCallback onOpenOffices;

  @override
  State<CompanyDashboardScreen> createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen> {
  CompanyDashboardSummary? _summary;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final summary = await widget.repositories.dashboard.fetchSummary();
    if (!mounted) return;
    setState(() => _summary = summary);
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    final companyName = widget.repositories.auth.currentUser.companyName;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ダッシュボード', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('$companyName の本日の状況です', style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          if (summary == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                KpiCard(
                  label: '従業員数',
                  value: '${summary.employeeCount}名',
                  delta: '本日出勤中 ${summary.workingNowCount}名',
                  icon: Icons.groups_rounded,
                  iconColor: KpiIconColor.blue,
                  onTap: widget.onOpenEmployees,
                ),
                KpiCard(
                  label: '有給休暇 未承認',
                  value: '${summary.pendingPaidHolidayCount}件',
                  delta: '確認が必要な申請',
                  icon: Icons.wb_sunny_rounded,
                  iconColor: KpiIconColor.orange,
                  onTap: widget.onOpenPaidHolidayRequests,
                ),
                KpiCard(
                  label: '事業所数',
                  value: '${summary.officeCount}拠点',
                  delta: '事業所・部署の管理',
                  icon: Icons.apartment_rounded,
                  iconColor: KpiIconColor.green,
                  onTap: widget.onOpenOffices,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
