import 'package:flutter_test/flutter_test.dart';
import 'package:vetcare_app/configs/generic_response.dart';

void main() {
  group('GenericResponse.fromRpc', () {
    test('decodes a successful backend envelope', () {
      final response = GenericResponse<Map<String, dynamic>>.fromRpc({
        'success': true,
        'code': 'CREATED',
        'message': 'ok',
        'data': {'id': 7}
      }, decode: (json) => json);

      expect(response.success, isTrue);
      expect(response.code, 'CREATED');
      expect(response.data?['id'], 7);
      expect(response.hasError, isFalse);
    });

    test('rejects malformed payloads', () {
      final response = GenericResponse<void>.fromRpc('not-json');

      expect(response.success, isFalse);
      expect(response.code, 'INVALID_RESPONSE');
      expect(response.hasError, isTrue);
    });
  });
}
