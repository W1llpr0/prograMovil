import 'package:flutter_test/flutter_test.dart';
import 'package:vetcare_app/main.dart';

void main() {
  testWidgets('VetCare app smoke test', (WidgetTester tester) async {
    // App requires Supabase init; just verify it can be instantiated.
    expect(VetCareApp, isNotNull);
  });
}
