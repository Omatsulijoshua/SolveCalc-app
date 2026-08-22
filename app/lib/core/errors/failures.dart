abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class CalculationFailure extends Failure {
  const CalculationFailure(super.message);
}

class DivisionByZeroFailure extends CalculationFailure {
  const DivisionByZeroFailure() : super('Cannot divide by zero.');
}

class DomainFailure extends CalculationFailure {
  const DomainFailure(super.message);
}

class SyntaxFailure extends CalculationFailure {
  const SyntaxFailure([super.message = 'Invalid expression.']);
}

class ParenthesisMismatchFailure extends CalculationFailure {
  const ParenthesisMismatchFailure() : super('Unmatched parentheses.');
}

class OverflowFailure extends CalculationFailure {
  const OverflowFailure() : super('Result overflow.');
}

class OCRFailure extends Failure {
  const OCRFailure(super.message);
}

class AISolverFailure extends Failure {
  const AISolverFailure(super.message);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}
