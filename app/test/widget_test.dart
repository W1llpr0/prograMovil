import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vetcare_app/configs/generic_response.dart';
import 'package:vetcare_app/configs/theme.dart';
import 'package:vetcare_app/models/app_user.dart';
import 'package:vetcare_app/pages/sign_in/sign_in_controller.dart';
import 'package:vetcare_app/pages/sign_in/sign_in_page.dart';
import 'package:vetcare_app/services/auth_service.dart';

void main() {
  setUp(() => Get.reset());

  testWidgets('login matches the Spanish VetCare entry mockup', (tester) async {
    final controller = SignInController(authService: _FakeAuthService());

    await tester.pumpWidget(GetMaterialApp(
      theme: AppTheme.light(),
      home: SignInPage(controller: controller),
    ));

    expect(find.text('VetCare'), findsOneWidget);
    expect(find.text('Tu veterinaria digital'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Regístrate'), findsOneWidget);
    expect(find.byIcon(Icons.pets), findsOneWidget);
  });
}

class _FakeAuthService extends AuthService {
  _FakeAuthService() : super.detached();

  @override
  Future<GenericResponse<AppUser>> signIn({
    required String email,
    required String password,
  }) async =>
      const GenericResponse(success: false, message: 'not used');
}
