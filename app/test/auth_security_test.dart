import 'package:flutter_test/flutter_test.dart';
import 'package:vetcare_app/services/auth_service.dart';

void main() {
  test('malformed credentials use the generic non-enumerating response',
      () async {
    final response = await AuthService.detached().signIn(
      email: 'not-an-email',
      password: 'anything',
    );

    expect(response.success, isFalse);
    expect(response.code, 'INVALID_CREDENTIALS');
    expect(response.message, AuthService.invalidCredentialsMessage);
    expect(response.error, isNull);
    expect(response.message.toLowerCase(), isNot(contains('user')));
    expect(response.message.toLowerCase(), isNot(contains('email not found')));
  });
}
