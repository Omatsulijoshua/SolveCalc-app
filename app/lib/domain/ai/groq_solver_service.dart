import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../solver/math_verifier.dart';
import '../solver/solution_models.dart';
import 'ai_solver_service.dart';

class GroqAIService implements AISolverService {
  final String apiKey;
  static const _uuid = Uuid();
  final LocalDeterministicAISolver _fallback = LocalDeterministicAISolver();

  GroqAIService({required this.apiKey});

  static const String _groqChatUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _groqModelsUrl = 'https://api.groq.com/openai/v1/models';

  /// Test whether a provided Groq API Key is valid and active
  static Future<bool> testApiKey(String key) async {
    final cleanKey = key.trim();
    if (cleanKey.isEmpty) {
      throw Exception('API Key cannot be empty.');
    }

    try {
      final response = await http.get(
        Uri.parse(_groqModelsUrl),
        headers: {
          'Authorization': 'Bearer $cleanKey',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid Groq API Key (HTTP 401). Please ensure you copied the entire key starting with "gsk_".');
      } else {
        try {
          final errBody = jsonDecode(response.body);
          final msg = errBody['error']?['message'] ?? 'Status ${response.statusCode}';
          throw Exception(msg);
        } catch (_) {
          throw Exception('Groq API verification failed (HTTP ${response.statusCode}).');
        }
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('Invalid Groq API Key')) {
        rethrow;
      }
      throw Exception('Could not connect to Groq: ${e.toString().replaceAll("Exception: ", "")}');
    }
  }

  /// OCR image-to-math recognition using Groq Vision
  static Future<String> recognizeMathFromImage(String imagePath, String key) async {
    final cleanKey = key.trim();
    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception('Image file not found.');
    }

    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);
    final mimeType = imagePath.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';

    final visionModels = [
      'llama-3.2-11b-vision-preview',
      'llama-3.2-90b-vision-preview',
      'openai/gpt-oss-120b',
    ];

    for (final model in visionModels) {
      try {
        final response = await http.post(
          Uri.parse(_groqChatUrl),
          headers: {
            'Authorization': 'Bearer $cleanKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': model,
            'messages': [
              {
                'role': 'user',
                'content': [
                  {
                    'type': 'text',
                    'text':
                        'Extract ONLY the raw mathematical question or equation from this image. Do not add any greeting, markdown backticks, or extra words. Output only the clean mathematical text (e.g. 2x + 5 = 15 or x^2 + 5x + 6 = 0 or sin(30) + cos(60)).'
                  },
                  {
                    'type': 'image_url',
                    'image_url': {'url': 'data:$mimeType;base64,$base64Image'}
                  }
                ]
              }
            ],
            'temperature': 0.1,
            'max_tokens': 200,
          }),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final choices = data['choices'] as List<dynamic>?;
          if (choices != null && choices.isNotEmpty) {
            final rawText = choices[0]['message']?['content'] as String? ?? '';
            final cleaned = rawText.replaceAll('```', '').trim();
            if (cleaned.isNotEmpty) return cleaned;
          }
        }
      } catch (_) {
        // Try next vision model
      }
    }

    throw Exception('Failed to recognize math from image. Please enter question manually.');
  }

  @override
  Future<SolveResult> solveQuestion(String question, {bool learnMode = true}) async {
    final cleanKey = apiKey.trim();
    if (cleanKey.isEmpty) {
      return _fallback.solveQuestion(question, learnMode: learnMode);
    }

    final prompt = '''
You are SolveCalc, an expert mathematics solver and educational tutor. Solve this mathematical question step-by-step with complete clarity.
Return ONLY valid JSON matching this exact schema:
{
  "questionType": "linear_equation|quadratic_equation|system_of_equations|arithmetic|calculus|trigonometry|general",
  "finalAnswer": "x = ... or numerical result",
  "steps": [
    {
      "stepNumber": 1,
      "title": "Clear step title",
      "explanation": "Clear calculation step explanation",
      "whyExplanation": "Educational explanation of WHY this step was performed (Learn Mode)",
      "equation": "Algebraic or mathematical equation"
    }
  ]
}

Problem: $question
''';

    final modelsToTry = [
      'openai/gpt-oss-120b',
      'openai/gpt-oss-20b',
      'qwen/qwen3.6-27b',
      'llama-3.3-70b-versatile',
      'groq/compound',
    ];

    for (final model in modelsToTry) {
      try {
        final response = await http.post(
          Uri.parse(_groqChatUrl),
          headers: {
            'Authorization': 'Bearer $cleanKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': model,
            'messages': [
              {'role': 'user', 'content': prompt}
            ],
            'temperature': 0.1,
          }),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final choices = data['choices'] as List<dynamic>?;
          if (choices != null && choices.isNotEmpty) {
            String content = choices[0]['message']?['content'] as String? ?? '{}';
            // Clean markdown code blocks if any
            if (content.contains('```json')) {
              content = content.split('```json')[1].split('```')[0].trim();
            } else if (content.contains('```')) {
              content = content.split('```')[1].split('```')[0].trim();
            }

            final parsedJson = jsonDecode(content) as Map<String, dynamic>;
            final stepsList = (parsedJson['steps'] as List<dynamic>? ?? [])
                .map((s) => SolutionStep.fromJson(s as Map<String, dynamic>))
                .toList();

            final proposedAnswer = parsedJson['finalAnswer'] as String? ?? '';
            final verification = MathVerifier.verify(question, proposedAnswer);

            return SolveResult(
              id: _uuid.v4(),
              originalQuestion: question,
              questionType: parsedJson['questionType'] as String? ?? 'general',
              finalAnswer: proposedAnswer,
              steps: stepsList,
              isVerified: verification.isVerified,
              verificationDetails: verification.message,
              timestamp: DateTime.now(),
            );
          }
        }
      } catch (_) {
        // Try next model
      }
    }

    return _fallback.solveQuestion(question, learnMode: learnMode);
  }
}
