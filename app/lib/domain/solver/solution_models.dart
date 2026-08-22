class SolutionStep {
  final int stepNumber;
  final String title;
  final String explanation;
  final String whyExplanation; // Learn Mode explanation
  final String equation;

  const SolutionStep({
    required this.stepNumber,
    required this.title,
    required this.explanation,
    required this.whyExplanation,
    required this.equation,
  });

  Map<String, dynamic> toJson() => {
        'stepNumber': stepNumber,
        'title': title,
        'explanation': explanation,
        'whyExplanation': whyExplanation,
        'equation': equation,
      };

  factory SolutionStep.fromJson(Map<String, dynamic> json) => SolutionStep(
        stepNumber: json['stepNumber'] as int? ?? 1,
        title: json['title'] as String? ?? '',
        explanation: json['explanation'] as String? ?? '',
        whyExplanation: json['whyExplanation'] as String? ?? json['explanation'] as String? ?? '',
        equation: json['equation'] as String? ?? '',
      );
}

class SolveResult {
  final String id;
  final String originalQuestion;
  final String questionType; // 'linear_equation', 'quadratic_equation', 'system_of_equations', 'arithmetic', 'calculus', 'general'
  final String finalAnswer;
  final List<SolutionStep> steps;
  final bool isVerified;
  final String? verificationDetails;
  final DateTime timestamp;

  const SolveResult({
    required this.id,
    required this.originalQuestion,
    required this.questionType,
    required this.finalAnswer,
    required this.steps,
    required this.isVerified,
    this.verificationDetails,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'originalQuestion': originalQuestion,
        'questionType': questionType,
        'finalAnswer': finalAnswer,
        'steps': steps.map((s) => s.toJson()).toList(),
        'isVerified': isVerified,
        'verificationDetails': verificationDetails,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SolveResult.fromJson(Map<String, dynamic> json) => SolveResult(
        id: json['id'] as String? ?? '',
        originalQuestion: json['originalQuestion'] as String? ?? '',
        questionType: json['questionType'] as String? ?? 'general',
        finalAnswer: json['finalAnswer'] as String? ?? '',
        steps: (json['steps'] as List<dynamic>? ?? [])
            .map((s) => SolutionStep.fromJson(s as Map<String, dynamic>))
            .toList(),
        isVerified: json['isVerified'] as bool? ?? false,
        verificationDetails: json['verificationDetails'] as String?,
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}
