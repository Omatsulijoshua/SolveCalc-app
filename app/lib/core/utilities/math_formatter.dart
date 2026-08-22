class MathFormatter {
  static String formatResult(num value, {int maxPrecision = 10}) {
    if (value.isNaN) return 'Error';
    if (value.isInfinite) return value.isNegative ? '-Infinity' : 'Infinity';

    // Exact integers
    if (value == value.roundToDouble() && value.abs() < 1e14) {
      return value.toInt().toString();
    }

    // Very large or very small numbers -> scientific notation
    final absVal = value.abs();
    if ((absVal >= 1e12 || (absVal < 1e-6 && absVal > 0))) {
      final expStr = value.toStringAsExponential(6);
      return expStr.replaceAll('e+', 'e');
    }

    // Standard decimal formatting
    String str = value.toStringAsPrecision(maxPrecision);
    // Remove trailing zeros after decimal point
    if (str.contains('.')) {
      str = str.replaceFirst(RegExp(r'\.?0+$'), '');
    }
    // Convert -0 or -0.0 to 0
    if (str == '-0' || str == '-0.0') str = '0';
    return str;
  }

  /// Automatically appends matching closing parentheses for any unclosed open parentheses
  static String autoCloseParentheses(String input) {
    int openCount = 0;
    for (int i = 0; i < input.length; i++) {
      if (input[i] == '(') openCount++;
      if (input[i] == ')') {
        if (openCount > 0) {
          openCount--;
        }
      }
    }
    if (openCount > 0) {
      return input + (')' * openCount);
    }
    return input;
  }

  static String sanitizeExpression(String input) {
    final formatted = input
        .replaceAll('×', '*')
        .replaceAll('−', '-')
        .replaceAll('÷', '/')
        .replaceAll('²', '^2')
        .replaceAll('³', '^3')
        .replaceAll('π', 'pi');
    return autoCloseParentheses(formatted.trim());
  }

  static String prettifyExpression(String input) {
    return input
        .replaceAll('*', ' × ')
        .replaceAll('-', ' − ')
        .replaceAll('+', ' + ')
        .replaceAll('/', ' ÷ ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
