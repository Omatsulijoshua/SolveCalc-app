import '../../core/errors/failures.dart';
import '../../core/utilities/math_formatter.dart';
import 'evaluator.dart';
import 'lexer.dart';
import 'parser.dart';

class CalculationResult {
  final bool isSuccess;
  final num? value;
  final String? formattedResult;
  final String? errorMessage;

  const CalculationResult.success(this.value, this.formattedResult)
      : isSuccess = true,
        errorMessage = null;

  const CalculationResult.failure(this.errorMessage)
      : isSuccess = false,
        value = null,
        formattedResult = null;
}

class CalculatorEngine {
  static num calculate(String expression, {AngleMode angleMode = AngleMode.deg}) {
    final sanitized = MathFormatter.sanitizeExpression(expression.trim());
    if (sanitized.isEmpty) {
      throw const SyntaxFailure('Empty expression.');
    }

    final lexer = Lexer(sanitized);
    final tokens = lexer.tokenize();
    final parser = Parser(tokens);
    final ast = parser.parse();
    final evaluator = Evaluator(angleMode: angleMode);
    return evaluator.evaluate(ast);
  }

  static CalculationResult tryCalculate(
    String expression, {
    AngleMode angleMode = AngleMode.deg,
    int maxPrecision = 10,
  }) {
    try {
      final value = calculate(expression, angleMode: angleMode);
      final formatted = MathFormatter.formatResult(value, maxPrecision: maxPrecision);
      return CalculationResult.success(value, formatted);
    } on Failure catch (f) {
      return CalculationResult.failure(f.message);
    } catch (e) {
      return CalculationResult.failure('Invalid expression.');
    }
  }

  static bool isValid(String expression, {AngleMode angleMode = AngleMode.deg}) {
    try {
      calculate(expression, angleMode: angleMode);
      return true;
    } catch (_) {
      return false;
    }
  }
}
