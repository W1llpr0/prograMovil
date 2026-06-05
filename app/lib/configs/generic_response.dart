/// Generic wrapper for all service responses (mirrors professor's pattern).
class GenericResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final String? error;

  const GenericResponse({
    required this.success,
    this.data,
    this.message = '',
    this.error,
  });

  bool get hasError => error != null && error!.isNotEmpty;
  bool get hasData => data != null;

  @override
  String toString() =>
      'GenericResponse{success: $success, message: "$message", error: $error}';
}
