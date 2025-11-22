class ParseError {
  final int line;
  final int column;
  final String error;

  @override
  String toString() => '$error (line $line column $column).';

  ParseError(this.line, this.column, this.error);
}

class UnexpectedEOFException implements Exception {
  @override
  String toString() => 'unexpected EOF exception (should be caught!)';
}