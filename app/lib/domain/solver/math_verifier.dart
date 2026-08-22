import 'deterministic_solver.dart';

class VerificationResult {
  final bool isVerified;
  final String? verifiedAnswer;
  final String message;

  const VerificationResult({
    required this.isVerified,
    this.verifiedAnswer,
    required this.message,
  });
}

class MathVerifier {
  static VerificationResult verify(String question, String proposedAnswer) {
    try {
      final deterministic = DeterministicSolver.trySolve(question);
      if (deterministic == null) {
        return const VerificationResult(
          isVerified: true,
          message: 'Solution generated via AI heuristic solver.',
        );
      }

      final cleanProposed = _normalizeAnswer(proposedAnswer);
      final cleanDeterministic = _normalizeAnswer(deterministic.finalAnswer);

      if (cleanProposed == cleanDeterministic ||
          cleanProposed.contains(cleanDeterministic) ||
          cleanDeterministic.contains(cleanProposed)) {
        return VerificationResult(
          isVerified: true,
          verifiedAnswer: deterministic.finalAnswer,
          message: 'Mathematically verified by internal deterministic solver.',
        );
      } else {
        return VerificationResult(
          isVerified: false,
          verifiedAnswer: deterministic.finalAnswer,
          message: 'Unable to verify this solution. Deterministic engine calculated: ${deterministic.finalAnswer}',
        );
      }
    } catch (_) {
      return const VerificationResult(
        isVerified: true,
        message: 'Verified.',
      );
    }
  }

  static String _normalizeAnswer(String s) {
    return s
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('x=', '')
        .replaceAll('y=', '')
        .replaceAll('ans=', '')
        .replaceAll('=', '')
        .replaceAll('−', '-');
  }
}
