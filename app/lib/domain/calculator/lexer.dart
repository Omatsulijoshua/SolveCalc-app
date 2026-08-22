import '../../core/errors/failures.dart';
import 'token.dart';

class Lexer {
  final String source;
  int _position = 0;

  Lexer(this.source);

  List<Token> tokenize() {
    final rawTokens = <Token>[];

    while (_position < source.length) {
      final char = source[_position];

      // Skip whitespace
      if (_isWhitespace(char)) {
        _position++;
        continue;
      }

      // Numbers & scientific notation
      if (_isDigit(char) || (char == '.' && _peekNextIsDigit())) {
        rawTokens.add(_readNumber());
        continue;
      }

      // Identifiers (functions and constants)
      if (_isAlpha(char) || char == 'π') {
        rawTokens.add(_readIdentifier());
        continue;
      }

      // Root symbols
      if (char == '√') {
        rawTokens.add(Token(
          type: TokenType.identifier,
          text: 'sqrt',
          position: _position++,
        ));
        continue;
      }

      if (char == '∛') {
        rawTokens.add(Token(
          type: TokenType.identifier,
          text: 'cbrt',
          position: _position++,
        ));
        continue;
      }

      // Powers: ² and ³
      if (char == '²') {
        rawTokens.add(Token(type: TokenType.power, text: '^', position: _position++));
        rawTokens.add(Token(type: TokenType.number, text: '2', value: 2, position: _position));
        continue;
      }
      if (char == '³') {
        rawTokens.add(Token(type: TokenType.power, text: '^', position: _position++));
        rawTokens.add(Token(type: TokenType.number, text: '3', value: 3, position: _position));
        continue;
      }

      // Single character operators
      switch (char) {
        case '+':
          rawTokens.add(Token(type: TokenType.plus, text: '+', position: _position++));
          break;
        case '-':
        case '−':
          rawTokens.add(Token(type: TokenType.minus, text: '-', position: _position++));
          break;
        case '*':
        case '×':
          rawTokens.add(Token(type: TokenType.multiply, text: '*', position: _position++));
          break;
        case '/':
        case '÷':
          rawTokens.add(Token(type: TokenType.divide, text: '/', position: _position++));
          break;
        case '^':
          rawTokens.add(Token(type: TokenType.power, text: '^', position: _position++));
          break;
        case '%':
          rawTokens.add(Token(type: TokenType.percent, text: '%', position: _position++));
          break;
        case '!':
          rawTokens.add(Token(type: TokenType.factorial, text: '!', position: _position++));
          break;
        case '(':
          rawTokens.add(Token(type: TokenType.openParen, text: '(', position: _position++));
          break;
        case ')':
          rawTokens.add(Token(type: TokenType.closeParen, text: ')', position: _position++));
          break;
        case ',':
          rawTokens.add(Token(type: TokenType.comma, text: ',', position: _position++));
          break;
        default:
          throw SyntaxFailure('Unexpected character: "$char" at position $_position');
      }
    }

    rawTokens.add(Token(type: TokenType.eof, text: '', position: _position));

    // Insert implicit multiplications and disambiguate unary plus/minus
    return _processTokens(rawTokens);
  }

  List<Token> _processTokens(List<Token> tokens) {
    final processed = <Token>[];

    for (int i = 0; i < tokens.length; i++) {
      final current = tokens[i];
      final prev = i > 0 ? tokens[i - 1] : null;

      // Disambiguate Unary Plus / Minus
      if (current.type == TokenType.minus || current.type == TokenType.plus) {
        final isUnary = prev == null ||
            prev.type == TokenType.plus ||
            prev.type == TokenType.minus ||
            prev.type == TokenType.multiply ||
            prev.type == TokenType.divide ||
            prev.type == TokenType.power ||
            prev.type == TokenType.modulo ||
            prev.type == TokenType.openParen ||
            prev.type == TokenType.comma ||
            prev.type == TokenType.unaryMinus ||
            prev.type == TokenType.unaryPlus;

        if (isUnary) {
          final unaryType = current.type == TokenType.minus
              ? TokenType.unaryMinus
              : TokenType.unaryPlus;
          processed.add(Token(
            type: unaryType,
            text: current.text,
            position: current.position,
          ));
          continue;
        }
      }

      // Check if we need to insert implicit multiplication before current token
      if (prev != null && _shouldInsertImplicitMultiplication(prev, current)) {
        processed.add(Token(
          type: TokenType.multiply,
          text: '*',
          position: current.position,
        ));
      }

      processed.add(current);
    }

    return processed;
  }

  bool _shouldInsertImplicitMultiplication(Token prev, Token current) {
    final prevCanEnd = prev.type == TokenType.number ||
        prev.type == TokenType.closeParen ||
        prev.type == TokenType.factorial ||
        prev.type == TokenType.percent ||
        (prev.type == TokenType.identifier && (prev.text == 'pi' || prev.text == 'e'));

    final currentCanStart = current.type == TokenType.number ||
        current.type == TokenType.openParen ||
        current.type == TokenType.identifier;

    // Cases:
    // 2(3) -> 2 * (3)
    // (2)(3) -> (2) * (3)
    // (2)3 -> (2) * 3
    // 2pi -> 2 * pi
    // 2sin(30) -> 2 * sin(30)
    // pi sin(30) -> pi * sin(30)
    // 5! 2 -> 5! * 2
    return prevCanEnd && currentCanStart;
  }

  Token _readNumber() {
    final start = _position;
    bool hasDecimal = false;

    while (_position < source.length) {
      final char = source[_position];
      if (_isDigit(char)) {
        _position++;
      } else if (char == '.' && !hasDecimal) {
        hasDecimal = true;
        _position++;
      } else {
        break;
      }
    }

    // Check for scientific notation: e or E followed by optional +/- and digits
    if (_position < source.length &&
        (source[_position] == 'e' || source[_position] == 'E')) {
      final nextPos = _position + 1;
      if (nextPos < source.length) {
        final nextChar = source[nextPos];
        if (_isDigit(nextChar) ||
            ((nextChar == '+' || nextChar == '-') &&
                nextPos + 1 < source.length &&
                _isDigit(source[nextPos + 1]))) {
          _position++; // consume 'e'
          if (source[_position] == '+' || source[_position] == '-') {
            _position++; // consume sign
          }
          while (_position < source.length && _isDigit(source[_position])) {
            _position++;
          }
        }
      }
    }

    final text = source.substring(start, _position);
    final value = num.tryParse(text);
    if (value == null) {
      throw SyntaxFailure('Invalid number format: "$text"');
    }

    return Token(
      type: TokenType.number,
      text: text,
      value: value,
      position: start,
    );
  }

  Token _readIdentifier() {
    final start = _position;

    if (source[_position] == 'π') {
      _position++;
      return Token(
        type: TokenType.identifier,
        text: 'pi',
        position: start,
      );
    }

    while (_position < source.length && _isAlpha(source[_position])) {
      _position++;
    }

    final text = source.substring(start, _position).toLowerCase();
    return Token(
      type: TokenType.identifier,
      text: text,
      position: start,
    );
  }

  bool _isDigit(String char) => char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;

  bool _isAlpha(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }

  bool _isWhitespace(String char) =>
      char == ' ' || char == '\t' || char == '\n' || char == '\r';

  bool _peekNextIsDigit() {
    if (_position + 1 < source.length) {
      return _isDigit(source[_position + 1]);
    }
    return false;
  }
}
