import '../../common/api/api_client.dart';
import 'announcement_repository.dart';
import 'attendance_repository.dart';
import 'auth_repository.dart';
import 'http_announcement_repository.dart';
import 'http_attendance_repository.dart';
import 'http_auth_repository.dart';
import 'http_paid_holiday_repository.dart';
import 'http_punch_repository.dart';
import 'paid_holiday_repository.dart';
import 'password_reset_repository.dart';
import 'punch_repository.dart';
import 'token_storage.dart';

/// 画面に渡すリポジトリ一式。パッケージに依存しない手動DIコンテナ。
///
/// 認証・打刻・勤怠・有給休暇・お知らせはTimeFace2(Laravel)の
/// スマホアプリ向けAPI(`/api/mobile/*`、time_face_スマホアプリAPI仕様書(従業員向け).xlsx)を叩く。
class EmployeeRepositories {
  /// APIのオリジン(scheme + host[:port])。
  /// ビルド時に `--dart-define=API_ORIGIN=https://timeface.ddd-system.co.jp` で指定する。
  /// 未指定時は `php artisan serve --port=8123` で起動したローカルのTimeFace2を指す。
  /// 既定は Android エミュレータ用の 10.0.2.2(ホストPCの 127.0.0.1 へのエイリアス)。
  /// iOSシミュレータ/デスクトップからは `--dart-define=API_ORIGIN=http://127.0.0.1:8123`、
  /// 実機からは `--dart-define=API_ORIGIN=http://<ホストPCのLAN IP>:8123` を指定する。
  static const String _apiOrigin = String.fromEnvironment(
    'API_ORIGIN',
    defaultValue: 'http://10.0.2.2:8123',
  );

  factory EmployeeRepositories({
    /// TimeFace2の従業員向けAPIのベースURL。未指定時は[_apiOrigin] + `/api/mobile`。
    String? apiBaseUrl,
    AuthRepository? auth,
    PunchRepository? punch,
    AttendanceRepository? attendance,
    AnnouncementRepository? announcement,
    PaidHolidayRepository? paidHoliday,
    PasswordResetRepository? passwordReset,

    /// ログイン時に発行されたアクセストークンの保存先。
    /// アプリ本体では [employeeRepositoriesProvider] がセキュアストレージ実装
    /// (flutter_secure_storage)を注入する。未指定時はメモリ保持のみ。
    TokenStorage? tokenStorage,
  }) {
    final client = ApiClient(baseUrl: apiBaseUrl ?? '$_apiOrigin/api/mobile');
    // HttpPunchRepositoryは打刻APIのレスポンスに氏名が含まれないため、
    // ログイン時に取得済みのauthRepo.currentUserから氏名を借用する
    final authRepo =
        auth ??
        HttpAuthRepository(
          client: client,
          tokenStorage: tokenStorage ?? InMemoryTokenStorage(),
        );
    return EmployeeRepositories._(
      client: client,
      auth: authRepo,
      punch: punch ?? HttpPunchRepository(client: client, auth: authRepo),
      attendance: attendance ?? HttpAttendanceRepository(client: client),
      announcement: announcement ?? HttpAnnouncementRepository(client: client),
      paidHoliday: paidHoliday ?? HttpPaidHolidayRepository(client: client),
      passwordReset: passwordReset ?? MockPasswordResetRepository(),
    );
  }

  EmployeeRepositories._({
    required this.client,
    required this.auth,
    required this.punch,
    required this.attendance,
    required this.announcement,
    required this.paidHoliday,
    required this.passwordReset,
  });

  final ApiClient client;
  final AuthRepository auth;
  final PunchRepository punch;
  final AttendanceRepository attendance;
  final AnnouncementRepository announcement;
  final PaidHolidayRepository paidHoliday;
  final PasswordResetRepository passwordReset;
}
