import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vetcare_app/configs/generic_response.dart';
import 'package:vetcare_app/configs/app_routes.dart';
import 'package:vetcare_app/configs/theme.dart';
import 'package:vetcare_app/models/app_user.dart';
import 'package:vetcare_app/pages/sign_in/sign_in_controller.dart';
import 'package:vetcare_app/pages/sign_in/sign_in_page.dart';
import 'package:vetcare_app/pages/sign_up/sign_up_controller.dart';
import 'package:vetcare_app/pages/sign_up/sign_up_page.dart';
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

  testWidgets(
      'successful signup returns to the mounted login without disposed fields',
      (tester) async {
    final signIn = Get.put(SignInController(authService: _FakeAuthService()));
    late SignUpController signUp;

    await tester.pumpWidget(GetMaterialApp(
      initialRoute: AppRoutes.signIn,
      getPages: [
        GetPage(
          name: AppRoutes.signIn,
          page: () => SignInPage(controller: signIn),
        ),
        GetPage(
          name: AppRoutes.signUp,
          page: () {
            signUp = Get.put(SignUpController(
              authService: _SuccessfulSignUpAuthService(),
            ));
            return SignUpPage(controller: signUp);
          },
        ),
      ],
    ));
    await tester.pumpAndSettle();

    Get.toNamed(AppRoutes.signUp);
    await tester.pumpAndSettle();

    signUp.firstNameCtrl.text = 'Prueba';
    signUp.lastNameCtrl.text = 'Cliente';
    signUp.documentCtrl.text = '12345678';
    signUp.emailCtrl.text = 'nuevo@example.test';
    signUp.passwordCtrl.text = 'Verde123';
    signUp.confirmCtrl.text = 'Verde123';
    signUp.register();
    await tester.pumpAndSettle();

    expect(Get.currentRoute, AppRoutes.signIn);
    expect(signIn.emailCtrl.text, 'nuevo@example.test');
    expect(tester.takeException(), isNull);
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

class _SuccessfulSignUpAuthService extends AuthService {
  _SuccessfulSignUpAuthService() : super.detached();

  @override
  Future<GenericResponse<AppUser>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? document,
    String? phone,
    String? address,
    String role = 'client',
  }) async =>
      GenericResponse(
        success: true,
        code: 'SIGNED_UP',
        data: AppUser(
          id: 'signup-test-user',
          email: email,
          firstName: firstName,
          lastName: lastName,
          document: document,
          role: role,
        ),
      );
}
