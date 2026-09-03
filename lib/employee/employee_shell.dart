import 'package:flutter/material.dart';
import '../common/api/api_exception.dart';
import '../common/widgets/app_bottom_nav.dart';
import '../common/widgets/app_top_bar.dart';
import 'models/punch_state.dart';
import 'repositories/employee_repositories.dart';
import 'screens/announcements_screen.dart';
import 'screens/attendances_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/paid_holidays_screen.dart';
import 'screens/punch_screen.dart';

const _tabTitles = ['マイページ', '打刻', '勤怠', '有給休暇', 'お知らせ'];

const _tabItems = [
  AppBottomNavItem(icon: Icons.home_rounded, label: 'ホーム'),
  AppBottomNavItem(icon: Icons.access_time_rounded, label: '打刻'),
  AppBottomNavItem(icon: Icons.calendar_month_rounded, label: '勤怠'),
  AppBottomNavItem(icon: Icons.wb_sunny_rounded, label: '有給休暇'),
  AppBottomNavItem(icon: Icons.mail_rounded, label: 'お知らせ'),
];

/// 従業員ログイン後のメイン画面。下部タブ(5画面)を1つのScaffoldで共有し、
/// タブ切り替えはIndexedStackで行う(各タブのbuild状態は保持される)。
class EmployeeShell extends StatefulWidget {
  const EmployeeShell({super.key, required this.repositories});

  final EmployeeRepositories repositories;

  @override
  State<EmployeeShell> createState() => _EmployeeShellState();
}

class _EmployeeShellState extends State<EmployeeShell> {
  int _tabIndex = 0;
  PunchState? _punchState;

  @override
  void initState() {
    super.initState();
    _loadPunchState();
  }

  /// 起動時に一度だけ本日の打刻状況を取得する。マイページ・打刻タブの両方で
  /// この_punchStateを共有するため、EmployeeShell(親)側で1回だけ保持している。
  Future<void> _loadPunchState() async {
    try {
      final state = await widget.repositories.punch.fetchState();
      if (!mounted) return;
      setState(() => _punchState = state);
    } on ApiException catch (e) {
      // 自動ログイン復元したトークンが期限切れ・失効していた場合はここで401になる。
      // ローカルの認証情報を破棄してログイン画面へ戻す。
      if (e.statusCode == 401) {
        await _handleLogout();
      }
    }
  }

  /// 出勤/退勤/休憩開始/休憩終了いずれかの打刻APIを呼び、
  /// 返ってきた最新状態で_punchStateを更新する(呼び出し元はPunchScreen)。
  Future<void> _runPunchAction(Future<PunchState> Function() action) async {
    final state = await action();
    if (!mounted) return;
    setState(() => _punchState = state);
  }

  void _goToTab(int index) => setState(() => _tabIndex = index);

  /// TimeFace2側のトークンを無効化し、ログイン画面まで全画面スタックを破棄して戻る
  /// (pushAndRemoveUntilで打刻画面等に「戻る」で復帰できないようにする)。
  Future<void> _handleLogout() async {
    await widget.repositories.auth.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen(repositories: widget.repositories)),
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
        userName: user.name,
        userEmail: user.email,
        onLogout: _handleLogout,
      ),
      bottomNavigationBar: AppBottomNav(items: _tabItems, currentIndex: _tabIndex, onTap: _goToTab),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          HomeScreen(
            repositories: widget.repositories,
            punchState: _punchState,
            onOpenPunch: () => _goToTab(1),
            onOpenAttendances: () => _goToTab(2),
            onOpenPaidHolidays: () => _goToTab(3),
            onOpenAnnouncements: () => _goToTab(4),
          ),
          PunchScreen(
            punchState: _punchState,
            onClockIn: () => _runPunchAction(widget.repositories.punch.clockIn),
            onClockOut: () => _runPunchAction(widget.repositories.punch.clockOut),
            onBreakStart: () => _runPunchAction(widget.repositories.punch.startBreak),
            onBreakEnd: () => _runPunchAction(widget.repositories.punch.endBreak),
          ),
          AttendancesScreen(repository: widget.repositories.attendance, isActive: _tabIndex == 2),
          PaidHolidaysScreen(repository: widget.repositories.paidHoliday),
          AnnouncementsScreen(repository: widget.repositories.announcement),
        ],
      ),
    );
  }
}
