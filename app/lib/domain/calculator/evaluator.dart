import 'dart:math' as math;
import '../../core/errors/failures.dart';
import 'ast.dart';
import 'token.dart';

enum AngleMode {
  deg,
  rad,
  grad,
}

class Evaluator {
  final AngleMode angleMode;

  const Evaluator({this.angleMode = AngleMode.deg});

  num evaluate(ASTNode node) {
    if (node is NumberNode) {
      return node.value;
    }

    if (node is ConstantNode) {
      switch (node.name) {
        case 'pi':
          return math.pi;
        case 'e':
          return math.e;
        default:
          throw SyntaxFailure('Unknown constant: "${node.name}"');
      }
    }

    if (node is UnaryOpNode) {
      final val = evaluate(node.operand);
      if (node.op == TokenType.unaryMinus) {
        return -val;
      } else if (node.op == TokenType.unaryPlus) {
        return val;
      }
      throw SyntaxFailure('Unknown unary operator: ${node.op}');
    }

    if (node is PostfixOpNode) {
      final val = evaluate(node.operand);
      if (node.op == TokenType.factorial) {
        return _factorial(val);
      } else if (node.op == TokenType.percent) {
        return val / 100.0;
      }
      throw SyntaxFailure('Unknown postfix operator: ${node.op}');
    }

    if (node is BinaryOpNode) {
      final left = evaluate(node.left);
      final right = evaluate(node.right);

      switch (node.op) {
        case TokenType.plus:
          return left + right;
        case TokenType.minus:
          return left - right;
        case TokenType.multiply:
          return left * right;
        case TokenType.divide:
          if (right == 0) {
            throw const DivisionByZeroFailure();
          }
          return left / right;
        case TokenType.modulo:
          if (right == 0) {
            throw const DivisionByZeroFailure();
          }
          return left % right;
        case TokenType.power:
          if (left < 0 && right != right.toInt()) {
            throw const DomainFailure('Negative base with non-integer exponent is not real.');
          }
          final res = math.pow(left, right);
          if (res.isNaN) {
            throw const DomainFailure('Result is not a real number.');
          }
          return res;
        default:
          throw SyntaxFailure('Unknown binary operator: ${node.op}');
      }
    }

    if (node is FunctionCallNode) {
      return _evaluateFunction(node.name, node.args);
    }

    throw const SyntaxFailure('Unrecognized AST node.');
  }

  num _evaluateFunction(String name, List<ASTNode> args) {
    if (args.isEmpty) {
      throw SyntaxFailure('Function "$name" requires arguments.');
    }

    final evalArgs = args.map((a) => evaluate(a)).toList();
    final x = evalArgs[0];

    switch (name) {
      // Trigonometry
      case 'sin':
        final rad = _toRadians(x);
        final res = math.sin(rad);
        return _cleanFloat(res);

      case 'cos':
        final rad = _toRadians(x);
        final res = math.cos(rad);
        return _cleanFloat(res);

      case 'tan':
        final rad = _toRadians(x);
        // Check for singularity at odd multiples of pi/2
        final normalizedDeg = ((x % 360) + 360) % 360;
        if (angleMode == AngleMode.deg && (normalizedDeg == 90 || normalizedDeg == 270)) {
          throw const DomainFailure('Tangent is undefined.');
        }
        final res = math.tan(rad);
        return _cleanFloat(res);

      // Inverse Trigonometry
      case 'asin':
        if (x < -1 || x > 1) {
          throw const DomainFailure('Arcsine argument must be in [-1, 1].');
        }
        final rad = math.asin(x);
        return _cleanFloat(_fromRadians(rad));

      case 'acos':
        if (x < -1 || x > 1) {
          throw const DomainFailure('Arccosine argument must be in [-1, 1].');
        }
        final rad = math.acos(x);
        return _cleanFloat(_fromRadians(rad));

      case 'atan':
        final rad = math.atan(x);
        return _cleanFloat(_fromRadians(rad));

      // Hyperbolic
      case 'sinh':
        return _sinh(x);
      case 'cosh':
        return _cosh(x);
      case 'tanh':
        return _tanh(x);

      // Logarithmic
      case 'log':
        if (x <= 0) {
          throw const DomainFailure('Logarithm undefined for non-positive numbers.');
        }
        if (evalArgs.length > 1) {
          final base = evalArgs[1];
          if (base <= 0 || base == 1) {
            throw const DomainFailure('Logarithm base must be positive and not equal to 1.');
          }
          return math.log(x) / math.log(base);
        }
        return _cleanFloat(math.log(x) / math.ln10);

      case 'ln':
        if (x <= 0) {
          throw const DomainFailure('Natural log undefined for non-positive numbers.');
        }
        return _cleanFloat(math.log(x));

      case 'log2':
        if (x <= 0) {
          throw const DomainFailure('Log2 undefined for non-positive numbers.');
        }
        return _cleanFloat(math.log(x) / math.ln2);

      // Roots & Powers
      case 'sqrt':
        if (x < 0) {
          throw const DomainFailure('Square root of negative number is not a real number.');
        }
        return _cleanFloat(math.sqrt(x));

      case 'cbrt':
        if (x < 0) {
          return -_cleanFloat(math.pow(-x, 1 / 3));
        }
        return _cleanFloat(math.pow(x, 1 / 3));

      case 'nthroot':
      case 'root':
        if (evalArgs.length < 2) {
          throw const SyntaxFailure('nthRoot requires 2 arguments: nthRoot(x, n)');
        }
        final n = evalArgs[1];
        if (n == 0) throw const DivisionByZeroFailure();
        if (x < 0 && n % 2 == 0) {
          throw const DomainFailure('Even root of negative number is not real.');
        }
        if (x < 0) {
          return -math.pow(-x, 1 / n);
        }
        return math.pow(x, 1 / n);

      // Other
      case 'abs':
        return x.abs();

      case 'exp':
        return math.exp(x);

      case 'fact':
        return _factorial(x);

      case 'inv':
      case 'reciprocal':
        if (x == 0) throw const DivisionByZeroFailure();
        return 1.0 / x;

      default:
        throw SyntaxFailure('Unknown function: "$name"');
    }
  }

  double _toRadians(num value) {
    switch (angleMode) {
      case AngleMode.deg:
        return value * (math.pi / 180.0);
      case AngleMode.rad:
        return value.toDouble();
      case AngleMode.grad:
        return value * (math.pi / 200.0);
    }
  }

  double _fromRadians(double rad) {
    switch (angleMode) {
      case AngleMode.deg:
        return rad * (180.0 / math.pi);
      case AngleMode.rad:
        return rad;
      case AngleMode.grad:
        return rad * (200.0 / math.pi);
    }
  }

  num _factorial(num n) {
    if (n < 0) {
      throw const DomainFailure('Factorial undefined for negative numbers.');
    }
    if (n != n.toInt()) {
      throw const DomainFailure('Factorial currently supported for non-negative integers.');
    }
    final intVal = n.toInt();
    if (intVal > 170) {
      throw const OverflowFailure();
    }
    if (intVal == 0 || intVal == 1) return 1;

    double result = 1.0;
    for (int i = 2; i <= intVal; i++) {
      result *= i;
    }
    return result;
  }

  double _sinh(num x) => (math.exp(x) - math.exp(-x)) / 2;
  double _cosh(num x) => (math.exp(x) + math.exp(-x)) / 2;
  double _tanh(num x) => _sinh(x) / _cosh(x);

  num _cleanFloat(num value) {
    if (value.abs() < 1e-15) return 0;
    final fixed = double.parse(value.toStringAsPrecision(14));
    if ((fixed - fixed.round()).abs() < 1e-12) {
      return fixed.round();
    }
    return fixed;
  }
}
