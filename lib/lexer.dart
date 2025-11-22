import 'package:flutter/material.dart';
import 'package:texteditor/errors.dart';

class Token {
  final int line;
  final int column;

  Token(this.line, this.column);
}

class SymbolToken extends Token {
  final String symbol;
  SymbolToken(super.line, super.column, this.symbol);

  @override
  String toString() => 'symbol $symbol';
}

class IdentifierToken extends Token {
  final String identifier;
  IdentifierToken(super.line, super.column, this.identifier);
  @override
  String toString() => 'identifier $identifier';
}

class StringToken extends Token {
  final String string;
  StringToken(super.line, super.column, this.string);
  @override
  String toString() => 'string "$string"';
}

class IntegerToken extends Token {
  final int integer;
  IntegerToken(super.line, super.column, this.integer);
  @override
  String toString() => 'integer $integer';
}

class EOFToken extends Token {
  EOFToken(super.line, super.column);
  @override
  String toString() => 'EOF';
}

enum LexerState {
  base,
  bang,
  doubleQuotedString,
  escapedDoubleQuotedString,
  doubleQuotedStringUnicodeEscape,
  percent,
  and,
  andAnd,
  singleQuotedString,
  escapedSingleQuotedString,
  singleQuotedStringUnicodeEscape,
  asterisk,
  plus,
  minus,
  slash,
  number,
  lessThan,
  lessThanLessThan,
  comment,
  equals,
  greaterThan,
  greaterThanGreaterThan,
  identifier,
  caret,
  verticalBar,
  verticalBarVerticalBar,
  tilde,
  tildeSlash,
}

Iterable<Token> tokenise(String file) sync* {
  int i = 0;
  int line = 1;
  int column = 1;
  LexerState state = .base;
  StringBuffer buffer = StringBuffer();
  int intBuffer = 0;
  void endLine() {
    line++;
    column = 0;
  }

  int startLine = 1;
  int startColumn = 1;

  while (i < file.length) {
    String character = file.characters.elementAt(i);
    switch (state) {
      case .base:
        if (character.codeUnits.length > 1) {
          error('unexpected character $character', line, column);
        }
        startColumn = column;
        startLine = line;
        switch (file[i].codeUnits.single) {
          case >= 0 && <= 9 || 0xB || 0xC || >= 0xE && <= 0x1F || 0x7F:
            error(
              'unexpected control character 0x${character.codeUnits.single.toRadixString(16)}',
              line,
              column,
            );
          case 0xa:
            endLine();
          case 0xd:
          case 0x20:
            break;
          case 0x21:
            state = .bang;
          case 0x22:
            state = .doubleQuotedString;
          case 0x28 || // (
              0x29 || // )
              0x2C || // ,
              0x2E || // .
              0x3A || // :
              0x3B || // ;
              0x3F || // ?
              >= 0x5B && <= 0x5D || // [\]
              0x60 || // `
              0x7B || // {
              0x7D: // }
            yield SymbolToken(line, column, character);
          case 0x25:
            state = .percent;
          case 0x26:
            state = .and;
          case 0x27:
            state = .singleQuotedString;
          case 0x2A:
            state = .asterisk;
          case 0x2B:
            state = .plus;
          case 0x2D:
            state = .minus;
          case 0x2F:
            state = .slash;
          case >= 0x30 && <= 0x39:
            state = .number;
            continue;
          case 0x3C:
            state = .lessThan;
          case 0x3D:
            state = .equals;
          case 0x3E:
            state = .greaterThan;
          case 0x23 || // #
              0x24 || // $
              0x40 || // @
              >= 0x41 && <= 0x5A || // letters
              0x5F || // _
              >= 0x61 && <= 0x7A: // more letters
            state = .identifier;
            continue;
          case 0x5E:
            state = .caret;
          case 0x7C:
            state = .verticalBar;
          case 0x7E:
            state = .tilde;
          case > 0x7F:
            error('unexpected unicode character $character', line, column);
        }
      case .bang:
        if (character == '=') {
          yield SymbolToken(line, column, '!=');
          state = .base;
        } else {
          yield SymbolToken(line, column, '!');
          state = .base;
          continue;
        }
      case .doubleQuotedString:
        if (character == '\\') {
          state = .escapedDoubleQuotedString;
        } else if (character == '"') {
          yield StringToken(line, column, buffer.toString());
          buffer.clear();
          state = .base;
        } else {
          buffer.write(character);
        }
      case .escapedDoubleQuotedString:
        if (character == 'n') {
          buffer.write('\n');
          state = .doubleQuotedString;
        } else if (character == 't') {
          buffer.write('\t');
          state = .doubleQuotedString;
        } else if (character == 'r') {
          buffer.write('\r');
          state = .doubleQuotedString;
        } else if (character == '0') {
          buffer.write('\u0000');
          state = .doubleQuotedString;
        } else if (character == 'u') {
          state = .doubleQuotedStringUnicodeEscape;
        } else {
          buffer.write(character);
          state = .doubleQuotedString;
        }
      case .doubleQuotedStringUnicodeEscape:
        if (character.codeUnits.first < 0x30 ||
            character.codeUnits.first > 0x39) {
          buffer.write(String.fromCharCode(intBuffer));
          intBuffer = 0;
          state = .doubleQuotedString;
          continue;
        } else {
          int value = character.codeUnits.single - 0x30;
          intBuffer = intBuffer * 10 + value;
        }
      case .percent:
        if (character == '=') {
          yield SymbolToken(line, column, '%=');
          state = .base;
        } else {
          yield SymbolToken(line, column, '%');
          state = .base;
          continue;
        }
      case .and:
        if (character == '=') {
          yield SymbolToken(line, column, '&=');
          state = .base;
        } else if (character == '&') {
          state = .andAnd;
        } else {
          yield SymbolToken(line, column, '&');
          state = .base;
          continue;
        }
      case .andAnd:
        if (character == '=') {
          yield SymbolToken(line, column, '&&=');
          state = .base;
        } else {
          yield SymbolToken(line, column, '&&');
          state = .base;
          continue;
        }
      case .singleQuotedString:
        if (character == '\\') {
          state = .escapedSingleQuotedString;
        } else if (character == '\'') {
          yield StringToken(line, column, buffer.toString());
          buffer.clear();
          state = .base;
        } else {
          buffer.write(character);
        }
      case .escapedSingleQuotedString:
        if (character == 'n') {
          buffer.write('\n');
          state = .singleQuotedString;
        } else if (character == 't') {
          buffer.write('\t');
          state = .singleQuotedString;
        } else if (character == 'r') {
          buffer.write('\r');
          state = .singleQuotedString;
        } else if (character == '0') {
          buffer.write('\u0000');
          state = .singleQuotedString;
        } else if (character == 'u') {
          state = .singleQuotedStringUnicodeEscape;
        } else {
          buffer.write(character);
          state = .singleQuotedString;
        }
      case .singleQuotedStringUnicodeEscape:
        if (character.codeUnits.first < 0x30 ||
            character.codeUnits.first > 0x39) {
          buffer.write(String.fromCharCode(intBuffer));
          intBuffer = 0;
          state = .singleQuotedString;
          continue;
        } else {
          int value = character.codeUnits.single - 0x30;
          intBuffer = intBuffer * 10 + value;
        }
      case .asterisk:
        if (character == '=') {
          yield SymbolToken(line, column, '*=');
          state = .base;
        } else {
          yield SymbolToken(line, column, '*');
          state = .base;
          continue;
        }
      case .plus:
        if (character == '=') {
          yield SymbolToken(line, column, '+=');
          state = .base;
        } else {
          yield SymbolToken(line, column, '+');
          state = .base;
          continue;
        }
      case .minus:
        if (character == '=') {
          yield SymbolToken(line, column, '-=');
          state = .base;
        } else {
          yield SymbolToken(line, column, '-');
          state = .base;
          continue;
        }
      case .slash:
        if (character == '=') {
          yield SymbolToken(line, column, '/=');
          state = .base;
        } else {
          yield SymbolToken(line, column, '/');
          state = .base;
          continue;
        }
      case .number:
        if (character.codeUnits.first < 0x30 ||
            character.codeUnits.first > 0x39) {
          yield IntegerToken(line, column, intBuffer);
          intBuffer = 0;
          state = .base;
          continue;
        } else {
          int value = character.codeUnits.single - 0x30;
          intBuffer = intBuffer * 10 + value;
        }
      case .lessThan:
        if (character == '=') {
          yield SymbolToken(line, column, '<=');
          state = .base;
        } else if (character == '<') {
          state = .lessThanLessThan;
        } else if (character == '!') {
          state = .comment;
        } else {
          yield SymbolToken(line, column, '<');
          state = .base;
          continue;
        }
      case .lessThanLessThan:
        if (character == '=') {
          yield SymbolToken(line, column, '<<=');
          state = .base;
        } else {
          yield SymbolToken(line, column, '<<');
          state = .base;
          continue;
        }
      case .comment:
        if (character == '\n') {
          endLine();
        } else if (character == '>') {
          state = .base;
        }
      case .equals:
        if (character == '=') {
          yield SymbolToken(line, column, '==');
          state = .base;
        } else {
          yield SymbolToken(line, column, '=');
          state = .base;
          continue;
        }
      case .greaterThan:
        if (character == '=') {
          yield SymbolToken(line, column, '>=');
          state = .base;
        } else if (character == '>') {
          state = .greaterThanGreaterThan;
        } else if (character == '!') {
          state = .comment;
        } else {
          yield SymbolToken(line, column, '>');
          state = .base;
          continue;
        }
      case .greaterThanGreaterThan:
        if (character == '=') {
          yield SymbolToken(line, column, '>>=');
          state = .base;
        } else {
          yield SymbolToken(line, column, '>>');
          state = .base;
          continue;
        }
      case .identifier:
        if (character.codeUnits.length > 1) {
          error('unexpected character $character', line, column);
        }
        switch (file[i].codeUnits.single) {
          case 0x23 || // #
              0x24 || // $
              0x40 || // @
              >= 0x41 && <= 0x5A || // letters
              0x5F || // _
              >= 0x61 && <= 0x7A ||
              >= 0x30 && <= 0x39:
            buffer.write(character);
          default:
            yield IdentifierToken(line, column, buffer.toString());
            buffer.clear();
            state = .base;
            continue;
        }
      case .caret:
        if (character == '=') {
          yield SymbolToken(line, column, '^=');
          state = .base;
        } else {
          yield SymbolToken(line, column, '^');
          state = .base;
          continue;
        }
      case .verticalBar:
        if (character == '=') {
          yield SymbolToken(line, column, '|=');
          state = .base;
        } else if (character == '|') {
          state = .verticalBarVerticalBar;
        } else {
          yield SymbolToken(line, column, '|');
          state = .base;
          continue;
        }
      case .verticalBarVerticalBar:
        if (character == '=') {
          yield SymbolToken(line, column, '||=');
          state = .base;
        } else {
          yield SymbolToken(line, column, '||');
          state = .base;
          continue;
        }
      case .tilde:
        if (character == '/') {
          state = .tildeSlash;
        } else {
          yield SymbolToken(line, column, '~');
          state = .base;
          continue;
        }
      case .tildeSlash:
        if (character == '=') {
          yield SymbolToken(line, column, '~/=');
          state = .base;
        } else {
          yield SymbolToken(line, column, '~/');
          state = .base;
          continue;
        }
    }
    column++;
    i++;
  }

  switch (state) {
    case .doubleQuotedString:
    case .escapedDoubleQuotedString:
    case .doubleQuotedStringUnicodeEscape:
    case .singleQuotedString:
    case .escapedSingleQuotedString:
    case .singleQuotedStringUnicodeEscape:
      error('incomplete string', startLine, startColumn);
    case .comment:
      error('incomplete comment', startLine, startColumn);
    case .number:
      yield IntegerToken(line, column, intBuffer);
    case .identifier:
      yield IdentifierToken(line, column, buffer.toString());
    case .bang:
      yield SymbolToken(line, column, '!');
    case .percent:
      yield SymbolToken(line, column, '%');
    case .and:
      yield SymbolToken(line, column, '&');
    case .andAnd:
      yield SymbolToken(line, column, '&&');
    case .asterisk:
      yield SymbolToken(line, column, '*');
    case .plus:
      yield SymbolToken(line, column, '+');
    case .minus:
      yield SymbolToken(line, column, '-');
    case .slash:
      yield SymbolToken(line, column, '/');
    case .lessThan:
      yield SymbolToken(line, column, '<');
    case .lessThanLessThan:
      yield SymbolToken(line, column, '<<');
    case .equals:
      yield SymbolToken(line, column, '=');
    case .greaterThan:
      yield SymbolToken(line, column, '>');
    case .greaterThanGreaterThan:
      yield SymbolToken(line, column, '>>');
    case .caret:
      yield SymbolToken(line, column, '^');
    case .verticalBar:
      yield SymbolToken(line, column, '|');
    case .verticalBarVerticalBar:
      yield SymbolToken(line, column, '||');
    case .tilde:
      yield SymbolToken(line, column, '~');
    case .tildeSlash:
      yield SymbolToken(line, column, '~/');
    case .base:
  }
  yield EOFToken(line, column);
}

void error(String error, int line, int column) {}

class TokenReader {
  final Iterator<Token> iterator;
  final List<ParseError> parseErrors;
  Token readToken() {
    return (iterator..moveNext()).current;
  }

  String? readSymbol() =>
      castToken<SymbolToken>(readToken(), 'symbol', parseErrors)?.symbol;
  String? readIdentifier() =>
      castToken<IdentifierToken>(readToken(), 'identifier', parseErrors)?.identifier;
  String? readString() =>
      castToken<StringToken>(readToken(), 'string', parseErrors)?.string;
  int? readInteger() =>
      castToken<IntegerToken>(readToken(), 'integer', parseErrors)?.integer;

  TokenReader(Iterable<Token> iterable, this.parseErrors) : iterator = iterable.iterator;
}

T? castToken<T extends Token>(final Token token, String expected, List<ParseError> parseErrors) {
  if (token is T) {
    return token;
  } else {
    parseErrors.add(ParseError(
      token.line,
      token.column,
      'Expected $expected but got $token',
    ));
    return null;
  }
}
