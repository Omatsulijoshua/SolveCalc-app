import 'package:flutter_test/flutter_test.dart';
import 'package:solve_calc/domain/calculator/calculator_engine.dart';
import 'package:solve_calc/domain/calculator/evaluator.dart';

void main() {
  group('Basic Calculator Arithmetic & Precedence', () {
    test('2 + 3 = 5', () {
      expect(CalculatorEngine.calculate('2 + 3'), 5);
    });

    test('10 - 4 = 6', () {
      expect(CalculatorEngine.calculate('10 - 4'), 6);
    });

    test('2 + 3 * 4 = 14 (precedence over left-to-right)', () {
      expect(CalculatorEngine.calculate('2 + 3 * 4'), 14);
    });

    test('2 + 3 × 4 = 14 (unicode multiplication symbol)', () {
      expect(CalculatorEngine.calculate('2 + 3 × 4'), 14);
    });

    test('10 / 2 = 5', () {
      expect(CalculatorEngine.calculate('10 / 2'), 5);
    });

    test('10 ÷ 2 = 5 (unicode division symbol)', () {
      expect(CalculatorEngine.calculate('10 ÷ 2'), 5);
    });

    test('(5 + 3) * 7 = 56', () {
      expect(CalculatorEngine.calculate('(5 + 3) * 7'), 56);
    });

    test('Negative numbers and unary minus: -5 + 10 = 5', () {
      expect(CalculatorEngine.calculate('-5 + 10'), 5);
    });

    test('Parentheses with unary minus: -(3 + 2) = -5', () {
      expect(CalculatorEngine.calculate('-(3 + 2)'), -5);
    });

    test('Scientific notation: 1.5e3 = 1500', () {
      expect(CalculatorEngine.calculate('1.5e3'), 1500);
    });

    test('Percentages: 50% = 0.5', () {
      expect(CalculatorEngine.calculate('50%'), 0.5);
    });

    test('Percentages in arithmetic: 200 * 15% = 30', () {
      expect(CalculatorEngine.calculate('200 * 15%'), 30);
    });
  });

  group('Implicit Multiplication', () {
    test('2(3 + 4) = 14', () {
      expect(CalculatorEngine.calculate('2(3 + 4)'), 14);
    });

    test('(2 + 3)(4 + 5) = 45', () {
      expect(CalculatorEngine.calculate('(2 + 3)(4 + 5)'), 45);
    });

    test('3pi in DEG = 3 * pi', () {
      expect(CalculatorEngine.calculate('3pi'), closeTo(9.42477796, 1e-6));
    });

    test('2sin(30) in DEG = 1', () {
      expect(CalculatorEngine.calculate('2sin(30)'), 1);
    });
  });

  group('Scientific Functions & Constants', () {
    test('Trig in DEG: sin(30) = 0.5', () {
      expect(CalculatorEngine.calculate('sin(30)', angleMode: AngleMode.deg), 0.5);
    });

    test('Trig in DEG: cos(60) = 0.5', () {
      expect(CalculatorEngine.calculate('cos(60)', angleMode: AngleMode.deg), 0.5);
    });

    test('Trig in DEG: tan(45) = 1', () {
      expect(CalculatorEngine.calculate('tan(45)', angleMode: AngleMode.deg), 1);
    });

    test('Trig in RAD: sin(pi / 6) = 0.5', () {
      expect(CalculatorEngine.calculate('sin(pi / 6)', angleMode: AngleMode.rad), closeTo(0.5, 1e-10));
    });

    test('Inverse Trig in DEG: asin(0.5) = 30', () {
      expect(CalculatorEngine.calculate('asin(0.5)', angleMode: AngleMode.deg), closeTo(30, 1e-10));
    });

    test('Square root: sqrt(25) = 5', () {
      expect(CalculatorEngine.calculate('sqrt(25)'), 5);
    });

    test('Square root symbol: √25 = 5', () {
      expect(CalculatorEngine.calculate('√25'), 5);
    });

    test('Cube root symbol: ∛27 = 3', () {
      expect(CalculatorEngine.calculate('∛27'), 3);
    });

    test('Powers: 2^10 = 1024', () {
      expect(CalculatorEngine.calculate('2^10'), 1024);
    });

    test('Unicode powers: 5² = 25', () {
      expect(CalculatorEngine.calculate('5²'), 25);
    });

    test('Unicode cube: 2³ = 8', () {
      expect(CalculatorEngine.calculate('2³'), 8);
    });

    test('Power right-associativity: 2^3^2 = 512', () {
      expect(CalculatorEngine.calculate('2^3^2'), 512);
    });

    test('Logarithms: log(100) = 2', () {
      expect(CalculatorEngine.calculate('log(100)'), 2);
    });

    test('Natural log: ln(e) = 1', () {
      expect(CalculatorEngine.calculate('ln(e)'), 1);
    });

    test('Factorial: 5! = 120', () {
      expect(CalculatorEngine.calculate('5!'), 120);
    });

    test('Factorial: 0! = 1', () {
      expect(CalculatorEngine.calculate('0!'), 1);
    });

    test('Hyperbolic: sinh(0) = 0', () {
      expect(CalculatorEngine.calculate('sinh(0)'), 0);
    });

    test('Hyperbolic: cosh(0) = 1', () {
      expect(CalculatorEngine.calculate('cosh(0)'), 1);
    });
  });

  group('Error Handling', () {
    test('Division by zero throws failure', () {
      final res = CalculatorEngine.tryCalculate('10 / 0');
      expect(res.isSuccess, false);
      expect(res.errorMessage, 'Cannot divide by zero.');
    });

    test('Square root of negative number throws domain failure', () {
      final res = CalculatorEngine.tryCalculate('sqrt(-1)');
      expect(res.isSuccess, false);
      expect(res.errorMessage, contains('not a real number'));
    });

    test('Log of zero throws domain failure', () {
      final res = CalculatorEngine.tryCalculate('log(0)');
      expect(res.isSuccess, false);
      expect(res.errorMessage, contains('undefined'));
    });

    test('Unbalanced parenthesis throws parenthesis failure', () {
      final res = CalculatorEngine.tryCalculate('(2 + 3');
      expect(res.isSuccess, false);
      expect(res.errorMessage, contains('parenthes'));
    });

    test('Invalid syntax throws syntax failure', () {
      final res = CalculatorEngine.tryCalculate('2 + *');
      expect(res.isSuccess, false);
    });
  });
}
