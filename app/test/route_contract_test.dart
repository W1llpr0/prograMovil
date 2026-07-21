import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every declared and referenced AppRoute is registered exactly once', () {
    final routesSource = File('lib/configs/app_routes.dart').readAsStringSync();
    final mainSource = File('lib/main.dart').readAsStringSync();
    final lib = Directory('lib');

    final declarations = <String, String>{
      for (final match in RegExp(
        r"static const\s+(\w+)\s*=\s*'([^']+)'",
      ).allMatches(routesSource))
        match.group(1)!: match.group(2)!,
    };
    final registered = RegExp(r'name:\s*AppRoutes\.(\w+)')
        .allMatches(mainSource)
        .map((match) => match.group(1)!)
        .toList();
    final referenced = <String>{};
    for (final file in lib.listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      referenced.addAll(RegExp(r'AppRoutes\.(\w+)')
          .allMatches(file.readAsStringSync())
          .map((match) => match.group(1)!));
    }

    expect(declarations, isNotEmpty);
    expect(registered.toSet(), declarations.keys.toSet());
    expect(referenced.difference(declarations.keys.toSet()), isEmpty);
    for (final route in declarations.keys) {
      expect(registered.where((item) => item == route).length, 1,
          reason: '$route must be registered exactly once');
    }
    expect(declarations.values.toSet().length, declarations.length,
        reason: 'route paths must be unique');
  });
}
