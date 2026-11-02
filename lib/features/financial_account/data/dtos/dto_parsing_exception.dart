final class DtoParsingException implements FormatException {
  const DtoParsingException(this.message, {this.source, this.offset});

  @override
  final String message;

  @override
  final Object? source;

  @override
  final int? offset;

  @override
  String toString() => 'DtoParsingException: $message';
}
