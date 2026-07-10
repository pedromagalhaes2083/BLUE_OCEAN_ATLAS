class UnauthorisedException implements Exception {
  final String message;
  const UnauthorisedException(this.message);

  @override
  String toString() => 'UnauthorisedException: $message';
}
