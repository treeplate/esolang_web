import 'package:texteditor/errors.dart';

import 'lexer.dart';
import 'ast.dart';

Program parseProgram(String file, List<ParseError> parseErrors) {
  TokenReader tokens = TokenReader(tokenise(file), parseErrors);
  List<Statement> program = [];
  while (true) {
    Token token = tokens.readToken();
    void error(String error) {
      parseErrors.add(ParseError(token.line, token.column, error));
    }

    if (token is EOFToken) break;
    String? identifier = castToken<IdentifierToken>(
      token,
      'identifier',
      parseErrors,
    )?.identifier;
    if (identifier == null) {
      continue;
    }
    switch (identifier) {
      case 'expression':
        program.add(ExpressionStatement(parseExpression(tokens)));
      default:
        error('unexpected identifier "$identifier" at start of statement');
    }
  }
  return Program(program: program);
}

Expression parseExpression(TokenReader tokens) {
  Token token = tokens.readToken();
  if (token is EOFToken) {
    tokens.parseErrors.add(ParseError(token.line, token.column, 'unexpected EOF at start of expression'));
    throw UnexpectedEOFException();
  }
  tokens.parseErrors.add(ParseError(token.line, token.column, 'expressions not implemented'));
  return PlaceholderExpression();
}