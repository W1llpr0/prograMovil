/// Generic wrapper for all service responses (mirrors professor's pattern).
class GenericResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final String? code;
  final String? error;

  const GenericResponse({
    required this.success,
    this.data,
    this.message = '',
    this.code,
    this.error,
  });

  factory GenericResponse.fromRpc(
    dynamic payload, {
    T Function(Map<String, dynamic> json)? decode,
  }) {
    if (payload is! Map) {
      return GenericResponse<T>(
        success: false,
        code: 'INVALID_RESPONSE',
        message: 'El servidor devolvió una respuesta inválida.',
        error: payload?.toString(),
      );
    }
    final map = Map<String, dynamic>.from(payload);
    final rawData = map['data'];
    T? parsed;
    if (rawData != null && decode != null) {
      parsed = decode(Map<String, dynamic>.from(rawData as Map));
    } else if (rawData is T) {
      parsed = rawData;
    }
    return GenericResponse<T>(
      success: map['success'] == true,
      data: parsed,
      code: map['code']?.toString(),
      message: map['message']?.toString() ?? '',
      error: map['error']?.toString(),
    );
  }

  bool get hasError => error != null && error!.isNotEmpty;
  bool get hasData => data != null;

  @override
  String toString() =>
      'GenericResponse{success: $success, code: $code, message: "$message", error: $error}';
}
