import 'package:flutter/material.dart';
import '../common/widgets/app_bottom_nav.dart';
import '../common/widgets/app_top_bar.dart';
import 'repositories/company_repositories.dart';
import 'screens/company_dashboard_screen.dart';
import 'screens/company_employees_screen.dart';
import 'screens/company_login_screen.dart';
import 'screens/company_offices_departments_screen.dart';
import 'screens/company_paid_holiday_requests_screen.dart';

const _tabTitles = ['ダッシュボード', '従業員', '有給申請', '事業所'];

const _tabItems = [
  AppBottomNavItem(icon: Icons.home_rounded, label: 'ホーム'),
  AppBottomNavItem(icon: Icons.groups_rounded, label: '従業員'),
  AppBottomNavItem(icon: Icons.wb_sunny_rounded, label: '有給申請'),
  AppBottomNavItem(icon: Icons.apartment_rounded, label: '事業所'),
];

/// 企業管理者ログイン後のメイン画面。[EmployeeShell]と同じ
/// IndexedStack+共通AppTopBar/AppBottomNavの構成で4タブを切り替える。
class CompanyShell extends StatefulWidget {
  const CompanyShell({super.key, required this.repositories});

  final CompanyRepositories repositories;

  @override
  State<CompanyShell> createState() => _CompanyShellState();
}

class _CompanyShellState extends State<CompanyShell> {
  int _tabIndex = 0;

  void _goToTab(int index) => setState(() => _tabIndex = index);

  Future<void> _handleLogout() async {
    await widget.repositories.auth.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => CompanyLoginScreen(repositories: widget.repositories)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.repositories.auth.currentUser;
    return Scaffold(
      appBar: AppTopBar(
        title: _tabTitles[_tabIndex],
        userInitial: user.initial,
        userName: user.companyName,
        userEmail: user.email,
        onLogout: _handleLogout,
      ),
      bottomNavigationBar: AppBottomNav(items: _tabItems, currentIndex: _tabIndex, onTap: _goToTab),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          CompanyDashboardScreen(
            repositories: widget.repositories,
            onOpenEmployees: () => _goToTab(1),
            onOpenPaidHolidayRequests: () => _goToTab(2),
            onOpenOffices: () => _goToTab(3),
          ),
          CompanyEmployeesScreen(repositories: widget.repositories),
          CompanyPaidHolidayRequestsScreen(repositories: widget.repositories),
          CompanyOfficesDepartmentsScreen(repositories: widget.repositories),
        ],
      ),
    );
  }
}
