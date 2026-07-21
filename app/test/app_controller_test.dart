import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vetcare_app/components/app_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(Get.reset);

  testWidgets('settings persist language and appearance', (tester) async {
    final controller = AppController();

    await controller.setLocale('en');
    await controller.setDarkMode(true);

    final restored = AppController();
    await restored.loadPreferences();

    expect(restored.locale.value, 'en');
    expect(restored.isDark.value, isTrue);
  });

  testWidgets('invalid language falls back to Spanish', (tester) async {
    final controller = AppController();
    await controller.setLocale('fr');

    expect(controller.locale.value, 'es');
  });
}
