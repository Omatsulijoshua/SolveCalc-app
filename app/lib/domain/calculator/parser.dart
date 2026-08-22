import '../../core/errors/failures.dart';
import 'ast.dart';
import 'token.dart';

class Parser {
  final List<Token> tokens;
  int _current = 0;

  Parser(this.tokens);

  ASTNode parse() {
    if (_isAtEnd()) {
      throw const SyntaxFailure('Empty expression.');
    }
    final result = _parseExpression();
    if (!_isAtEnd()) {
      throw SyntaxFailure(
          'Unexpected token "${_peek().text}" at position ${_peek().position}');
    }
    return result;
  }

  ASTNode _parseExpression() {
    return _parseAdditive();
  }

  ASTNode _parseAdditive() {
    var left = _parseMultiplicative();

    while (!_isAtEnd()) {
      if (_match(TokenType.plus)) {
        final right = _parseMultiplicative();
        left = BinaryOpNode(TokenType.plus, left, right);
      } else if (_match(TokenType.minus)) {
        final right = _parseMultiplicative();
        left = BinaryOpNode(TokenType.minus, left, right);
      } else {
        break;
      }
    }

    return left;
  }

  ASTNode _parseMultiplicative() {
    var left = _parseExponential();

    while (!_isAtEnd()) {
      if (_match(TokenType.multiply)) {
        final right = _parseExponential();
        left = BinaryOpNode(TokenType.multiply, left, right);
      } else if (_match(TokenType.divide)) {
        final right = _parseExponential();
        left = BinaryOpNode(TokenType.divide, left, right);
      } else if (_match(TokenType.modulo)) {
        final right = _parseExponential();
        left = BinaryOpNode(TokenType.modulo, left, right);
      } else {
        break;
      }
    }

    return left;
  }

  ASTNode _parseExponential() {
    final left = _parseUnary();

    if (_match(TokenType.power)) {
      // Right-associative: 2^3^2 = 2^(3^2) = 512
      final right = _parseExponential();
      return BinaryOpNode(TokenType.power, left, right);
    }

    return left;
  }

  ASTNode _parseUnary() {
    if (_match(TokenType.unaryMinus)) {
      final operand = _parseUnary();
      return UnaryOpNode(TokenType.unaryMinus, operand);
    }
    if (_match(TokenType.unaryPlus)) {
      final operand = _parseUnary();
      return UnaryOpNode(TokenType.unaryPlus, operand);
    }
    return _parsePostfix();
  }

  ASTNode _parsePostfix() {
    var node = _parsePrimary();

    while (!_isAtEnd()) {
      if (_match(TokenType.factorial)) {
        node = PostfixOpNode(TokenType.factorial, node);
      } else if (_match(TokenType.percent)) {
        node = PostfixOpNode(TokenType.percent, node);
      } else {
        break;
      }
    }

    return node;
  }

  ASTNode _parsePrimary() {
    if (_isAtEnd()) {
      throw const SyntaxFailure('Unexpected end of expression.');
    }

    // Number literal
    if (_peek().type == TokenType.number) {
      final token = _advance();
      return NumberNode(token.value!);
    }

    // Identifiers (functions or constants)
    if (_peek().type == TokenType.identifier) {
      final token = _advance();
      final name = token.text.toLowerCase();

      // Constants
      if (name == 'pi' || name == 'e') {
        return ConstantNode(name);
      }

      // Modulo keyword
      if (name == 'mod') {
        throw const SyntaxFailure('Unexpected "mod" operator in operand position.');
      }

      // Function call with parentheses: e.g. sin(30)
      if (_match(TokenType.openParen)) {
        final args = <ASTNode>[];
        if (!_check(TokenType.closeParen)) {
          do {
            args.add(_parseExpression());
          } while (_match(TokenType.comma));
        }
        _consume(TokenType.closeParen, 'Expected ")" after function arguments.');
        return FunctionCallNode(name, args);
      }

      // Function call without parentheses: e.g. sin 30, sqrt 25
      final arg = _parseUnary();
      return FunctionCallNode(name, [arg]);
    }

    // Grouping: ( expression )
    if (_match(TokenType.openParen)) {
      final expr = _parseExpression();
      _consume(TokenType.closeParen, 'Missing closing parenthesis ")".');
      return expr;
    }

    throw SyntaxFailure('Unexpected token "${_peek().text}" at position ${_peek().position}');
  }

  bool _match(TokenType type) {
    if (_check(type)) {
      _advance();
      return true;
    }
    return false;
  }

  bool _check(TokenType type) {
    if (_isAtEnd()) return false;
    return _peek().type == type;
  }

  Token _advance() {
    if (!_isAtEnd()) _current++;
    return _previous();
  }

  bool _isAtEnd() => _peek().type == TokenType.eof;

  Token _peek() => tokens[_current];

  Token _previous() => tokens[_current - 1];

  void _consume(TokenType type, String message) {
    if (_check(type)) {
      _advance();
      return;
    }
    if (type == TokenType.closeParen) {
      throw const ParenthesisMismatchFailure();
    }
    throw SyntaxFailure(message);
  }
}
