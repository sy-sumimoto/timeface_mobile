import '../../common/api/api_client.dart';
import 'company_auth_repository.dart';
import 'company_dashboard_repository.dart';
import 'company_signup_repository.dart';
import 'department_repository.dart';
import 'employee_repository.dart';
import 'http_company_auth_repository.dart';
import 'http_company_signup_repository.dart';
import 'http_employee_repository.dart';
import 'office_repository.dart';
import 'paid_holiday_approval_repository.dart';

/// 企業管理者画面に渡すリポジトリ一式。[EmployeeRepositories]と同じ
/// 手動DIコンテナのパターン。
///
/// ログイン・従業員管理・サインアップはTimeFace2の実APIを叩く。
/// ダッシュボード・事業所/部署・有給承認はまだモバイルAPIが無いため、
/// 当面Mock実装のまま(実API追加時はそれぞれの実装だけ差し替える想定)。
class CompanyRepositories {
  /// APIのオリジン(scheme + host[:port])。
  /// 既定は本番のTimeFace2(`https://timeface.ddd-system.co.jp`)。
  /// ローカルのTimeFace2(`php artisan serve --port=8123`)へ向ける場合はビルド時に上書きする。
  /// Androidエミュレータ: `--dart-define=API_ORIGIN=http://10.0.2.2:8123`
  /// iOSシミュレータ/デスクトップ: `--dart-define=API_ORIGIN=http://127.0.0.1:8123`
  /// 実機: `--dart-define=API_ORIGIN=http://<ホストPCのLAN IP>:8123`
  static const String _apiOrigin = String.fromEnvironment(
    'API_ORIGIN',
    defaultValue: 'https://timeface.ddd-system.co.jp',
  );

  factory CompanyRepositories({
    /// TimeFace2の企業管理者向けAPIのベースURL。未指定時は[_apiOrigin] + `/api/company`。
    String? apiBaseUrl,
    CompanyAuthRepository? auth,
    CompanySignupRepository? signup,
    CompanyDashboardRepository? dashboard,
    EmployeeRepository? employee,
    PaidHolidayApprovalRepository? paidHolidayApproval,
    OfficeRepository? office,
    DepartmentRepository? department,
  }) {
    final client = ApiClient(baseUrl: apiBaseUrl ?? '$_apiOrigin/api/company');
    return CompanyRepositories._(
      client: client,
      auth: auth ?? HttpCompanyAuthRepository(client: client),
      signup: signup ?? HttpCompanySignupRepository(client: client),
      dashboard: dashboard ?? MockCompanyDashboardRepository(),
      employee: employee ?? HttpEmployeeRepository(client: client),
      paidHolidayApproval: paidHolidayApproval ?? MockPaidHolidayApprovalRepository(),
      office: office ?? MockOfficeRepository(),
      department: department ?? MockDepartmentRepository(),
    );
  }

  CompanyRepositories._({
    required this.client,
    required this.auth,
    required this.signup,
    required this.dashboard,
    required this.employee,
    required this.paidHolidayApproval,
    required this.office,
    required this.department,
  });

  final ApiClient client;
  final CompanyAuthRepository auth;
  final CompanySignupRepository signup;
  final CompanyDashboardRepository dashboard;
  final EmployeeRepository employee;
  final PaidHolidayApprovalRepository paidHolidayApproval;
  final OfficeRepository office;
  final DepartmentRepository department;
}
