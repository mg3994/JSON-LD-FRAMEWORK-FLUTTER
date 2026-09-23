enum ValidationSeverity { info, warning, error }

enum ValidationMode {
  /// Strict mode: errors are treated strictly and cause validation failure.
  strict,

  /// Warning mode: non-critical warnings are logged/flagged but validation passes.
  warning,

  /// Permissive mode: loose validation, logs issues without failing.
  permissive,
}

class ValidationError {
  final String path;
  final String message;
  final ValidationSeverity severity;

  ValidationError({
    required this.path,
    required this.message,
    this.severity = ValidationSeverity.warning,
  });

  @override
  String toString() => '[$severity] At "$path": $message';
}

class ValidationReport {
  final ValidationMode mode;
  final List<ValidationError> errors;

  ValidationReport({
    required this.mode,
    required this.errors,
  });

  bool get isValid => errors.where((e) => e.severity == ValidationSeverity.error).isEmpty;

  List<ValidationError> get warnings =>
      errors.where((e) => e.severity == ValidationSeverity.warning).toList();

  List<ValidationError> get criticalErrors =>
      errors.where((e) => e.severity == ValidationSeverity.error).toList();
}

/// Helper for ISO 8601, ISO 4217, and URI validations.
class DataTypeValidator {
  static final RegExp _iso8601Date = RegExp(
    r'^\d{4}(-\d{2}(-\d{2}(T\d{2}:\d{2}(:\d{2}(\.\d+)?)?(Z|[\+\-]\d{2}:\d{2})?)?)?)?$',
  );

  static final RegExp _iso8601Duration = RegExp(
    r'^P(?!$)(\d+Y)?(\d+M)?(\d+W)?(\d+D)?(T(?=.)(\d+H)?(\d+M)?(\d+S)?)?$',
  );

  static final RegExp _iso4217Currency = RegExp(r'^[A-Z]{3}$');

  static bool isValidIsoDate(String value) => _iso8601Date.hasMatch(value);

  static bool isValidIsoDuration(String value) => _iso8601Duration.hasMatch(value);

  static bool isValidCurrencyCode(String value) => _iso4217Currency.hasMatch(value);

  static bool isAbsoluteUri(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && uri.hasScheme && uri.hasAuthority;
  }
}
