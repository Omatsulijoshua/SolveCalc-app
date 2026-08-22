import 'package:flutter_test/flutter_test.dart';
import 'package:solve_calc/domain/solver/deterministic_solver.dart';

void main() {
  group('Linear Equations', () {
    test('Solve 2x + 5 = 15 -> x = 5', () {
      final res = DeterministicSolver.trySolve('2x + 5 = 15');
      expect(res, isNotNull);
      expect(res!.finalAnswer, 'x = 5');
      expect(res.steps.isNotEmpty, true);
      expect(res.isVerified, true);
    });

    test('Solve 3x + 9 = 18 -> x = 3', () {
      final res = DeterministicSolver.trySolve('3x + 9 = 18');
      expect(res, isNotNull);
      expect(res!.finalAnswer, 'x = 3');
      expect(res.steps.length, greaterThanOrEqualTo(2));
    });

    test('Solve 5x - 10 = 0 -> x = 2', () {
      final res = DeterministicSolver.trySolve('5x - 10 = 0');
      expect(res, isNotNull);
      expect(res!.finalAnswer, 'x = 2');
    });
  });

  group('Quadratic Equations', () {
    test('Solve x^2 + 5x + 6 = 0 -> x = -2, x = -3', () {
      final res = DeterministicSolver.trySolve('x^2 + 5x + 6 = 0');
      expect(res, isNotNull);
      expect(res!.finalAnswer, contains('-2'));
      expect(res.finalAnswer, contains('-3'));
      expect(res.steps.any((s) => s.title.contains('Discriminant')), true);
    });

    test('Solve x^2 - 4 = 0 -> x = 2, x = -2', () {
      final res = DeterministicSolver.trySolve('x^2 - 4 = 0');
      expect(res, isNotNull);
      expect(res!.finalAnswer, contains('2'));
      expect(res.finalAnswer, contains('-2'));
    });
  });

  group('Systems of Equations', () {
    test('Solve 2x + y = 7, x - y = 2 -> x = 3, y = 1', () {
      final res = DeterministicSolver.trySolve('2x + y = 7\nx - y = 2');
      expect(res, isNotNull);
      expect(res!.finalAnswer, 'x = 3,  y = 1');
      expect(res.isVerified, true);
    });
  });
}
