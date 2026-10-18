class AppError {
  final String message;
  final String? code;
  final dynamic original;

  const AppError({required this.message, this.code, this.original});

  @override
  String toString() => 'AppError[$code]: $message';

  static AppError fromException(dynamic e) {
    if (e is AppError) return e;
    return AppError(message: e.toString(), original: e);
  }
}
