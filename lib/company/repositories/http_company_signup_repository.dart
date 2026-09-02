import '../../common/api/api_client.dart';
import 'company_signup_repository.dart';

/// TimeFace2 (`/api/company/signup` `/signup/resend` `/signup/verify`) を叩く実装。
class HttpCompanySignupRepository implements CompanySignupRepository {
  HttpCompanySignupRepository({required this.client});

  final ApiClient client;

  @override
  Future<void> requestSignUpCode({
    required String lastName,
    required String firstName,
    required String email,
    required String password,
  }) async {
    await client.post('/signup', {
      'last_name': lastName,
      'first_name': firstName,
      'email': email,
      'password': password,
    });
  }

  @override
  Future<void> resendSignUpCode({required String email}) async {
    await client.post('/signup/resend', {'email': email});
  }

  @override
  Future<void> verifySignUpCode({required String email, required String code}) async {
    await client.post('/signup/verify', {'email': email, 'code': code});
  }
}
