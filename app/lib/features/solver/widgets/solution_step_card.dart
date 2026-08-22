import 'package:flutter/material.dart';
import '../../../core/theme/theme_presets.dart';
import '../../../domain/solver/solution_models.dart';
import '../../../presentation/providers/solver_provider.dart';

class SolutionStepCard extends StatelessWidget {
  final SolutionStep step;
  final ExplanationMode mode;
  final CalculatorThemeConfig theme;

  const SolutionStepCard({
    super.key,
    required this.step,
    required this.mode,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.operatorButtonColor.withAlpha(60)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(theme.isDark ? 30 : 10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'STEP ${step.stepNumber}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimaryColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Primary Step Explanation
          Text(
            step.explanation,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: theme.textPrimaryColor.withAlpha(220),
            ),
          ),

          // Equation Box
          if (step.equation.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.backgroundColor.withAlpha(180),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.primaryColor.withAlpha(40)),
              ),
              child: Text(
                step.equation,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  color: theme.accentColor,
                ),
              ),
            ),
          ],

          // Learn Mode "Why" section
          if (mode == ExplanationMode.learnMode && step.whyExplanation.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981).withAlpha(80)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'WHY THIS STEP?',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step.whyExplanation,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            color: theme.textPrimaryColor.withAlpha(230),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
